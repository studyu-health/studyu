import { corsHeaders, handleCors } from '../_shared/cors.ts';
import { createProvider, type ImageMimeType, type LLMProvider } from './providers.ts';

const maxImageBytes = 4 * 1024 * 1024;
const maxRequestBytes = 4 * Math.ceil(maxImageBytes / 3) + 1024;
const mealTypes = new Set(['breakfast', 'brunch', 'lunch', 'dinner', 'snack', 'other']);
const authTimeoutMs = 5_000;

class RequestError extends Error {
  constructor(public readonly status: number, message: string) {
    super(message);
  }
}

function jsonResponse(status: number, body: object, extraHeaders: HeadersInit = {}): Response {
  return Response.json(body, {
    status,
    headers: { ...corsHeaders, ...extraHeaders },
  });
}

function getSupabaseConfig() {
  const url = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anonKey || !serviceKey) throw new Error('Missing Supabase configuration');
  return { url, anonKey, serviceKey };
}

async function getUserId(token: string): Promise<string | null> {
  const { url, anonKey } = getSupabaseConfig();
  const response = await fetch(new URL('/auth/v1/user', url), {
    headers: { apikey: anonKey, Authorization: `Bearer ${token}` },
    signal: AbortSignal.timeout(authTimeoutMs),
  });
  if ([400, 401, 403, 404].includes(response.status)) return null;
  if (!response.ok) throw new Error('Could not validate the Supabase session');
  const user = await response.json();
  return user.role === 'authenticated' && typeof user.id === 'string'
    ? user.id : null;
}

async function consumeQuota(userId: string): Promise<boolean> {
  const { url, serviceKey } = getSupabaseConfig();
  const response = await fetch(new URL('/rest/v1/rpc/consume_nutrition_photo_analysis_quota', url), {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ p_user_id: userId }),
    signal: AbortSignal.timeout(authTimeoutMs),
  });
  if (!response.ok) throw new Error('Could not check the photo analysis quota');
  return (await response.json()) === true;
}

async function readRequestBody(req: Request): Promise<Record<string, unknown>> {
  if (Number(req.headers.get('content-length')) > maxRequestBytes) {
    throw new RequestError(413, 'Image request exceeds the size limit');
  }
  if (!req.body) throw new RequestError(400, 'A JSON body is required');
  const reader = req.body.getReader();
  const decoder = new TextDecoder();
  const chunks: string[] = [];
  let received = 0;
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      received += value.byteLength;
      if (received > maxRequestBytes) {
        await reader.cancel();
        throw new RequestError(413, 'Image request exceeds the size limit');
      }
      chunks.push(decoder.decode(value, { stream: true }));
    }
    chunks.push(decoder.decode());
  } finally {
    reader.releaseLock();
  }
  try {
    const body: unknown = JSON.parse(chunks.join(''));
    if (body && typeof body === 'object' && !Array.isArray(body)) {
      return body as Record<string, unknown>;
    }
  } catch (error) {
    if (!(error instanceof SyntaxError)) throw error;
  }
  throw new RequestError(400, 'Invalid JSON body');
}

function readImage(value: unknown): { base64: string; mimeType: ImageMimeType } {
  if (typeof value !== 'string' || value.length < 100 || value.length % 4 !== 0 ||
      !/^[A-Za-z0-9+/]+={0,2}$/.test(value)) {
    throw new RequestError(400, 'Image must contain valid base64 data');
  }
  const padding = value.endsWith('==') ? 2 : value.endsWith('=') ? 1 : 0;
  if (value.length * 3 / 4 - padding > maxImageBytes) {
    throw new RequestError(413, 'Image exceeds the 4 MiB size limit');
  }
  const prefix = atob(value.slice(0, 12));
  if (prefix.startsWith('\xff\xd8\xff')) return { base64: value, mimeType: 'image/jpeg' };
  if (prefix.startsWith('\x89PNG\r\n\x1a\n')) return { base64: value, mimeType: 'image/png' };
  throw new RequestError(400, 'Image must be JPEG or PNG');
}

interface AnalysisDependencies {
  getUserId(token: string): Promise<string | null>;
  consumeQuota(userId: string): Promise<boolean>;
  analyzeImage: LLMProvider['analyzeImage'];
}

const dependencies: AnalysisDependencies = {
  getUserId,
  consumeQuota,
  analyzeImage: (base64, mimeType, mealContext) =>
    createProvider().analyzeImage(base64, mimeType, mealContext),
};

export async function handleFoodAnalysis(
  req: Request,
  services = dependencies,
): Promise<Response> {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;
  if (req.method !== 'POST') {
    return jsonResponse(405, { error: 'Use POST to analyze a food image' }, { Allow: 'POST, OPTIONS' });
  }

  try {
    const token = req.headers.get('authorization')?.match(/^Bearer ([^\s]+)$/i)?.[1];
    const userId = token ? await services.getUserId(token) : null;
    if (!userId) return jsonResponse(401, { error: 'Sign in to analyze a food image' });

    const body = await readRequestBody(req);
    const image = readImage(body.imageBase64);
    const { mealType, mealTime } = body;
    if ((mealType !== undefined && (typeof mealType !== 'string' || !mealTypes.has(mealType))) ||
        (mealTime !== undefined && (typeof mealTime !== 'string' || !/^(?:[01]\d|2[0-3]):[0-5]\d$/.test(mealTime)))) {
      throw new RequestError(400, 'Invalid meal type or time');
    }

    if (!await services.consumeQuota(userId)) {
      return jsonResponse(429, { error: 'Photo analysis limit reached. Try again in one minute.' }, {
        'Retry-After': '60',
      });
    }
    const result = await services.analyzeImage(image.base64, image.mimeType, { mealType, mealTime });
    return jsonResponse(200, { success: true, data: result });
  } catch (error) {
    if (error instanceof RequestError) return jsonResponse(error.status, { error: error.message });
    if (error instanceof Error && error.name === 'TimeoutError') {
      return jsonResponse(504, { error: 'Photo analysis timed out. Try again.' });
    }
    console.error('Food image analysis failed');
    return jsonResponse(500, { error: 'Could not analyze the food image' });
  }
}
