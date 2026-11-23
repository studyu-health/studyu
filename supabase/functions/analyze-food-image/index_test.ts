import { handleFoodAnalysis } from './handler.ts';

const jpeg = btoa('\xff\xd8\xff' + '\x00'.repeat(72));
const png = btoa('\x89PNG\r\n\x1a\n' + '\x00'.repeat(67));

function postImage(imageBase64: string, headers?: HeadersInit) {
  return new Request('https://studyu.test/analyze-food-image', {
    method: 'POST',
    headers: { Authorization: 'Bearer test-session', ...headers },
    body: JSON.stringify({ imageBase64, mealType: 'brunch', mealTime: '10:30' }),
  });
}

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) throw new Error(`Expected ${expected}, received ${actual}`);
}

function fakeServices({ authenticated = true, quota = true } = {}) {
  const calls: string[] = [];
  return {
    calls,
    getUserId(token: string) {
      calls.push(`session:${token}`);
      return Promise.resolve(authenticated ? 'test-user' : null);
    },
    consumeQuota(userId: string) {
      calls.push(`quota:${userId}`);
      return Promise.resolve(quota);
    },
    analyzeImage(_base64: string, mimeType: string) {
      calls.push(mimeType);
      return Promise.resolve({ items: [], overallConfidence: 0 });
    },
  };
}

Deno.test('validates the session and checks quota before forwarding a JPEG or PNG', async () => {
  const services = fakeServices();
  assertEquals((await handleFoodAnalysis(postImage(jpeg), services)).status, 200);
  assertEquals((await handleFoodAnalysis(postImage(png), services)).status, 200);
  assertEquals(
    services.calls.join(','),
    'session:test-session,quota:test-user,image/jpeg,session:test-session,quota:test-user,image/png',
  );
});

Deno.test('stops when the session check fails', async () => {
  const services = fakeServices({ authenticated: false });
  assertEquals((await handleFoodAnalysis(postImage(jpeg), services)).status, 401);
  assertEquals(services.calls.join(','), 'session:test-session');
});

Deno.test('rejects invalid image data and oversized requests before consuming quota', async () => {
  const services = fakeServices();
  assertEquals((await handleFoodAnalysis(postImage('invalid'), services)).status, 400);
  assertEquals((await handleFoodAnalysis(postImage(jpeg, { 'Content-Length': '6000000' }), services)).status, 413);
  assertEquals((await handleFoodAnalysis(postImage(jpeg + 'A'.repeat(6000000)), services)).status, 413);
  assertEquals(services.calls.join(','), 'session:test-session,session:test-session,session:test-session');
});

Deno.test('returns retry information after the quota is exhausted', async () => {
  const services = fakeServices({ quota: false });
  const response = await handleFoodAnalysis(postImage(jpeg), services);
  assertEquals(response.status, 429);
  assertEquals(response.headers.get('Retry-After'), '60');
  assertEquals(services.calls.join(','), 'session:test-session,quota:test-user');
});
