# AI Fitness Operations Copilot

## Product UX, Design Direction & Design System — v0.1

---

# 1. Design thesis

O produto não deve parecer:

* um chatbot com dashboard anexado;
* uma ferramenta de BI genérica;
* um painel fitness promocional;
* uma coleção de cards;
* uma demonstração de IA.

Ele deve parecer uma **ferramenta operacional de investigação**.

A experiência central é:

```text
PERCEBER
   ↓
ENTENDER
   ↓
INVESTIGAR
   ↓
VERIFICAR EVIDÊNCIA
   ↓
DECIDIR
```

O software apresenta fatos e detecta situações.

A IA ajuda o usuário a interpretá-las.

A interface deve deixar essa separação perceptível sem obrigar o usuário a entender a arquitetura técnica.

---

# 2. UX Principles

## P1 — Situação antes de visualização

O Dashboard deve responder primeiro:

> O que está acontecendo?

Somente depois:

> Como os números se comportaram?

Um gráfico não deve existir sem responder a uma questão operacional.

---

## P2 — Investigação progressiva

A hierarquia deve permitir:

```text
visão geral
→ mudança
→ decomposição
→ entidade afetada
→ evidência
→ interpretação
```

O usuário não deve receber todos os detalhes ao mesmo tempo.

---

## P3 — Evidência sempre próxima da conclusão

Qualquer insight ou resposta analítica deve tornar acessível:

* valor atual;
* referência;
* variação;
* período;
* decomposição relevante;
* limitações.

A explicação da IA nunca deve ficar visualmente desconectada dos fatos que a sustentam.

---

## P4 — IA opcional, dados essenciais

Dashboard, frequência, ocupação, membros e insights devem funcionar independentemente do LLM.

A arquitetura já estabelece que falha da IA não deve comprometer os indicadores tradicionais. 

Portanto, no UX:

```text
LLM indisponível ≠ produto indisponível
```

---

## P5 — Prioridade sem alarmismo

Uma situação de alta prioridade deve ser perceptível, mas não transformar a interface em um painel de emergência.

Evitar:

* vermelho dominante;
* banners persistentes sem necessidade;
* ícones de alerta repetidos;
* linguagem como “CRÍTICO!”;
* animações pulsantes.

Prioridade é comunicada principalmente por:

* ordem;
* peso tipográfico;
* marcador semântico;
* linguagem;
* contexto.

---

## P6 — Comparação explícita

Uma variação nunca aparece isoladamente.

Errado:

```text
-12%
```

Correto:

```text
-12%
vs. 7 dias anteriores
```

As regras de negócio já exigem que toda análise de variação declare seu período de comparação. 

---

## P7 — Certeza proporcional à evidência

A interface não deve transformar sinais em previsões.

Exemplo:

**Evitar**

> Aluno com alto risco de cancelar.

**Preferir**

> Frequência em queda acentuada.

Isso preserva a regra de que redução de frequência não significa cancelamento. 

---

## P8 — Densidade profissional

O usuário é um gestor operacional.

A interface deve permitir leitura rápida e comparação, não maximizar espaço vazio.

Usaremos:

* espaçamento controlado;
* tabelas;
* agrupamentos;
* divisores;
* tipografia hierárquica;
* poucos containers.

Não:

* uma caixa arredondada para cada número.

---

# 3. Information Architecture

```text
AI Fitness Operations Copilot
│
├── Login
│
└── Authenticated Application
    │
    ├── Overview
    │   └── Dashboard
    │
    ├── Analysis
    │   ├── Attendance
    │   └── Occupancy
    │
    ├── Members
    │   ├── Member List
    │   └── Member Details
    │
    ├── Attention
    │   ├── All Insights
    │   └── Insight Detail
    │
    └── Copilot
        ├── Conversation
        ├── Current Context
        ├── Evidence
        └── Conversation History
```

### Decisão de MVP

**Occupancy não precisa ser uma página de primeiro nível.**

Ela pode inicialmente existir como seção de Attendance Analysis.

Portanto, a navegação principal recomendada é:

```text
Overview
Attendance
Members
Attention
Copilot
```

Isso mantém o MVP pequeno e consistente com o escopo original, que concentra o produto em dashboard, frequência, ocupação, membros, sinais e copiloto. 

---

# 4. Navigation Model

## Desktop

Sidebar fixa à esquerda.

```text
┌──────────────────────────┐
│ AI Fitness Copilot       │
│ Unidade Centro           │
├──────────────────────────┤
│ Overview                 │
│ Attendance               │
│ Members                  │
│ Attention           4    │
│ Copilot                  │
├──────────────────────────┤
│ User                     │
│ Role                     │
└──────────────────────────┘
```

### Razões

A sidebar:

* preserva contexto;
* favorece aplicações operacionais;
* torna o Copilot uma função do sistema, não um produto separado;
* permite mostrar Attention count sem criar notificações intrusivas.

Não haverá navegação superior duplicando os mesmos itens.

---

# 5. Screen Inventory

| Tela                | Objetivo                                  | Ação primária          | Ações secundárias                           |
| ------------------- | ----------------------------------------- | ---------------------- | ------------------------------------------- |
| Login               | autenticar usuário autorizado             | Entrar                 | recuperar acesso                            |
| Dashboard           | compreender estado da unidade             | investigar situação    | trocar período, abrir análise               |
| Attendance Analysis | entender mudança de frequência e ocupação | explorar mudança       | filtrar período, abrir membros relacionados |
| Members             | localizar e comparar alunos               | abrir aluno            | buscar, filtrar, ordenar                    |
| Member Details      | investigar comportamento individual       | perguntar sobre aluno  | alterar período, examinar visitas           |
| Attention           | priorizar sinais determinísticos          | investigar insight     | filtrar por tipo/prioridade                 |
| Insight Detail      | explicar por que o sinal existe           | investigar com Copilot | abrir evidências/entidade                   |
| Copilot             | interpretar dados autorizados             | realizar pergunta      | usar sugestão, abrir evidência              |

