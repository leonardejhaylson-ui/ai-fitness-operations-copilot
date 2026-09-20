import type { CopilotContext } from './context';
import { validateCopilotAnswer, type CopilotAnswer } from './validation';

const RESPONSE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['answer', 'evidence_ids', 'limitation'],
  properties: {
    answer: { type: 'string' },
    evidence_ids: { type: 'array', items: { type: 'string' } },
    limitation: { anyOf: [{ type: 'string' }, { type: 'null' }] },
  },
} as const;

function extractOutputText(payload: unknown): string {
  if (!payload || typeof payload !== 'object') throw new Error('Invalid provider response');
  const output = (payload as { output?: unknown }).output;
  if (!Array.isArray(output)) throw new Error('Provider response missing output');

  for (const item of output) {
    if (!item || typeof item !== 'object') continue;
    const content = (item as { content?: unknown }).content;
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      if (!part || typeof part !== 'object') continue;
      const text = (part as { text?: unknown }).text;
      if (typeof text === 'string' && text.length > 0) return text;
    }
  }
  throw new Error('Provider response missing text');
}

export async function askOpenAI(
  question: string,
  context: CopilotContext,
  signal?: AbortSignal,
): Promise<CopilotAnswer> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error('OPENAI_API_KEY is not configured');

  const model = process.env.OPENAI_MODEL || 'gpt-5.6-luna';
  const facts = context.facts.map((fact) => `${fact.id} | ${fact.label}: ${fact.value}`).join('\n');
  const limitations = context.limitations.map((item) => `- ${item}`).join('\n');

  const response = await fetch('https://api.openai.com/v1/responses', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    signal,
    body: JSON.stringify({
      model,
      input: [
        {
          role: 'system',
          content: [
            'Você é o Copiloto Operacional de uma academia.',
            'Responda em português do Brasil usando somente os fatos fornecidos.',
            'Não calcule novos números primários, não invente causas e não faça previsão de cancelamento.',
            'Quando a pergunta pedir causa, separe o que os dados mostram do que eles não permitem determinar.',
            'Use evidence_ids somente para IDs fornecidos no contexto.',
            'Se não houver evidência suficiente, declare a limitação claramente.',
          ].join(' '),
        },
        {
          role: 'user',
          content: `Pergunta: ${question}\n\nPeríodo: ${context.period.label}\n\nFatos autorizados:\n${facts}\n\nLimitações conhecidas:\n${limitations}`,
        },
      ],
      text: {
        format: {
          type: 'json_schema',
          name: 'fitness_copilot_response',
          strict: true,
          schema: RESPONSE_SCHEMA,
        },
      },
    }),
  });

  if (!response.ok) {
    throw new Error(`OpenAI provider error: ${response.status}`);
  }

  const raw = await response.json();
  const text = extractOutputText(raw);
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw new Error('Provider returned malformed structured output');
  }
  return validateCopilotAnswer(parsed, context);
}
