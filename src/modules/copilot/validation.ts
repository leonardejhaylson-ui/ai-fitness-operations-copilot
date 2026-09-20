import type { CopilotContext } from './context';

export interface CopilotAnswer {
  readonly answer: string;
  readonly evidence_ids: readonly string[];
  readonly limitation: string | null;
}

export function validateCopilotAnswer(value: unknown, context: CopilotContext): CopilotAnswer {
  if (!value || typeof value !== 'object') throw new Error('Invalid Copilot response');
  const candidate = value as Record<string, unknown>;

  if (typeof candidate.answer !== 'string' || candidate.answer.trim().length === 0)
    throw new Error('Invalid Copilot answer');

  if (!Array.isArray(candidate.evidence_ids) || !candidate.evidence_ids.every((id) => typeof id === 'string'))
    throw new Error('Invalid Copilot evidence');

  if (candidate.limitation !== null && typeof candidate.limitation !== 'string')
    throw new Error('Invalid Copilot limitation');

  const allowed = new Set(context.facts.map((fact) => fact.id));
  for (const id of candidate.evidence_ids) {
    if (!allowed.has(id)) throw new Error('Fabricated evidence reference');
  }

  return {
    answer: candidate.answer.trim(),
    evidence_ids: [...new Set(candidate.evidence_ids as string[])],
    limitation: candidate.limitation === null ? null : candidate.limitation.trim(),
  };
}