---

# 6. Permissions v0.1

As funções existentes no modelo são:

* Manager;
* Coordinator;
* Analyst.

Todos os dados operacionais são associados à unidade e o usuário só pode acessar unidades autorizadas. Isso está materializado pela associação User ↔ GymUnit e pelo isolamento por `gym_unit_id`. 

Como o MVP não inclui operações administrativas de cadastro, campanhas, contratos ou CRM, a UX v0.1 deve ser predominantemente de **leitura e investigação**.

## MANAGER

Pode visualizar:

* Dashboard;
* Attendance;
* Members;
* Member Details;
* Attention;
* Copilot da unidade autorizada.

## COORDINATOR

Mesmas funções analíticas dentro das unidades às quais possui autorização.

No MVP com uma unidade, não introduzir uma interface artificial de comparação multiunidade.

## ANALYST

Pode visualizar e investigar dados autorizados.

Não haverá controles de edição apenas para criar uma diferença artificial entre papéis.

## Forbidden state

Quando uma rota válida pertence a uma unidade não autorizada:

```text
Acesso não permitido

Você não possui acesso a esta unidade.

[Voltar para Overview]
```

Nunca mostrar uma página vazia ou “404” quando a causa real é autorização.

---

# 7. Core User Flows

## 7.1 Daily operational review

```text
Login
  ↓
Dashboard
  ↓
selecionar 7d ou 30d
  ↓
ver indicadores
  ↓
ver situações que merecem atenção
  ↓
selecionar situação
  ↓
Insight Detail / análise relacionada
  ↓
inspecionar evidência
  ↓
Perguntar ao Copilot
  ↓
interpretação + evidências + limitações
```

---

## 7.2 Attendance investigation

```text
Dashboard
  ↓
frequência apresenta mudança
  ↓
Attendance Analysis
  ↓
linha temporal
  ↓
breakdown por dia
  ↓
distribuição horária
  ↓
identificar concentração da mudança
  ↓
Copilot com contexto de Attendance
```

---

## 7.3 Member investigation

```text
Attention
  ↓
"alunos com redução de frequência"
  ↓
Members filtrado
  ↓
Member Details
  ↓
histórico individual
  ↓
última visita + comparação
  ↓
"Perguntar sobre este aluno"
  ↓
Copilot contextual
```

---

## 7.4 Direct Copilot

```text
Copilot
  ↓
pergunta
  ↓
contexto autorizado
  ↓
interpretação
  ↓
evidence references
  ↓
abrir evidência
  ↓
navegar para análise correspondente
```

---

# 8. Loading Strategy

Loading não deve bloquear a aplicação inteira.

## Shell

Sidebar e cabeçalho aparecem imediatamente após sessão válida.

## Dashboard

Skeletons independentes para:

* metric strip;
* attendance chart;
* occupancy;
* attention list.

Evitar spinner central.

## Tables

Preservar:

* cabeçalho;
* filtros;
* largura das colunas.

Skeleton apenas das linhas.

## Charts

Manter altura final reservada para evitar layout shift.

## Copilot

Ao enviar pergunta:

```text
Pergunta do usuário
────────────────────────
Analisando dados da unidade…
```

Não usar:

> Pensando...

O sistema não deve teatralizar comportamento humano do modelo.

Preferir etapas funcionais, quando úteis:

```text
Consultando métricas…
Preparando contexto…
Interpretando evidências…
```

Somente se forem estados reais.

---

# 9. Empty States

## Nenhum insight ativo

Não:

> Tudo perfeito! 🎉

Preferir:

```text
Nenhuma situação relevante detectada

As regras atuais não identificaram mudanças que exijam atenção
neste período.

Período analisado: últimos 7 dias
```

---

## Members search sem resultado

```text
Nenhum aluno encontrado

Revise o nome, código ou filtros aplicados.

[Limpar filtros]
```

---

## Conversation vazia

O Copilot não começa com um mascote ou uma bolha “Olá! Como posso ajudar?”.

Mostrar:

```text
Investigue os dados da unidade

Faça uma pergunta sobre frequência, ocupação,
alunos ou situações detectadas.

Sugestões:
[O que mudou nos últimos 7 dias?]
[Quais alunos reduziram frequência?]
[Quais horários tiveram menor utilização?]
```

---

# 10. Error States

## Página

Estrutura:

```text
Não foi possível carregar os dados

Ocorreu um problema ao consultar esta informação.

[Tentar novamente]
```

Se possível:

```text
Última atualização disponível: 10:42
```

---

## Widget / section failure

Uma seção que falha não elimina o restante da página.

```text
Occupancy
────────────────────
Não foi possível carregar esta distribuição.

[Tentar novamente]
```

---

## Database unavailable

Dashboard não deve exibir números antigos como se fossem atuais sem identificação.

Mostrar indisponibilidade da informação.

---

# 11. AI Unavailable State

Este estado é essencial.

```text
Copilot temporariamente indisponível

Os dados, indicadores e análises da unidade continuam disponíveis.
Você pode continuar investigando pelo Dashboard, Attendance,
Members e Attention.

[Tentar novamente]
```

No resto do produto:

```text
[ Perguntar ao Copilot ]
          ↓
disabled

Copilot temporariamente indisponível
```

Não transformar falha de IA em banner global vermelho.

---

# 12. Insufficient Data State

