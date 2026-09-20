// @vitest-environment node
import { describe, expect, it } from 'vitest';
import { buildDemoCopilotContext } from './context';
import { validateCopilotAnswer } from './validation';

describe('Copilot evidence validation', () => {
  it('accepts only evidence IDs present in the authorized context', () => {
    const context = buildDemoCopilotContext();
    const answer = validateCopilotAnswer({
      answer: 'A frequência caiu no período.',
      evidence_ids: ['E1', 'E4'],
      limitation: null,
    }, context);
    expect(answer.evidence_ids).toEqual(['E1', 'E4']);
  });

  it('rejects fabricated evidence references', () => {
    const context = buildDemoCopilotContext();
    expect(() => validateCopilotAnswer({
      answer: 'Resposta',
      evidence_ids: ['E99'],
      limitation: null,
    }, context)).toThrow('Fabricated evidence reference');
  });

  it('deduplicates evidence references and validates shape', () => {
    const context = buildDemoCopilotContext();
    const answer = validateCopilotAnswer({
      answer: 'Resposta',
      evidence_ids: ['E1', 'E1'],
      limitation: 'Sem causalidade externa disponível.',
    }, context);
    expect(answer.evidence_ids).toEqual(['E1']);
    expect(() => validateCopilotAnswer({ answer: '', evidence_ids: [], limitation: null }, context)).toThrow();
  });
});
