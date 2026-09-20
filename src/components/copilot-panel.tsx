'use client';

import { FormEvent, useState } from 'react';

interface Evidence {
  id: string;
  label: string;
  value: string;
}

interface ResponsePayload {
  answer?: string;
  evidence?: Evidence[];
  limitation?: string | null;
  error?: string;
  period?: { label: string };
}

const suggestions = [
  'O que mudou nos últimos 7 dias?',
  'Onde a frequência mais mudou?',
  'Quais alunos apresentam redução relevante?',
  'Quais situações estão ativas?',
];

export function CopilotPanel() {
  const [question, setQuestion] = useState('');
  const [result, setResult] = useState<ResponsePayload | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function submit(event?: FormEvent) {
    event?.preventDefault();
    const value = question.trim();
    if (!value || submitting) return;

    setSubmitting(true);
    setResult(null);
    try {
      const response = await fetch('/api/copilot', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: value }),
      });
      const payload = await response.json() as ResponsePayload;
      setResult(payload);
    } catch {
      setResult({ error: 'Não foi possível concluir esta análise. Tente novamente.' });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section className="panel copilot-main">
      {!result ? (
        <div className="copilot-empty">
          <span className="copilot-kicker">Copiloto</span>
          <h2>O que você quer investigar?</h2>
          <div className="suggestion-list">
            {suggestions.map((suggestion) => (
              <button key={suggestion} type="button" onClick={() => setQuestion(suggestion)}>
                {suggestion}
              </button>
            ))}
          </div>
        </div>
      ) : result.error ? (
        <div className="copilot-answer error-state">
          <h2>Não foi possível responder</h2>
          <p>{result.error}</p>
        </div>
      ) : (
        <div className="copilot-answer">
          <span className="copilot-kicker">Resposta</span>
          <p className="answer-text">{result.answer}</p>
          {result.evidence?.length ? (
            <div className="evidence-block">
              <h3>Evidências</h3>
              {result.evidence.map((item) => (
                <div className="evidence-row" key={item.id}>
                  <span>{item.id}</span>
                  <div><strong>{item.label}</strong><p>{item.value}</p></div>
                </div>
              ))}
            </div>
          ) : null}
          {result.period ? <p className="response-meta">{result.period.label}</p> : null}
          {result.limitation ? (
            <div className="limitation-block">
              <strong>Limitação</strong>
              <p>{result.limitation}</p>
            </div>
          ) : null}
        </div>
      )}

      <form className="prompt-bar" onSubmit={submit}>
        <input
          value={question}
          onChange={(event) => setQuestion(event.target.value)}
          maxLength={1000}
          placeholder="Faça uma pergunta sobre os dados da unidade"
          aria-label="Pergunta ao Copiloto"
        />
        <button type="submit" disabled={submitting || !question.trim()}>
          {submitting ? 'Analisando…' : 'Enviar'}
        </button>
      </form>
      <p className="copilot-note">As respostas usam apenas fatos autorizados do contexto e evidências validadas pelo sistema.</p>
    </section>
  );
}