Dados insuficientes são **resultado analítico**, não erro técnico.

Exemplo:

```text
Não há evidência suficiente para responder a essa pergunta.

Disponível:
• frequência
• acessos
• distribuição por horário

Não disponível:
• preço
• campanhas
• motivo de cancelamento
```

Isso segue diretamente o requisito de declarar limitações quando os dados não permitem determinar uma causa. 

---

# 13. Textual Wireframes

## 13.1 Login

```text
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│ AI FITNESS OPERATIONS                                       │
│ COPILOT                                                     │
│                                                             │
│ Inteligência operacional para gestão da unidade             │
│                                                             │
│                              ┌────────────────────────────┐ │
│                              │ Entrar                     │ │
│                              │                            │ │
│                              │ E-mail                     │ │
│                              │ [________________________] │ │
│                              │                            │ │
│                              │ Senha                      │ │
│                              │ [________________________] │ │
│                              │                            │ │
│                              │ [ Entrar ]                 │ │
│                              │                            │ │
│                              │ Esqueci minha senha        │ │
│                              └────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Sem métricas fictícias.

Sem depoimentos.

Sem “AI-powered gym management”.

---

# 14. Dashboard Wireframe

```text
┌──────────────┬──────────────────────────────────────────────────────────┐
│              │ Overview                           [7 days | 30 days]   │
│ NAVIGATION   │ Unidade Centro                                          │
│              │ Atualizado 10:42                                       │
│ Overview     ├──────────────────────────────────────────────────────────┤
│ Attendance   │                                                          │
│ Members      │ OPERATIONAL SUMMARY                                      │
│ Attention 4  │                                                          │
│ Copilot      │ Active       Accesses      Avg frequency      Attention │
│              │ 482          1,240         2.6 / week         4         │
│              │              ↓ 12% vs prev. period                      │
│              ├──────────────────────────────────────────────────────────┤
│              │ ATTENDANCE EVOLUTION                                    │
│              │                                                          │
│              │     ─────────── line chart ─────────────                 │
│              │                                                          │
│              │ Current period  ———   Previous period  ----             │
│              │                                          [View analysis] │
│              ├─────────────────────────────┬────────────────────────────┤
│              │ OCCUPANCY                   │ NEEDS ATTENTION            │
│              │                             │                            │
│              │ hourly distribution         │ HIGH                       │
│              │ / compact heat matrix       │ Attendance dropped 12%     │
│              │                             │ 7d · vs previous 7d        │
│              │                             │ [Investigate →]            │
│              │                             │                            │
│              │                             │ ATTENTION                   │
│              │                             │ 18 members reduced freq.    │
│              │                             │ [Investigate →]            │
└──────────────┴─────────────────────────────┴────────────────────────────┘
```

---

# 15. Dashboard Specification

## 15.1 Header

Deve mostrar:

* nome da tela;
* unidade ativa;
* período 7d / 30d;
* momento de atualização.

O período é um controle global do Dashboard.

---

## 15.2 Metric strip

Recomendo quatro métricas primárias:

### Active Members

Valor absoluto.

Sem comparação quando ela não possui significado operacional adequado.

### Accesses

Valor atual + comparação equivalente.

### Average Attendance

Média por membro ativo no período.

### Members Requiring Attention

Contagem de alunos atingidos por regras relevantes.

### Regra visual

Não usar quatro cards flutuantes.

Usar uma faixa única:

```text
Active members     Accesses       Avg attendance       Attention
482                1,240          2.6/week             18
                   ↓12%
───────────────────────────────────────────────────────────────
```

Divisores, não containers independentes.

---

## 15.3 Attendance Evolution

Elemento analítico principal do Dashboard.

Line chart com:

* série atual;
* período anterior comparável;
* tooltip;
* eixo temporal;
* legenda simples.

A comparação é visualmente secundária.

---

## 15.4 Occupancy

No Dashboard o objetivo não é fazer análise profunda.

Mostrar uma síntese:

* faixa horária;
* intensidade;
* indicação dos períodos mais/menos utilizados.

Clique abre Attendance Analysis já na seção de Occupancy.

---

## 15.5 Attention

Máximo recomendado no Dashboard:

**3 a 5 situações.**

Ordenadas por:

1. prioridade;
2. recência;
3. relevância operacional.

Cada linha:

```text
HIGH
Attendance decreased 12%

1,240 vs 1,410 accesses
Last 7d vs previous 7d

