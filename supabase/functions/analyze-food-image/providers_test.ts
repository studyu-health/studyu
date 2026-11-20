import { createProvider } from './providers.ts';

const providers = [
  {
    provider: 'openai',
    apiKeyName: 'OPENAI_API_KEY',
    response: (content: string) => ({ choices: [{ message: { content } }] }),
  },
  {
    provider: 'anthropic',
    apiKeyName: 'ANTHROPIC_API_KEY',
    response: (text: string) => ({ content: [{ text }] }),
  },
  {
    provider: 'gemini',
    apiKeyName: 'GOOGLE_API_KEY',
    response: (text: string) => ({ candidates: [{ content: { parts: [{ text }] } }] }),
  },
];

function assertEqual(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`Expected ${JSON.stringify(expected)}, received ${JSON.stringify(actual)}`);
  }
}

for (const { provider, apiKeyName, response } of providers) {
  Deno.test(`${provider} preserves known zeros and omits unavailable estimates`, async () => {
    const originalProvider = Deno.env.get('LLM_PROVIDER');
    const originalApiKey = Deno.env.get(apiKeyName);
    const originalFetch = globalThis.fetch;
    Deno.env.set('LLM_PROVIDER', provider);
    Deno.env.set(apiKeyName, 'test-key');
    const content = JSON.stringify({
      items: [
        { name: 'Apple', nutrition: { energyKcal: 50, carbs: 0, protein: null, fat: -1, sugars: '' } },
        { name: 'Pear' },
      ],
    });
    globalThis.fetch = () => Promise.resolve(Response.json(response(content)));
    try {
      const { items } = await createProvider().analyzeImage('fixture', 'image/jpeg', {});
      assertEqual(items[0].nutrition, { energyKcal: 50, carbs: 0 });
      assertEqual(items[1].nutrition, {});
    } finally {
      globalThis.fetch = originalFetch;
      if (originalProvider === undefined) Deno.env.delete('LLM_PROVIDER');
      else Deno.env.set('LLM_PROVIDER', originalProvider);
      if (originalApiKey === undefined) Deno.env.delete(apiKeyName);
      else Deno.env.set(apiKeyName, originalApiKey);
    }
  });
}
