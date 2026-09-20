import { NextResponse } from 'next/server';
import { buildDemoCopilotContext } from '@/modules/copilot/context';
import { askOpenAI } from '@/modules/copilot/gateway';
import { getAuthenticatedUser } from '@/lib/supabase/server';

const MAX_QUESTION_LENGTH = 1000;

export async function POST(request: Request) {
  const user = await getAuthenticatedUser();
  if (!user) return NextResponse.json({ error: 'Não autorizado.' }, { status: 401 });

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'Pergunta inválida.' }, { status: 400 });
  }

  const question = typeof (body as { question?: unknown })?.question === 'string'
    ? (body as { question: string }).question.trim()
    : '';

  if (!question || question.length > MAX_QUESTION_LENGTH) {
    return NextResponse.json({ error: 'A pergunta deve ter entre 1 e 1000 caracteres.' }, { status: 400 });
  }

  const context = buildDemoCopilotContext();

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20_000);
    try {
      const result = await askOpenAI(question, context, controller.signal);
      const evidence = result.evidence_ids.map((id) => context.facts.find((fact) => fact.id === id)!).filter(Boolean);
      return NextResponse.json({
        answer: result.answer,
        evidence,
        limitation: result.limitation,
        period: context.period,
      });
    } finally {
      clearTimeout(timeout);
    }
  } catch {
    return NextResponse.json({
      error: 'Não foi possível concluir esta análise. Tente novamente.',
    }, { status: 503 });
  }
}