[Investigate]
```

Evitar transformar cada item em card grande.

---

# 16. Attendance Analysis Wireframe

```text
┌──────────────┬──────────────────────────────────────────────────────────┐
│ NAV          │ Attendance                     [7 days | 30 days]        │
│              │ Compare: previous equivalent period                     │
│              ├──────────────────────────────────────────────────────────┤
│              │ Accesses            Variation          Avg attendance    │
│              │ 1,240               -12.1%             2.6 / member     │
│              ├──────────────────────────────────────────────────────────┤
│              │ ATTENDANCE OVER TIME                                    │
│              │                                                         │
│              │ [ line chart current vs previous ]                      │
│              ├──────────────────────────────────────────────────────────┤
│              │ DAILY BREAKDOWN                                         │
│              │ Mon   Tue   Wed   Thu   Fri   Sat   Sun                 │
│              │ ...                                                     │
│              ├──────────────────────────────────────────────────────────┤
│              │ HOURLY DISTRIBUTION                                     │
│              │                                                         │
│              │       06 07 08 ... 18 19 20 ...                         │
│              │ Mon   ░  ▒  ▓      █  █  ▓                             │
│              │ Tue   ...                                               │
│              │                                                         │
│              ├──────────────────────────────────────────────────────────┤
│              │ RELATED SIGNALS                                         │
│              │ 18 members reduced attendance            [View members] │
│              │ Evening period -21%                      [Investigate]   │
│              └──────────────────────────────────────────────────────────┘
```

---

# 17. Members Wireframe

```text
┌──────────────┬──────────────────────────────────────────────────────────┐
│ NAV          │ Members                                                 │
│              │                                                         │
│              │ [ Search name or code... ]                              │
│              │ Status [All ▼]  Frequency [All ▼]  [Clear]             │
│              ├──────────────────────────────────────────────────────────┤
│              │ Name          Status   Recent freq.  Change   Last visit │
│              │──────────────────────────────────────────────────────────│
│              │ Ana Souza     Active   1 / week       ↓ 67%   8 days    │
│              │ Bruno Lima    Active   3 / week       ↓ 25%   2 days    │
│              │ Carla Melo    Active   4 / week       stable  Today     │
│              │ ...                                                     │
│              └──────────────────────────────────────────────────────────┘
```

### Default sorting

Não ordenar automaticamente por “risk score”, porque tal score não faz parte do MVP.

Quando a página é aberta a partir de Attention:

```text
Applied filter:
Frequency reduction
```

A origem da investigação deve permanecer visível.

---

# 18. Member Details Wireframe

```text
┌──────────────┬──────────────────────────────────────────────────────────┐
│ NAV          │ ← Members                                               │
│              │ Ana Souza                         ACTIVE                │
│              │ Member #A-0142                                          │
│              │                                                         │
│              │ [Ask Copilot about this member]                         │
│              ├──────────────────────────────────────────────────────────┤
│              │ Recent frequency   Previous   Change     Last visit     │
│              │ 1/week             3/week     -67%       8 days ago     │
│              ├──────────────────────────────────────────────────────────┤
│              │ ATTENDANCE HISTORY                                      │
│              │                                                         │
│              │ [individual line / weekly bars]                         │
│              ├──────────────────────────────────────────────────────────┤
│              │ DETECTED SIGNALS                                        │
│              │ ATTENTION                                               │
│              │ Frequency reduction                                     │
│              │ 1 visit vs 3 previous period                            │
│              │                                                         │
│              │ ATTENTION                                               │
│              │ 8 days since last visit                                 │
│              ├──────────────────────────────────────────────────────────┤
│              │ RECENT VISITS                                           │
│              │ 11 Sep  18:32                                           │
│              │ 04 Sep  18:47                                           │
└──────────────┴──────────────────────────────────────────────────────────┘
```

---

# 19. Attention / Insights Wireframe

```text
┌──────────────┬──────────────────────────────────────────────────────────┐
│ NAV          │ Attention                                               │
│              │                                                         │
│              │ Priority [All] Type [All] Period [7d]                   │
│              ├──────────────────────────────────────────────────────────┤
│              │ HIGH                                                    │
│              │ Attendance decreased 12%                                │
│              │ 1,240 vs 1,410 accesses                                 │
│              │ 7d vs previous 7d                                       │
│              │ Attendance · detected today                             │
│              │                                      [Investigate →]    │
│              │──────────────────────────────────────────────────────────│
│              │ ATTENTION                                               │
│              │ 18 members reduced attendance                           │
│              │ Member frequency · 7d                                   │
│              │                                      [Investigate →]    │
│              │──────────────────────────────────────────────────────────│
│              │ INFORMATION                                             │
│              │ Morning attendance remained stable                      │
│              │                                      [View evidence →]  │
└──────────────┴──────────────────────────────────────────────────────────┘
```

---

# 20. Insight Detail

Um insight não é uma frase isolada.

Estrutura:

```text
Attendance decreased 12%
HIGH PRIORITY

Last 7 days
vs previous 7 days

────────────────────────────────

WHAT CHANGED

Current
1,240 accesses

Previous
1,410 accesses

Variation
-12.1%

────────────────────────────────

WHERE THE CHANGE IS CONCENTRATED

Tuesday       -15%
Wednesday     -18%
18:00–20:00   -21%

────────────────────────────────

WHAT THIS SIGNAL MEANS

Attendance exceeded the configured
reduction threshold for this period.

────────────────────────────────

