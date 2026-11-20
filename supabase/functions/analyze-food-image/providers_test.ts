import { createProvider } from './providers.ts';

const providers = [
  {
    provider: 'openai',
    apiKeyName: 'OPENAI_API_KEY',
    defaultModel: 'gpt-4o-mini',
    response: (content: string) => ({ choices: [{ message: { content } }] }),
  },
  {
    provider: 'anthropic',
    apiKeyName: 'ANTHROPIC_API_KEY',
    defaultModel: 'claude-sonnet-4-6',
    response: (text: string) => ({ content: [{ text }] }),
  },
  {
    provider: 'gemini',
    apiKeyName: 'GOOGLE_API_KEY',
    defaultModel: 'gemini-3.6-flash',
    response: (text: string) => ({ candidates: [{ content: { parts: [{ text }] } }] }),
  },
];

function assertEqual(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`Expected ${JSON.stringify(expected)}, received ${JSON.stringify(actual)}`);
  }
}

for (const { provider, apiKeyName, defaultModel, response } of providers) {
  Deno.test(`${provider} preserves known zeros and omits unavailable estimates`, async () => {
    const env = new Map([['LLM_PROVIDER', provider], [apiKeyName, 'test-key']]);
    const originalFetch = globalThis.fetch;
    const content = JSON.stringify({
      items: [
        { name: 'Apple', nutrition: { energyKcal: 50, carbs: 0, protein: null, fat: -1, sugars: '' } },
        { name: 'Pear' },
      ],
    });
    globalThis.fetch = (url, options) => {
      const model = provider === 'gemini'
        ? new URL(String(url)).pathname.split('/').at(-1)?.split(':')[0]
        : JSON.parse(String(options?.body)).model;
      assertEqual(model, defaultModel);
      return Promise.resolve(Response.json(response(content)));
    };
    try {
      const testProvider = createProvider((name) => env.get(name));
      const { items } = await testProvider.analyzeImage('fixture', 'image/jpeg', {});
      assertEqual(items[0].nutrition, { energyKcal: 50, carbs: 0 });
      assertEqual(items[1].nutrition, {});
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
}