[Ask Copilot about this change]
```

O texto em “What this signal means” é determinístico.
A IA só entra após a ação explícita de investigação.

---

# 21. Insight hierarchy

O modelo de dados já define `INFO / WARNING / HIGH` para severidade dos snapshots de insight. 

Na linguagem da interface:

## INFORMATION

Significa:

> mudança observável, útil para contexto, sem necessidade clara de intervenção.

Visual:

* neutral/cool badge;
* sem ícone de alerta.

---

## ATTENTION

Significa:

> mudança relevante que merece revisão.

Visual:

* amber/brown semantic marker;
* ícone apenas quando necessário.

---

## HIGH PRIORITY

Significa:

> mudança relevante acima de um threshold mais importante ou com impacto operacional maior.

Visual:

* muted brick/red;
* maior prioridade na ordenação;
* maior peso tipográfico.

### Importante

“High priority” não significa:

* emergência;
* previsão;
* falha;
* cancelamento iminente.

---

# 22. Copilot UX Specification

O Copilot deve parecer um **modo de análise conversacional dos dados**, não um chatbot independente.

## Layout desktop

```text
┌──────────────┬──────────────────────────────────────────────────────────┐
│ NAV          │ Copilot                                                 │
│              │ Unit: Centro · Context: Attendance · Last 7 days        │
│              ├───────────────────────────────┬──────────────────────────┤
│              │ CONVERSATION                  │ CURRENT CONTEXT          │
│              │                               │                          │
│              │ USER                          │ Unit                     │
│              │ Why did attendance decrease?  │ Centro                   │
│              │                               │                          │
│              │ COPILOT                       │ Period                   │
│              │ Attendance decreased mainly   │ Last 7 days              │
│              │ on Tuesday and Wednesday,     │                          │
│              │ with the largest change       │ Compared with            │
│              │ between 18:00 and 20:00.      │ Previous 7 days          │
│              │                               │                          │
│              │ Evidence 4                    │ Context source           │
│              │ [View evidence]               │ Attendance Analysis      │
│              │                               │                          │
│              │ Limitation                    │ [Change context]         │
│              │ No cancellation-reason data   │                          │
│              │ is available.                 │                          │
│              │                               │                          │
│              │ Suggested follow-ups          │                          │
│              │ [Which members changed most?] │                          │
│              │ [Was morning attendance flat?]│                          │
│              │                               │                          │
│              ├───────────────────────────────┴──────────────────────────┤
│              │ Ask about this data...                         [Send]   │
└──────────────┴──────────────────────────────────────────────────────────┘
```

---

# 23. AI Interaction Model

## 23.1 Context-first

Sempre mostrar o contexto usado:

```text
Centro
Attendance
Last 7 days
vs previous 7 days
```

Quando o usuário entra pelo Member Details:

```text
Centro
Ana Souza
Last 30 days
```

---

## 23.2 Context inheritance

Botão:

> Ask Copilot about this

leva junto:

* página atual;
* unidade;
* entidade;
* período;
* insight selecionado, quando houver.

O usuário não precisa repetir:

> “Estou falando da Ana Souza nos últimos 30 dias.”

---

## 23.3 Context can be inspected

O painel lateral “Current context” permite saber **sobre o que a IA está respondendo**.

Isso reduz ambiguidade e melhora confiança.

---

## 23.4 No fake persona

Não usar:

* avatar robô;
* nome humano;
* “digitando…”;
* olhos ou mascote;
* mensagens excessivamente conversacionais.

Label recomendado:

**Copilot**

Não:

**FitBot**, **GymGPT**, etc.

---

# 24. Evidence UX

Cada resposta analítica deve possuir quatro camadas.

## Layer 1 — Answer

Texto sintético:

> A redução está concentrada principalmente na terça e quarta-feira e foi mais forte entre 18h e 20h.

---

## Layer 2 — Evidence summary

```text
Evidence · 4

- Overall attendance      -12.1%
- Tuesday                 -15%
- Wednesday               -18%
- 18:00–20:00             -21%
```

---

## Layer 3 — Period

```text
Period
12–18 Sep

Compared with
5–11 Sep
```

---

## Layer 4 — Limitations

```text
Limitations

The available data does not include:
• weather
• pricing changes
• cancellation reasons
• marketing campaigns
```

A arquitetura já prevê evidências identificáveis e validação para impedir que o LLM referencie fatos inexistentes no contexto.

---

# 25. Evidence interactions

Cada evidência deve poder levar o usuário para sua origem.

Exemplo:

```text
18:00–20:00     -21%
[Open in Attendance]
```

Isso cria:

```text
AI interpretation
        ↓
evidence
        ↓
deterministic UI
```

Em vez de:

```text
AI says something
        ↓
trust it
```

---

# 26. Suggested Questions

Sugestões devem ser contextuais e derivadas das capacidades disponíveis.

## Dashboard

* O que mudou neste período?
* Qual situação merece investigação?
* Onde a frequência mais mudou?

## Attendance

* Em quais dias a queda foi maior?
* Que faixa horária mudou mais?
* A manhã também apresentou redução?

## Member

* O que mudou na frequência deste aluno?
* Quando começou a redução?
* Quantos dias se passaram desde a última visita?

## Insight

* Onde esta mudança está concentrada?
* Quais alunos estão relacionados?
* O que os dados disponíveis permitem concluir?

Evitar sugestões que pedem dados fora do escopo.

---

# 27. Design Direction

## Nome interno da direção

**Operational Intelligence Console**

Não é uma estética “futurista de IA”.

É uma linguagem de:

* análise;
* precisão;
* controle;
* clareza;
* confiança.

---

# 28. Personality

A personalidade visual deve ser:

**precisa + sóbria + analítica + humana sem ser informal.**

Não:

* fria demais;
* bancária;
* esportiva;
* futurista;
* lúdica.

O produto não precisa usar linguagem visual de academia.

Nenhum motivo visual exige:

* halteres;
* batimento cardíaco;
* vermelho “fitness”;
* verde “saúde”.

O domínio aparece nos dados, não na decoração.

---

# 29. Visual Density

Densidade:

**medium-dense.**

Objetivo:

* bastante informação por viewport;
* leitura confortável;
* bom uso em monitor corporativo.

Padrões:

* row height de tabela moderado;
* cabeçalhos compactos;
* espaços amplos apenas entre grandes regiões funcionais;
* espaços menores dentro de agrupamentos.

---

# 30. Typography

## Primary

**IBM Plex Sans**

Razões:

* desenho técnico sem parecer frio;
* excelente legibilidade;
* boa presença em interfaces densas;
* adequada para números e tabelas;
* possui identidade mais própria que uma UI genérica baseada apenas em Inter.

Fallback:

```text
system sans-serif
```

## Monospace

IBM Plex Mono apenas para:

* member code;
* identificadores técnicos em telas internas;
* valores técnicos de auditoria, caso expostos.

Não usar mono para todos os números.

---

# 31. Typography Scale

| Token    | Size / Line | Uso                  |
| -------- | ----------- | -------------------- |
| Display  | 32 / 40     | raramente; login     |
| H1       | 28 / 36     | título principal     |
| H2       | 22 / 30     | seção principal      |
| H3       | 18 / 26     | seção interna        |
| Body L   | 16 / 24     | explicações          |
| Body     | 14 / 21     | UI padrão            |
| Small    | 13 / 18     | metadata             |
| Caption  | 12 / 16     | timestamps / labels  |
| Metric L | 32 / 36     | número principal     |
| Metric M | 24 / 30     | métricas secundárias |

Numerais devem usar `tabular numerals`.

---

# 32. Grid

## Desktop

App shell:

```text
Sidebar: 224–240px
Content: fluid
Maximum analytical width: ~1440px
```

Main content:

**12-column grid.**

Usos:

```text
12 cols → charts principais
8 + 4  → chart + insights
6 + 6  → análises equivalentes
```

Evitar grid de cards de 3 colunas como estrutura predominante.

---

# 33. Spacing Scale

Base 4px:

```text
4
8
12
16
20
24
32
40
48
64
```

Principais convenções:

* 4–8: relações internas;
* 12–16: controles;
* 20–24: grupos;
* 32: seções;
* 48+: grandes divisões.

---

# 34. Radius

```text
0px   tables / structural dividers
4px   small controls
6px   buttons / inputs
8px   panels / dialogs
```

Não usar 16–24px como padrão.

---

# 35. Borders

Borders são uma ferramenta estrutural importante.

```text
1px solid neutral-200
```

Usados para:

* separar regiões;
* delimitar tabelas;
* inputs;
* side panels.

Preferir borda a sombra.

---

# 36. Elevation

## Level 0

Default.

Nenhuma sombra.

## Level 1

Menus flutuantes, popovers.

Sombra muito discreta.

## Level 2

Dialogs.

Nenhum outro elemento deve parecer “flutuando” sem necessidade.

---

# 37. Color Philosophy

A cor não é decoração.

Ela possui quatro funções:

1. estrutura;
2. interação;
3. estado;
4. visualização de dados.

## Foundation

**Graphite / ink**

Usado em:

* sidebar;
* textos;
* estrutura.

Expressa estabilidade operacional.

## Canvas

Warm neutral / off-white.

Evita o branco clínico puro e cria contraste suave com superfícies.

## Interaction

**Deep blue.**

Usado em:

* links;
* botão primário;
* foco;
* seleção;
* série principal dos gráficos.

Azul representa ação/interface, não “resultado positivo”.

## Semantic attention

**Muted amber.**

Atenção sem aparência de erro.

## High priority

**Muted brick / dark vermilion.**

Uso muito restrito.

## Positive / stable

Verde dessaturado apenas quando o conceito realmente for positivo/estável.

Nunca colorir todos os números positivos de verde automaticamente.

---

# 38. Suggested Core Tokens

Direção inicial, sujeita a validação de contraste:

```text
Ink 950        #17191C
Ink 800        #2D3035
Neutral 600    #646A73
Neutral 400    #989EA7
Neutral 200    #D9DDE2
Neutral 100    #ECEFF2
Canvas         #F6F7F5
Surface        #FFFFFF

Action 700     #274C77
Action 600     #315F91
Action 100     #E8EFF6

Attention 700  #8A5A19
Attention 100  #F7EEDC

High 700       #93443C
High 100       #F7E8E6

Success 700    #3F6B56
Success 100    #E8F0EB
```

O sistema deve funcionar mesmo em grayscale.

A cor reforça significado; não o cria sozinha.

---

# 39. Buttons

## Primary

Uma ação dominante por região.

Exemplos:

* Entrar;
* Send question;
* Retry.

## Secondary

Para ações importantes mas não dominantes.

## Tertiary

Text/button.

Muito utilizado para:

* View analysis;
* View evidence;
* Clear filters.

## Destructive

Provavelmente quase inexistente no MVP.

---

# 40. Inputs

Altura recomendada:

40px desktop.

Estrutura obrigatória:

```text
Label
[ Input                    ]
Supporting/error text
```

Placeholder nunca substitui label.

Focus state forte e acessível.

---

# 41. Selects

Utilizar para filtros discretos:

* status;
* insight type;
* priority.

Para 7d / 30d, usar segmented control.

São apenas duas opções recorrentes; um dropdown adicionaria fricção.

---

# 42. Tables

Tabelas são componente de primeira classe.

Não converter listas estruturadas em cards.

Características:

* header persistente quando útil;
* alinhamento consistente;
* números à direita;
* texto à esquerda;
* sort indicator claro;
* row hover discreto;
* linha inteira clicável quando abre detalhe.

Density:

```text
default row: ~44–48px
```

---

# 43. Badges

Badges só para categorias compactas:

* ACTIVE;
* INACTIVE;
* INFORMATION;
* ATTENTION;
* HIGH PRIORITY.

Não usar badge para:

* todo valor;
* datas;
* percentuais;
* navegação.

---

# 44. Alerts

Alerts reservados para situações de sistema:

* sessão expirada;
* falha de carregamento;
* IA indisponível;
* operação não autorizada.

Insight operacional **não é alert component**.

Ele pertence à linguagem própria de Insights.

---

# 45. Metric Display

Estrutura:

```text
ACCESSES

1,240
↓ 12.1%

vs previous 7 days
```

Não incluir:

* ícone decorativo;
* mini sparkline sem necessidade;
* background colorido;
* borda espessa.

---

# 46. Navigation Components

## Sidebar

Estado ativo:

* subtle filled row;
* left indicator opcional;
* contraste de texto.

Não usar pills arredondadas.

## Breadcrumb

Apenas em profundidade:

```text
Members / Ana Souza
```

ou

```text
Attention / Attendance decrease
```

---

# 47. Dialogs

Dialogs somente para tarefas que realmente interrompem o fluxo.

Exemplos possíveis:

* detalhes técnicos da evidência;
* confirmação de saída quando houver conteúdo não enviado.

Não abrir Member Details ou Insight Detail em modal.

Esses objetos merecem URL/página própria.

---

# 48. Tooltips

Uso:

* explicar definição de métrica;
* ponto de gráfico;
* abreviações.

Não esconder informações críticas exclusivamente em tooltip.

---

# 49. Loading Skeletons

Skeleton deve representar a forma real do conteúdo.

Metric:

```text
██████
██████████
```

Chart:

```text
Title █████
────────────────────
        skeleton plot
────────────────────
```

Sem shimmer intenso.

---

# 50. Empty Component Pattern

Todo estado vazio deve responder:

1. o que está vazio;
2. por quê, se soubermos;
3. o que fazer depois.

Template:

```text
No [items]

[Explanation]

[Optional action]
```

---

# 51. Error Component Pattern

Todo erro deve distinguir:

**system failure**

de

**valid lack of data**.

Isso é particularmente importante porque `INSUFFICIENT_DATA` já existe conceitualmente como estado distinto das falhas de provider ou validação na arquitetura de IA.

---

# 52. Charts — General Philosophy

Todo gráfico precisa responder a uma pergunta.

Antes de adicionar um gráfico:

> Qual decisão de leitura ele torna mais fácil?

Se a resposta puder ser apresentada melhor por:

* número;
* frase;
* tabela;

não usar gráfico.

---

# 53. Line Chart

Usar quando:

* há evolução temporal;
* importa visualizar direção;
* existe comparação contínua.

Principal uso:

**Attendance over time.**

### Comparison

Current:

* linha sólida;
* maior contraste.

Previous:

* linha secundária;
* tracejada ou menor intensidade.

Não usar duas cores completamente diferentes se ambas representam a mesma métrica em períodos diferentes.

---

# 54. Bar Chart

Usar quando:

* comparação entre categorias discretas;
* dias da semana;
* faixas horárias específicas.

Exemplo:

```text
Mon █████████
Tue ██████
Wed █████
```

Bom para mostrar concentração da queda.

---

# 55. Hourly Distribution

Para ocupação:

**heat matrix** ou barras por faixa horária.

Desktop detalhado:

```text
       06 07 08 09 ... 18 19 20 21
Mon    ░  ▒  ▓  ▒      █  █  ▓  ▒
Tue    ...
```

Não depender apenas da cor.

Tooltip deve fornecer valor exato.

Uma alternativa acessível em tabela deve estar disponível.

---

# 56. Tables vs Charts

Usar tabela quando:

* valores exatos importam;
* há muitos membros;
* precisamos localizar uma entidade;
* ordenar/filterar é importante.

Usar gráfico quando:

* forma/padrão é mais importante que valor exato.

---

# 57. Numerical Indicators

Indicador numérico é preferido quando a pergunta é:

> Quanto?

Exemplo:

```text
18
members with relevant frequency reduction
```

Não criar donut chart para isso.

---

# 58. Period Comparison

Formato padrão:

```text
Current
1,240

Previous
1,410
Change
-12.1%

Last 7 days vs previous 7 days
```

Nunca usar apenas seta ↑ ou ↓.

A seta reforça a direção, mas o sinal numérico continua obrigatório.

---

# 59. Responsive Rules

## Desktop ≥ 1280px

Experiência principal.

* sidebar fixa;
* grid 12 cols;
* context panel do Copilot;
* tabelas completas;
* charts completos.

---

## Small desktop / tablet landscape

Sidebar colapsável.

Layout:

```text
12 cols
↓
8 + 4
↓
full width sequential
```

Copilot context passa para drawer.

---

## Tablet portrait

* navegação compacta;
* métricas 2 × 2;
* charts full-width;
* Attention abaixo;
* tables com prioridades de coluna.

Members:

Mostrar primeiro:

* name;
* recent frequency;
* change;
* last visit.

---

## Mobile

Não tentar replicar dashboard desktop.

Priorizar:

1. summary;
2. attention;
3. primary trend;
4. navigation to detail.

Sidebar vira navigation drawer.

Tables podem virar **structured rows**, não cards decorativos.

Copilot:

* full screen;
* contexto acessível em sheet;
* evidence expansível.

O mobile é funcional, mas não será o principal cenário de apresentação.

---

# 60. Accessibility Rules

## Contrast

WCAG AA como mínimo.

Text normal:

**4.5:1**

Large text:

**3:1**

UI/focus boundaries:

**3:1** quando aplicável.

---

## Keyboard

Todos os controles:

* tab reachable;
* logical focus order;
* Enter/Space apropriados;
* Escape fecha overlays;
* foco retorna ao elemento acionador.

---

## Focus

Focus ring sempre visível.

Não remover outline sem substituição equivalente.

---

## Labels

Inputs sempre possuem label persistente.

Gráficos possuem:

* título;
* descrição;
* dados alternativos.

---

## Charts

Nunca usar apenas cor.

Combinar:

* line style;
* markers quando necessário;
* labels;
* tooltip;
* legend;
* tabela alternativa.

---

## Insights

Além da cor:

```text
INFORMATION
ATTENTION
HIGH PRIORITY
```

sempre em texto.

---

## Trend

Não:

```text
green vs red only
```

Usar:

```text
↓ -12.1%
↑ +8.4%
→ stable
```

---

# 61. Anti-Patterns

O projeto deve rejeitar explicitamente:

### Dashboard-as-card-grid

Dez caixas independentes de mesmo peso.

### AI-first homepage

Tela inicial dominada por “Ask anything”.

### Chatbot floating bubble

O Copilot possui área operacional própria.

### Glassmorphism

Não agrega significado.

### Gradient branding everywhere

Evitar completamente na UI operacional v0.1.

### Neon / AI purple

Não existe razão semântica.

### Excessive radius

Reduz densidade e dá aspecto consumer/SaaS genérico.

### Decorative icons

Todo ícone precisa representar ação, categoria ou estado.

### Fake real-time

Não usar “LIVE” se os dados não são realmente live.

### Fake precision

Não usar “89% chance of cancellation”.

Essa capacidade não existe.

### Invented KPI

Não criar:

* retention score;
* health score;
* engagement score;
* AI score;

sem definição determinística aprovada.

### AI calculating visible facts

Nunca exibir um número como se tivesse sido “descoberto pela IA”.

### Hidden comparison period

Toda variação informa sua referência.

### Alarm overload

High priority não cria tela vermelha.

### Nested cards

Panel → card → inner card → badge container deve ser evitado.

### Chart decoration

Pie, radial, gauge e donut não entram apenas para variedade visual.

---

# 62. UI Acceptance Criteria

## Global

* [ ] O usuário identifica unidade e página atual sem ambiguidade.
* [ ] O usuário consegue navegar pelo produto sem usar o Copilot.
* [ ] Nenhuma métrica operacional é apresentada como produzida pela IA.
* [ ] Períodos comparativos aparecem explicitamente.
* [ ] O layout evita card-grid como estrutura dominante.
* [ ] Estados semânticos não dependem apenas de cor.
* [ ] Elementos decorativos sem função são evitados.

## Login

* [ ] Possui labels persistentes.
* [ ] Erros de autenticação são claros.
* [ ] Não apresenta dashboard fictício ou marketing.
* [ ] Keyboard flow é completo.

## Dashboard

* [ ] 7d / 30d é imediatamente localizável.
* [ ] Principais indicadores são compreendidos em poucos segundos.
* [ ] Attendance evolution possui comparação equivalente.
* [ ] Occupancy é perceptível sem dominar a página.
* [ ] Attention mostra apenas situações relevantes.
* [ ] Toda situação possui caminho de investigação.
* [ ] Dashboard continua funcionando sem LLM.

## Attendance

* [ ] Evolução temporal é distinguível do período anterior.
* [ ] Breakdown diário pode ser lido sem gráfico complexo.
* [ ] Distribuição horária mostra valores exatos sob interação.
* [ ] Existe representação alternativa acessível.
* [ ] Filtros mantêm contexto de período.

## Members

* [ ] Busca aceita nome/código.
* [ ] Tabela suporta leitura rápida.
* [ ] Frequência recente e mudança são distinguíveis.
* [ ] Não existe “prediction score” inventado.
* [ ] Clique em membro abre página dedicada.

## Member Details

* [ ] Mostra comportamento, não julgamento.
* [ ] Última visita está clara.
* [ ] Comparação possui período explícito.
* [ ] Sinais relacionados mostram evidências.
* [ ] “Ask Copilot” transmite contexto automaticamente.

## Attention

* [ ] INFORMATION, ATTENTION e HIGH PRIORITY são distinguíveis por mais que cor.
* [ ] Priority altera hierarquia, não dramatização.
* [ ] Cada insight mostra período.
* [ ] Cada insight oferece evidência verificável.
* [ ] Terminologia não implica cancelamento futuro.

## Copilot

* [ ] Contexto atual está visível.
* [ ] Resposta diferencia interpretação de evidência.
* [ ] Evidências podem ser inspecionadas.
* [ ] Período está explícito.
* [ ] Limitações estão visíveis quando relevantes.
* [ ] Perguntas sugeridas respeitam o contexto disponível.
* [ ] Falha do LLM tem fallback claro.
* [ ] Insufficient data não aparece como erro técnico.
* [ ] O usuário consegue retornar da evidência para análise determinística.
* [ ] Não existe avatar/mascote/chat bubble genérico.

## Accessibility

* [ ] Contraste AA.
* [ ] Navegação integral por teclado.
* [ ] Focus state visível.
* [ ] Labels programaticamente associáveis.
* [ ] Charts possuem descrição e alternativa textual/tabular.
* [ ] Estado nunca depende exclusivamente de cor.
* [ ] Touch targets adequados em tablet/mobile.

---

# 63. Final Experience Model

A estrutura final do produto deve comunicar visualmente:

```text
                  OPERATIONAL DATA
                        │
                        ▼
                DETERMINISTIC METRICS
                        │
                        ▼
                  DETECTED SIGNALS
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
       USER INVESTIGATION      AI INTERPRETATION
             │                     │
             └──────────┬──────────┘
                        ▼
                    EVIDENCE
                        │
                        ▼
                  HUMAN DECISION
```

Essa é a identidade central do AI Fitness Operations Copilot.

A interface não vende “inteligência artificial”.

Ela demonstra inteligência operacional — e usa IA somente no ponto em que interpretação realmente melhora a investigação.

A decisão mais importante deste documento é a hierarquia **Overview → análise determinística → Insight → evidência → Copilot contextual**. Ela transforma o princípio arquitetural em comportamento de produto, em vez de apenas repeti-lo na interface. O escopo continua deliberadamente pequeno: uma unidade no MVP, members/access records como dados operacionais centrais e o Copilot trabalhando sobre contexto autorizado, sem tentar transformar o sistema em ERP/CRM. 

O próximo artefato lógico, antes de implementação, é um **UI Screen Specification v0.1** com cada tela detalhada em componentes, conteúdo exato, estados e comportamento — suficientemente preciso para um agente de frontend implementar sem tomar decisões de produto por conta própria.
