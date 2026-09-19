# AI Fitness Operations Copilot

## Arquitetura Inicial — v0.1

## 1. Architecture Overview

### Decisão principal

Para o MVP, a arquitetura recomendada é:

**Monólito modular full-stack em TypeScript**

com:

**Next.js / React**
→ apresentação e endpoints HTTP

**Application / Domain Modules**
→ casos de uso, regras e orquestração

**PostgreSQL via Supabase**
→ persistência

**Metrics Engine**
→ cálculos determinísticos

**Insight Engine**
→ detecção determinística de situações relevantes

**AI Context Builder**
→ transformação de fatos autorizados em contexto estruturado

**LLM Gateway**
→ comunicação controlada com o modelo

**LLM**
→ interpretação e síntese

A arquitetura deve preservar uma regra fundamental:

> **Database contém fatos.**
> **Metrics Engine calcula fatos derivados.**
> **Insight Engine detecta situações.**
> **LLM interpreta essas situações.**

O LLM nunca será a fonte da verdade operacional.

Isso é especialmente importante porque a especificação determina que médias, percentuais, rankings, ocupação e comparações sejam calculados pelo sistema e que a IA não seja responsável pela autenticação, autorização, persistência ou regras de acesso.

---

# 2. Visão arquitetural

```text
                        ┌───────────────────────────┐
                        │          Browser          │
                        │ Dashboard / Copilot UI    │
                        └─────────────┬─────────────┘
                                      │ HTTPS
                                      ▼
                        ┌───────────────────────────┐
                        │       Next.js App         │
                        │                           │
                        │ React / App Router        │
                        │ Server Components         │
                        │ Client Components         │
                        └─────────────┬─────────────┘
                                      │
                                      ▼
                        ┌───────────────────────────┐
                        │          API              │
                        │ Next.js Route Handlers    │
                        │ validation / auth / HTTP  │
                        └─────────────┬─────────────┘
                                      │
                                      ▼
                 ┌───────────────────────────────────────┐
                 │       Application / Domain Layer      │
                 │                                       │
                 │ Dashboard Use Cases                   │
                 │ Member Analysis                       │
                 │ Operational Analysis                  │
                 │ Copilot Orchestration                 │
                 └──────────┬───────────┬────────────────┘
                            │           │
                    ┌───────▼─────┐ ┌──▼──────────────┐
                    │ Repository  │ │ Metrics Engine  │
                    │ Layer       │ │ deterministic   │
                    └───────┬─────┘ └──┬──────────────┘
                            │           │
                            │           ▼
                            │    ┌────────────────────┐
                            │    │  Insight Engine    │
                            │    │ deterministic      │
                            │    └─────────┬──────────┘
                            │              │
                            ▼              │
                    ┌───────────────┐      │
                    │  PostgreSQL   │◄─────┘
                    │   Supabase    │
                    └───────────────┘

Copilot:

Question
   │
   ▼
Authorization
   │
   ▼
Application Service
   │
   ▼
Relevant Metrics / Insights
   │
   ▼
AI Context Builder
   │
   ▼
LLM Gateway
   │
   ▼
LLM
   │
   ▼
Structured AI Response
   │
   ▼
Evidence Validation
   │
   ▼
Browser
```

---

# 3. Recommended Stack

## Stack recomendada

| ÁreaTecnologia          |                                    |
| ----------------------- | ---------------------------------- |
| Linguagem               | TypeScript                         |
| Frontend                | React + Next.js                    |
| Framework               | Next.js App Router                 |
| UI                      | Tailwind CSS                       |
| Componentes             | shadcn/ui ou componentes próprios  |
| Gráficos                | Recharts                           |
| API                     | Next.js Route Handlers             |
| Validação               | Zod                                |
| Backend                 | Node.js / TypeScript               |
| Arquitetura             | Modular Monolith                   |
| Banco                   | PostgreSQL                         |
| Plataforma DB           | Supabase                           |
| Autenticação            | Supabase Auth                      |
| Autorização             | Application layer + PostgreSQL RLS |
| IA                      | OpenAI API via backend             |
| Testes unitários        | Vitest                             |
| Testes React            | Testing Library                    |
| E2E                     | Playwright                         |
| Observabilidade         | logs estruturados + Sentry         |
| Deploy frontend/backend | Vercel                             |
| Banco/Auth              | Supabase                           |
| CI                      | GitHub Actions                     |
| Repositório             | GitHub                             |
| Package manager         | pnpm                               |

---

# 4. Por que Next.js / React / TypeScript

## Alternativa A — React + SPA + backend separado

Arquitetura:

```text
React SPA
   ↓
Spring/Node API
```

### Benefícios

Boa separação física entre frontend e backend.

### Problemas para este MVP

Exige dois projetos executáveis, dois pipelines de deploy, configuração de CORS, contratos duplicados e mais coordenação entre agentes.

Essa separação física não oferece benefício proporcional para um sistema com apenas uma unidade, cerca de 500 alunos e alguns milhares de registros.

---

## Alternativa B — Next.js full-stack

Arquitetura:

```text
Next.js
 ├── React
 ├── Server Components
 ├── HTTP API
 └── Application modules
```

### Benefícios

- uma linguagem;
- um repositório;
- contratos TypeScript compartilháveis;
- excelente integração com Vercel;
- menos configuração;
- testes mais simples;
- deploy simples;
- agentes conseguem navegar mais facilmente pelo sistema.

O App Router atual do Next.js oferece React Server Components e Route Handlers para implementação de endpoints HTTP dentro da aplicação. ([Next.js](https://nextjs.org/docs/app?utm_source=chatgpt.com "Next.js Docs: App Router | Next.js"))

### Recomendação

**Next.js.**

Mas há uma distinção importante:

> utilizar Next.js full-stack não significa colocar toda regra de negócio em arquivos `route.ts`.

Next.js será apenas a camada de entrega.

O domínio precisa continuar independente:

```text
Route Handler
      ↓
Application Service
      ↓
Domain / Engines
      ↓
Repository
```

---

# 5. Java + Spring Boot vs Node.js / TypeScript

## Java + Spring Boot

Seria uma escolha perfeitamente válida para um backend corporativo maior.

### Benefícios

- maturidade;
- tipagem forte;
- ecossistema corporativo;
- excelente arquitetura em aplicações grandes;
- segurança e observabilidade maduras.

### Custos neste MVP

Criaria:

```text
Next.js frontend
+
Spring Boot backend
+
2 linguagens
+
2 builds
+
2 deploys
+
DTOs duplicados
+
mais infraestrutura
```

Para aproximadamente 500 alunos e alguns milhares de acessos, isso não resolve um problema real do MVP.

Também aumenta a quantidade de contexto que agentes precisam compreender simultaneamente.

### Conclusão

**Não usar Spring Boot no MVP.**

Não porque Java seja inadequado, mas porque sua vantagem aparece quando o backend possui volume, integrações e complexidade organizacional significativamente maiores.

---

## Node.js + TypeScript

No MVP, permite:

```text
React
Next.js
Backend
Schemas
Tests
AI integration
```

todos na mesma linguagem.

### Recomendação

**Node.js + TypeScript.**

---

# 6. Arquitetura: monólito modular

## Alternativa — microservices

Seria possível criar:

```text
dashboard-service
metrics-service
insights-service
ai-service
auth-service
```

Mas isso produziria:

- chamadas de rede internas;
- contratos distribuídos;
- deployments separados;
- autenticação entre serviços;
- mais logs;
- mais tracing;
- mais configuração;
- maior dificuldade para testes.

Sem necessidade atual.

---

## Recomendação

```text
MODULAR MONOLITH
```

Os componentes são separados conceitualmente, mas vivem no mesmo deploy.

Exemplo:

```text
modules/
  auth/
  dashboard/
  members/
  metrics/
  insights/
  copilot/
```

A fronteira entre eles deve existir no código, não na infraestrutura.

### Benefício importante

Se futuramente `copilot` ou `metrics` precisar virar serviço independente, sua fronteira já estará definida.

---

# 7. Frontend

O frontend deve possuir responsabilidade estritamente de apresentação e interação.

## Responsabilidades

```text
renderizar dashboard
renderizar gráficos
selecionar período
mostrar insights
listar alunos
mostrar detalhes do aluno
enviar perguntas ao copiloto
mostrar evidências
mostrar estados de loading/error
```

Não deve calcular indicadores relevantes.

Por exemplo:

Errado:

```text
Frontend:
acessos = ...
percentual = calcular(...)
```

Correto:

```text
GET /api/dashboard?period=7d

{
  totalAccesses,
  attendanceVariation,
  attentionMembers,
  occupancy
}
```

O backend deve devolver dados já semanticamente preparados.

### Server Components

Podem ser utilizados para carga inicial de páginas.

### Client Components

Usar onde existe interação real:

- gráficos;
- filtros;
- seleção de período;
- chat;
- tabelas interativas.

Evitar transformar a aplicação inteira em Client Components.

---

# 8. Backend

O backend terá quatro responsabilidades principais.

```text
HTTP
Application
Domain
Infrastructure
```

## HTTP layer

Responsável por:

- autenticação;
- validação da entrada;
- tradução HTTP;
- serialização;
- códigos de status.

Não contém regra de negócio.

---

## Application layer

Responsável por casos de uso.

Exemplos conceituais:

```text
GetDashboard
GetAttendanceEvolution
GetMemberDetails
GetOperationalInsights
AskCopilot
```

Essa camada coordena os componentes.

---

## Domain

Contém conceitos que representam o problema.

```text
Member
GymUnit
AccessRecord
Period
Metric
OperationalInsight
Evidence
```

Também contém regras puras.

---

## Infrastructure

Responsável por sistemas externos:

```text
Postgres
Supabase
OpenAI
Sentry
```

Assim o domínio não conhece OpenAI, Supabase ou Vercel.

---

# 9. Banco de dados

## Escolha

**PostgreSQL.**

Para este domínio, praticamente todos os dados são relacionais:

```text
GymUnit
User
Member
AccessRecord
Insight
Conversation
Message
```

As consultas principais também são naturalmente relacionais:

```text
COUNT
GROUP BY
DATE
TIME
JOIN
AVG
comparison
```

PostgreSQL é mais apropriado que um banco NoSQL para isso.

---

# 10. Supabase

Supabase faz sentido, mas não como substituto da arquitetura do backend.

Usaremos principalmente:

```text
Supabase
├── PostgreSQL
├── Auth
└── administração operacional
```

Supabase Auth utiliza JWTs e integra autenticação com PostgreSQL/RLS. ([Supabase](https://supabase.com/docs/guides/auth?utm_source=chatgpt.com "Auth | Supabase Docs"))

### Benefício

Evita construir:

- cadastro de usuários;
- armazenamento de senhas;
- reset de senha;
- sessão;
- refresh token.

### Recomendação

**Supabase Auth + Supabase PostgreSQL.**

---

# 11. Browser não acessa diretamente o domínio

Tecnicamente Supabase permite consultas diretamente do browser com RLS.

Para este projeto, não recomendo isso como caminho principal.

Arquitetura desejada:

```text
Browser
   ↓
Application API
   ↓
Domain
   ↓
Repository
   ↓
Supabase/Postgres
```

e não:

```text
Browser
   ↓
Supabase tables
```

### Por quê?

Queremos demonstrar explicitamente:

- backend;
- autorização;
- regras;
- métricas;
- observabilidade;
- arquitetura;
- teste.

A Data API pode continuar existindo, mas o frontend não deve depender diretamente das tabelas de negócio.

---

# 12. Modelo conceitual de dados

Estrutura inicial aproximada:

```text
users
  id
  email
  name

gym_units
  id
  name
  status

user_gym_units
  user_id
  gym_unit_id
  role

members
  id
  gym_unit_id
  name
  status
  joined_at

access_records
  id
  member_id
  gym_unit_id
  accessed_at

operational_insights
  id
  gym_unit_id
  type
  severity
  period_start
  period_end
  evidence_json
  generated_at

ai_conversations
  id
  user_id
  gym_unit_id
  created_at

ai_messages
  id
  conversation_id
  role
  content
  created_at

ai_runs
  id
  conversation_id
  question
  context_snapshot
  evidence_snapshot
  provider
  model
  status
  latency_ms
  created_at
```

A última tabela é especialmente interessante porque atende à auditabilidade definida na especificação: pergunta, contexto, dados utilizados e resposta precisam ser rastreáveis.

---

# 13. Metrics Engine

Este é um dos componentes mais importantes.

## Responsabilidade

Transformar:

```text
dados crus
```

em:

```text
fatos calculados
```

Exemplos:

```text
access_count
active_members
average_attendance
attendance_change_percentage
hourly_distribution
member_frequency_change
days_since_last_visit
```

### Exemplo conceitual

Entrada:

```text
Period:
2026-09-01 → 2026-09-07

Comparison:
2026-08-25 → 2026-08-31
```

Saída:

```text
Current accesses: 1,240
Previous accesses: 1,410
Variation: -12.06%
```

Nenhuma IA participa desse cálculo.

---

# 14. Onde calcular as métricas?

Existem três alternativas.

## A. Tudo em TypeScript

### Vantagem

Fácil de testar.

### Desvantagem

Pode exigir transferência excessiva de registros.

---

## B. Tudo em SQL

### Vantagem

Excelente para agregações.

### Desvantagem

Regras podem ficar espalhadas em queries complexas.

---

## C. Estratégia híbrida

**Recomendada.**

PostgreSQL realiza:

```text
COUNT
SUM
GROUP BY
date grouping
hour grouping
```

A camada de domínio realiza:

```text
comparação
classificação
thresholds
interpretação determinística
```

Assim usamos o banco para aquilo em que ele é excelente sem colocar toda a lógica de negócio em SQL.

---

# 15. Insight Engine

Metrics Engine responde:

> “O que os números são?”

Insight Engine responde:

> “Alguma mudança objetiva merece atenção?”

Ainda sem IA.

Exemplo:

```text
Metric
attendance_change = -14%

Rule
if attendance_change <= -10%

Insight
ATTENDANCE_DROP
```

Outro exemplo:

```text
days_since_visit = 13
historical_frequency = 4 visits/week

↓

PROLONGED_ABSENCE
```

---

# 16. Insights determinísticos

Um insight deve possuir algo semelhante a:

```text
type
severity
period
subject
metric
currentValue
referenceValue
variation
evidence[]
```

Exemplo conceitual:

```text
ATTENDANCE_DROP

period:
last 7 days

current:
1240 accesses

previous:
1410 accesses

variation:
-12%

evidence:
Tuesday -15%
Wednesday -18%
18:00-20:00 -21%
```

Isso permite que o LLM posteriormente descreva a situação sem produzir os números.

---

# 17. Thresholds

No MVP, thresholds devem ser explicitamente configuráveis.

Por exemplo conceitualmente:

```text
attendanceDropThreshold = -10%
memberFrequencyDropThreshold = -40%
prolongedAbsenceDays = 10
```

Não hardcodar valores espalhados pelo sistema.

Criar uma configuração central de regras do MVP.

Isso também facilita demonstração e testes.

---

# 18. AI Architecture

A arquitetura do copiloto não deve ser:

```text
User question
     ↓
LLM
     ↓
Database
```

Isso dá autonomia excessiva ao modelo.

A arquitetura recomendada é:

```text
User Question
     ↓
Intent / Question Classification
     ↓
Application Service
     ↓
Deterministic Data Retrieval
     ↓
Metrics Engine
     ↓
Insight Engine
     ↓
AI Context Builder
     ↓
LLM
     ↓
Structured Answer
     ↓
Evidence validation
     ↓
User
```

O LLM recebe informações prontas.

---

# 19. AI Context Builder

Este componente é crítico.

Ele transforma dados internos em um contrato específico para o LLM.

Exemplo conceitual:

```text
QUESTION
"Por que a frequência caiu?"

UNIT
Academia Demo

PERIOD
últimos 7 dias

FACTS
- accesses_current: 1240
- accesses_previous: 1410
- variation: -12.06%

BREAKDOWN
- Monday: -8%
- Tuesday: -15%
- Wednesday: -18%

TIME_RANGES
- 18h-20h: -21%
- 06h-09h: +2%

KNOWN_LIMITATIONS
- no weather data
- no cancellation reasons
- no marketing data
```

O modelo pode concluir:

> A redução está concentrada principalmente na terça e quarta-feira, especialmente entre 18h e 20h.

Mas não deve concluir:

> Provavelmente choveu e por isso as pessoas faltaram.

porque não existe evidência.

---

# 20. LLM Gateway

Nunca chamar o SDK do provedor diretamente a partir dos casos de uso.

Criar uma abstração:

```textLLMGateway
```

Responsável por:

- enviar prompt;
- selecionar modelo;
- aplicar timeout;
- controlar tokens;
- registrar duração;
- registrar falhas;
- validar resposta;
- mapear erro do fornecedor.

Isso evita espalhar dependência do fornecedor.

---

# 21. Resposta estruturada

Para o copiloto, recomendo que internamente o LLM gere estrutura, e não apenas uma string.

Por exemplo:

```text
answer
evidenceIds[]
limitations[]
confidenceBasis
followUpQuestions[]
```

O frontend pode então renderizar:

```text
Resposta

Evidências utilizadas

Limitações

Perguntas sugeridas
```

APIs atuais da OpenAI suportam Structured Outputs com JSON Schema, permitindo exigir formatos de resposta estruturados. ([Plataforma OpenAI](https://platform.openai.com/docs/api-reference/responses-streaming/response/refusal?lang=python\&utm_source=chatgpt.com "Streaming events | OpenAI API Reference"))

Isso melhora bastante:

- validação;
- testes;
- rastreabilidade;
- renderização;
- avaliação da IA.

---

# 22. RAG não é necessário inicialmente

Não recomendo introduzir:

```text
embeddings
vector database
pgvector
document retrieval
```

no MVP.

Nosso problema possui dados estruturados.

A solução natural é:

```text
question
→ deterministic query
→ structured context
→ LLM
```

e não:

```text
question
→ embedding
→ vector similarity
```

Vector search deve ser adicionado apenas se futuramente houver documentos não estruturados.

---

# 23. Autenticação

## Recomendação

**Supabase Auth.**

Inicialmente:

```text
email
+
password
```

já é suficiente.

Não há necessidade de:

- OAuth;
- SSO;
- MFA;
- login social;

para a demonstração.

---

# 24. Autorização

Autenticação responde:

```text
Quem é você?
```

Autorização responde:

```text
Que unidade você pode consultar?
```

Mesmo com apenas uma unidade no MVP, devemos modelar:

```text
user_gym_units
```

Assim já existe uma fronteira de segurança correta.

A regra fundamental será:

```text
user
  ↓
membership
  ↓
gym_unit
```

Qualquer consulta operacional deve possuir `gym_unit_id`.

---

# 25. Isolamento de dados

Recomendo dois níveis.

## Nível 1 — Application Layer

Toda consulta recebe:

```text
authenticatedUser
+
gymUnitId
```

e verifica associação.

## Nível 2 — PostgreSQL RLS

As tabelas operacionais possuem políticas de isolamento.

Supabase recomenda RLS como mecanismo de autorização em nível de linha e alerta que chaves privilegiadas capazes de ignorar RLS nunca devem chegar ao browser. ([Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security?utm_source=chatgpt.com "Row Level Security | Supabase Docs"))

Isso cria:

```text
defense in depth
```

Mesmo que uma consulta seja construída incorretamente, há uma segunda barreira.

---

# 26. Service Role

Usar chave privilegiada somente para tarefas administrativas claramente controladas.

Exemplos:

```text
seed do dataset
maintenance
test fixtures
```

Não usar service role para requests normais do usuário quando uma sessão autenticada puder preservar RLS.

A documentação do Supabase deixa explícito que credenciais de service role podem ignorar RLS e devem permanecer exclusivamente server-side. ([Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security?utm_source=chatgpt.com "Row Level Security | Supabase Docs"))

---

# 27. AI Security Boundary

A IA deve receber apenas informações que passaram anteriormente por autorização.

Nunca:

```text
LLM decide qual gym_unit consultar.
```

Sempre:

```text
authenticated user
      ↓
authorized gym unit
      ↓
backend queries
      ↓
authorized facts
      ↓
AI context
```

Assim a IA jamais atua como mecanismo de segurança.

---

# 28. Prompt injection

Como o dataset do MVP é sintético e estruturado, o risco inicial é menor que em um sistema que ingere documentos externos.

Mesmo assim:

- instruções do usuário devem ser tratadas como input;
- dados devem ser tratados como dados;
- contexto não deve conter segredos;
- nenhuma ferramenta administrativa deve estar disponível ao LLM;
- o LLM não recebe credenciais;
- o LLM não executa SQL livre.

---

# 29. Não permitir Text-to-SQL livre no MVP

Uma arquitetura possível seria:

```text
User question
→ LLM generates SQL
→ SQL executes
```

Não recomendo.

Problemas:

- autorização;
- SQL inválido;
- queries caras;
- comportamento imprevisível;
- prompt injection;
- dificuldade de testes.

Para o MVP:

```text
question
→ predefined analysis capability
→ deterministic query
```

O copiloto pode escolher entre capacidades controladas como:

```text
unit_overview
attendance_change
member_frequency
occupancy_distribution
attention_signals
```

Isso mantém poder suficiente para a demonstração sem entregar o banco ao modelo.

---

# 30. Fluxo solicitado

Fluxo arquitetural principal:

```text
Browser
   ↓
Frontend
   ↓
API
   ↓
Domain/Application
   ↓
Database
   ↓
Metrics Engine
   ↓
Insight Engine
   ↓
AI Context Builder
   ↓
LLM
   ↓
Response with Evidence
```

Uma observação importante:

fisicamente algumas etapas podem ocorrer em ordem diferente.

Por exemplo:

```text
Application
   ↓
Database
   ↓
Metrics Engine
```

ou determinadas métricas podem utilizar agregações diretamente no banco.

O fluxo representa responsabilidades, não necessariamente uma pipeline de rede.

---

# 31. Data Flow — Dashboard

```text
Browser
   │
   │ GET /api/dashboard?period=7d
   ▼
API
   │
   │ validate request
   │ authenticate
   ▼
Application
   │
   │ authorize unit
   ▼
Repository
   │
   ▼
PostgreSQL
   │
   │ access records + members
   ▼
Metrics Engine
   │
   ├── active members
   ├── total accesses
   ├── previous-period comparison
   ├── hourly occupancy
   └── frequency changes
   │
   ▼
Insight Engine
   │
   ├── attendance drop
   ├── low occupancy
   └── member frequency reduction
   │
   ▼
Dashboard DTO
   │
   ▼
Frontend
```

---

# 32. AI Data Flow

Pergunta:

> “Por que a frequência caiu esta semana?”

```text
Browser
   │
   │ POST /api/copilot/messages
   ▼
Authentication
   │
   ▼
Authorization
   │
   ▼
Copilot Application Service
   │
   ▼
Question classifier
   │
   └── attendance_change
   │
   ▼
Metrics Engine
   │
   ├── total change
   ├── daily breakdown
   └── hourly breakdown
   │
   ▼
Insight Engine
   │
   └── relevant deterministic signals
   │
   ▼
AI Context Builder
   │
   └── authorized structured facts
   │
   ▼
LLM Gateway
   │
   ▼
LLM
   │
   ▼
Structured Response
   │
   ├── answer
   ├── evidence references
   └── limitations
   │
   ▼
Response Validator
   │
   ▼
Audit Record
   │
   ▼
Frontend
```

---

# 33. Evidence architecture

Cada evidência deve possuir um identificador interno.

Exemplo:

```text
E1
attendance_change = -12.06%

E2
Tuesday = -15%

E3
Wednesday = -18%

E4
18h-20h = -21%
```

O LLM retorna:

```text
evidence:
E1
E2
E3
E4
```

O backend verifica:

```text
esses IDs realmente estavam no contexto?
```

Se o modelo referenciar `E99`, a resposta deve ser considerada inválida ou parcialmente inválida.

Essa abordagem torna a explicabilidade tecnicamente demonstrável.

---

# 34. Tratamento de dados insuficientes

O backend pode informar ao modelo:

```text
available evidence:
frequency

unavailable evidence:
weather
campaigns
cancellations
payments
```

Assim, se o usuário perguntar:

> “A frequência caiu porque aumentamos o preço?”

o sistema pode responder:

> Não existem dados de preços disponíveis para estabelecer essa relação.

Esse comportamento atende diretamente ao requisito de que o copiloto declare ausência de evidências em vez de inventar explicações.

---

# 35. Observabilidade

Precisamos observar duas categorias diferentes.

## Software

Registrar:

```text
request_id
endpoint
status
latency
user_id
gym_unit_id
error_type
```

Sem registrar tokens ou credenciais.

---

## IA

Registrar:

```text
ai_run_id
conversation_id
question
context version
evidence IDs
model
latency
token usage
status
error category
```

E, para ambiente de demonstração, pode ser útil armazenar o snapshot estruturado do contexto.

Isso permite responder posteriormente:

> “Por que a IA disse isso?”

---

# 36. Sentry

Para MVP, recomendo:

```text
Sentry
+
structured application logs
```

em vez de construir uma stack completa:

```text
OpenTelemetry
Prometheus
Grafana
Loki
Tempo
```

Essa stack seria tecnicamente interessante, mas totalmente desproporcional ao MVP.

OpenTelemetry pode entrar futuramente.

---

# 37. Tratamento de erros

Criar erros de domínio explícitos.

Exemplos conceituais:

```text
AuthenticationError
AuthorizationError
ValidationError
ResourceNotFoundError
InsufficientDataError
AIProviderError
AIResponseValidationError
DatabaseError
```

Eles serão traduzidos para respostas HTTP.

---

# 38. Falha da IA

A IA deve ser um subsistema opcional.

Arquitetura:

```text
Dashboard
 ├── Database
 ├── Metrics
 └── Insights

Copilot
 └── LLM
```

e nunca:

```text
Dashboard
   ↓
LLM
```

Assim:

```text
LLM indisponível
```

não afeta:

```text
dashboard
metrics
insights
members
charts
```

Isso atende explicitamente ao requisito de resiliência da IA.

---

# 39. Failure Strategy

### Banco indisponível

```text
Dashboard:
erro controlado

Copilot:
indisponível
```

### LLM indisponível

```text
Dashboard:
funciona normalmente

Insight Engine:
funciona normalmente

Copilot:
"Copiloto temporariamente indisponível"
```

### Timeout do LLM

Interromper request e retornar erro controlado.

Não fazer retries agressivos durante request interativo.

### Resposta inválida do LLM

```text
schema validation fails
→ discard
→ safe fallback
```

### Dados insuficientes

Não é erro de sistema.

É uma resposta de domínio:

```text
insufficient evidence
```

---

# 40. Serverless

Vercel Functions são adequadas ao MVP.

A documentação atual suporta Node.js como runtime de Functions, inclusive TypeScript, e a própria Vercel posiciona Functions para workloads HTTP/I/O e integrações com APIs e bancos. ([Vercel](https://vercel.com/docs/functions/runtimes?utm_source=chatgpt.com "Runtimes"))

O workload deste projeto é predominantemente:

```text
HTTP
SQL
LLM API
```

e portanto combina bem com serverless.

---

# 41. O que não colocar em serverless

Não devemos criar jobs pesados ou pipelines analíticos longos no MVP.

Com aproximadamente:

```text
500 alunos
6 meses
milhares de acessos
```

as métricas podem ser calculadas sob demanda.

Nenhuma infraestrutura como:

```text
Kafka
RabbitMQ
Redis queues
Spark
Airflow
```

é necessária.

---

# 42. Cache

Inicialmente:

**nenhum cache distribuído.**

As queries são pequenas.

Se necessário posteriormente:

```text
Next.js cache
ou
Redis
```

Mas cache antes de evidência de performance ruim criaria complexidade desnecessária.

---

# 43. Deployment Model

```text
GitHub
   │
   ├── pull request
   │       ↓
   │   automated tests
   │       ↓
   │   Vercel Preview
   │
   └── main
           ↓
      Vercel Production
           │
           ├── Next.js frontend
           └── Node.js API functions

Supabase
   ├── PostgreSQL
   └── Auth

OpenAI
   └── external LLM API

Sentry
   └── monitoring
```

---

# 44. Ambientes

Recomendo inicialmente:

```text
local
preview
production
```

Não é necessário criar um ambiente permanente de staging para o MVP.

### Local

```text
local app
Supabase local ou development project
```

### Preview

Cada Pull Request:

```text
Vercel Preview Deployment
```

### Production

Branch:

```text
main
```

---

# 45. Região

As Functions devem executar preferencialmente próximas do banco, pois a própria documentação da Vercel recomenda proximidade entre Functions e fonte de dados para reduzir latência. ([Vercel](https://vercel.com/docs/functions/configuring-functions?utm_source=chatgpt.com "Configuring Functions"))

Logo, ao criar Supabase e Vercel, devemos escolher regiões compatíveis ou próximas.

---

# 46. Repository Structure Proposal

Sugestão:

```text
ai-fitness-operations-copilot/

├── .github/
│   └── workflows/
│
├── docs/
│   ├── product/
│   ├── architecture/
│   ├── adr/
│   ├── ai/
│   └── security/
│
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   ├── (dashboard)/
│   │   ├── api/
│   │   └── layout.tsx
│   │
│   ├── components/
│   │
│   ├── modules/
│   │   ├── auth/
│   │   ├── units/
│   │   ├── members/
│   │   ├── attendance/
│   │   ├── metrics/
│   │   ├── insights/
│   │   └── copilot/
│   │
│   ├── shared/
│   │   ├── errors/
│   │   ├── validation/
│   │   ├── logging/
│   │   └── types/
│   │
│   └── infrastructure/
│       ├── database/
│       ├── supabase/
│       ├── ai/
│       └── observability/
│
├── supabase/
│   ├── migrations/
│   ├── seed/
│   └── tests/
│
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── ai-evals/
│
├── scripts/
│   └── dataset/
│
├── package.json
├── pnpm-lock.yaml
└── README.md
```

---

# 47. Organização interna de módulo

Cada módulo importante pode seguir:

```text
metrics/
├── domain/
├── application/
├── infrastructure/
└── index.ts
```

Mas não aplicar essa estrutura rigidamente a módulos pequenos.

Evitar criar arquivos vazios apenas para “seguir Clean Architecture”.

A regra deve ser:

> arquitetura deve separar responsabilidades, não multiplicar pastas.

---

# 48. Arquitetura amigável para agentes de IA

O repositório será produzido principalmente com auxílio de agentes.

Isso altera algumas decisões.

Precisamos privilegiar:

```text
convenções explícitas
módulos pequenos
tipos claros
arquivos previsíveis
testes próximos às regras
documentação arquitetural
contratos estruturados
```

Evitar:

```text
metaprogramação
mágica
reflexão
configuração implícita
abstrações genéricas excessivas
```

Quanto mais explícita a arquitetura, mais facilmente um agente consegue modificar apenas a área correta.

---

# 49. Documentação para agentes

Adicionar:

```text
AGENTS.md
```

ou instruções equivalentes na raiz.

Deve explicar:

```text
arquitetura
comandos
padrões
regras
testes obrigatórios
fronteiras dos módulos
regras de segurança
regra "software calcula / IA interpreta"
```

Além disso:

```text
docs/architecture/
docs/adr/```

funcionam como memória técnica do projeto.

---

# 50. Estratégia de testes

## Unit tests

Principal prioridade.

Especialmente para:

```text
metrics
insight rules
period comparison
frequency calculations
evidence generation
```

As funções devem ser predominantemente puras.

---

## Integration tests

Testar:

```text
repositories
database
auth boundaries
RLS
API endpoints
```

Supabase atualmente recomenda testar as próprias políticas RLS e fornece suporte para testes de banco nesse fluxo. ([Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security?utm_source=chatgpt.com "Row Level Security | Supabase Docs"))

---

## E2E

Playwright deverá testar fluxos essenciais:

```text
login
dashboard
troca de período
aluno
insight
copilot
LLM failure
```

---

# 51. Testes da IA

Não tratar teste do copiloto como:

```text
expectedText === actualText
```

Criar avaliações baseadas em propriedades.

Exemplos:

```text
resposta possui evidência?
cita apenas evidências fornecidas?
inventou causa não disponível?
reconhece dados insuficientes?
preserva valores calculados?
```

Assim o projeto demonstra AI engineering, e não apenas API integration.

---

# 52. Dataset

O dataset sintético deve ser reproduzível.

Recomendo:

```text
fixed random seed
+
scenario definitions
```

Exemplo:

```text
baseline attendance
weekend variation
evening peak
controlled attendance drop
members with progressive decline
members with prolonged absence
```

Isso permite:

```text
dataset
→ expected metrics
→ expected insights
```

e portanto testes automatizados muito convincentes.

---

# 53. Segurança

Principais fronteiras:

```text
Internet
   │
   ▼
Vercel / HTTPS
   │
   ▼
Authentication
   │
   ▼
Authorization
   │
   ▼
Application
   │
   ▼
RLS
   │
   ▼
Database
```

Para IA:

```text
Authorized Data
   │
   ▼
Context Builder
   │
   ▼
LLM Provider
```

Nunca:

```text
LLM
 ↓
secret
```

ou:

```text
Browser
 ↓
service_role
```

---

# 54. Security Boundaries

## Boundary 1 — Browser / Server

Segredos nunca cruzam para o browser.

## Boundary 2 — Authenticated / Anonymous

APIs operacionais exigem sessão.

## Boundary 3 — User / Gym Unit

Usuário acessa somente unidades autorizadas.

## Boundary 4 — Application / Database

Aplicação acessa apenas dados necessários ao caso de uso.

## Boundary 5 — Application / LLM

Somente contexto autorizado e minimizado é enviado.

## Boundary 6 — LLM / System

LLM não recebe acesso irrestrito a banco, autenticação ou infraestrutura.

---

# 55. Component Responsibilities

| ComponenteResponsabilidade |                                           |
| -------------------------- | ----------------------------------------- |
| Frontend                   | apresentação e interação                  |
| API                        | transporte HTTP, validação e autenticação |
| Application                | coordenação de casos de uso               |
| Domain                     | regras e conceitos                        |
| Repository                 | acesso abstrato aos dados                 |
| PostgreSQL                 | fonte da verdade                          |
| Metrics Engine             | fatos quantitativos                       |
| Insight Engine             | sinais determinísticos                    |
| Context Builder            | preparar contexto autorizado              |
| LLM Gateway                | integração com fornecedor                 |
| LLM                        | interpretação e síntese                   |
| Evidence Validator         | impedir referências inexistentes          |
| Audit Layer                | rastreabilidade                           |
| Observability              | erros, logs e performance                 |

---

# 56. Architectural Risks

## Risco 1 — Next.js virar “massa única”

Se UI, SQL, IA e regras forem colocados diretamente em pages/routes, teremos um monólito acoplado.

### Mitigação

Module boundaries explícitas.

---

## Risco 2 — IA começar a calcular métricas

É tentador mandar registros crus e pedir:

> “analise isso”.

### Mitigação

LLM recebe fatos calculados.

---

## Risco 3 — Copiloto virar Text-to-SQL

Isso aumenta drasticamente segurança e imprevisibilidade.

### Mitigação

Capacidades analíticas controladas.

---

## Risco 4 — RLS configurada incorretamente

RLS adiciona proteção, mas política errada também pode bloquear ou expor dados.

### Mitigação

Testes explícitos de allow/deny.

---

## Risco 5 — dataset sintético pouco convincente

Se totalmente aleatório, os insights parecerão artificiais.

### Mitigação

Cenários determinísticos e anomalias planejadas.

---

## Risco 6 — Dependência excessiva do provedor de IA

### Mitigação

`LLMGateway`.

---

## Risco 7 — overengineering

É o maior risco arquitetural deste MVP.

Evitar inicialmente:

```text
microservices
Kubernetes
event bus
Redis
vector database
CQRS
event sourcing
GraphQL
Kafka
background workers
multi-region
custom auth
ML prediction pipeline
```

Nenhum desses componentes resolve um requisito atual.

---

# 57. Architecture Decision Records iniciais

## ADR-001 — Modular Monolith

**Status:** Accepted

### Decision

Utilizar monólito modular.

### Alternatives

Microservices.

### Reason

O domínio e a escala não justificam comunicação distribuída.

### Consequence

Deployment simples, mantendo fronteiras conceituais que permitem extração futura.

---

## ADR-002 — TypeScript end-to-end

**Status:** Accepted

### Decision

Frontend e backend utilizarão TypeScript.

### Alternatives

TypeScript + Java/Spring.

### Reason

Menor complexidade operacional e maior compartilhamento de tipos e conhecimento entre agentes.

---

## ADR-003 — Next.js App Router

**Status:** Accepted

### Decision

Next.js será framework web principal.

### Reason

Permite React, server rendering e endpoints HTTP no mesmo projeto e integra naturalmente com Vercel. Route Handlers são suporte nativo do App Router. ([Next.js](https://nextjs.org/docs/app/getting-started/route-handlers?utm_source=chatgpt.com "Getting Started: Route Handlers | Next.js"))

---

## ADR-004 — PostgreSQL

**Status:** Accepted

### Decision

PostgreSQL será a fonte da verdade.

### Reason

O domínio é relacional e altamente orientado a agregações temporais.

---

## ADR-005 — Supabase

**Status:** Accepted

### Decision

Supabase fornecerá PostgreSQL e autenticação.

### Reason

Reduz infraestrutura sem esconder o banco relacional subjacente.

---

## ADR-006 — Software calculates, AI interprets

**Status:** Accepted — Architectural Principle

### Decision

LLM nunca será responsável pelo cálculo primário de métricas.

### Reason

Determinismo, testabilidade, explicabilidade e confiabilidade.

Esta decisão deriva diretamente dos princípios já estabelecidos no produto.

---

## ADR-007 — Controlled AI Data Access

**Status:** Accepted

### Decision

LLM não terá acesso SQL livre.

### Alternatives

Text-to-SQL.

### Reason

Menor superfície de segurança e comportamento mais previsível.

---

## ADR-008 — Structured AI Responses

**Status:** Accepted

### Decision

Respostas internas do copiloto usarão schema estruturado.

### Reason

Permite validar evidências, limitações e formato antes de apresentar o resultado.

---

## ADR-009 — No Vector Database

**Status:** Accepted

### Decision

Não usar embeddings ou vector database no MVP.

### Reason

O conhecimento consultado é estruturado e relacional.

---

## ADR-010 — Vercel Serverless Deployment

**Status:** Accepted

### Decision

Frontend e APIs Next.js serão implantados inicialmente na Vercel.

### Reason

Baixa complexidade operacional e integração direta com GitHub/Next.js.

---

## ADR-011 — RLS as Defense in Depth

**Status:** Accepted

### Decision

Autorização será validada pela aplicação e reforçada por RLS.

### Reason

Reduzir o impacto de erros de consulta ou autorização.

---

## ADR-012 — AI Failure Isolation

**Status:** Accepted

### Decision

Falhas do LLM não impactam dashboard, métricas ou insights determinísticos.

### Reason

IA é uma camada de interpretação, não infraestrutura crítica do produto.

---

# 58. Decisão final sobre as tecnologias avaliadas

### Next.js / React / TypeScript

**Usar.**

É a combinação mais coerente para frontend + backend desse MVP.

### Java + Spring Boot

**Não usar no MVP.**

Tecnicamente adequado, arquiteturalmente desnecessário neste estágio.

### Node.js / TypeScript

**Usar.**

Backend do MVP.

### PostgreSQL

**Usar.**

Banco principal.

### Supabase

**Usar seletivamente.**

Principalmente:

```text
PostgreSQL
Auth
RLS
```

Não deixar Supabase substituir as camadas de domínio e aplicação.

### Serviços serverless

**Usar.**

Adequados ao volume e às características HTTP/I/O do MVP.

### Arquitetura monolítica modular

**Usar.**

É provavelmente a decisão estrutural mais importante do projeto.

---

# 59. Arquitetura final recomendada

```text
                     AI FITNESS OPERATIONS COPILOT

┌─────────────────────────────────────────────────────────────┐
│                          Browser                            │
│                                                             │
│ Dashboard │ Members │ Insights │ Copilot                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Next.js / Vercel                           │
│                                                             │
│ React UI                                                    │
│ Route Handlers                                              │
│ Authentication handling                                     │
│ Validation                                                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               Modular Application Layer                     │
│                                                             │
│ Dashboard │ Attendance │ Members │ Insights │ Copilot      │
└───────────┬─────────────┬──────────┬────────────────────────┘
            │             │          │
            ▼             ▼          ▼
       Repository    Metrics      Insight
         Layer       Engine       Engine
            │             │          │
            └─────────────┼──────────┘
                          ▼
                ┌──────────────────┐
                │    PostgreSQL    │
                │     Supabase     │
                └──────────────────┘

                          │
                    Copilot only
                          │
                          ▼
                ┌──────────────────┐
                │ AI Context       │
                │ Builder          │
                └────────┬─────────┘
                         ▼
                ┌──────────────────┐
                │ LLM Gateway      │
                └────────┬─────────┘
                         ▼
                ┌──────────────────┐
                │ LLM Provider     │
                └────────┬─────────┘
                         ▼
                ┌──────────────────┐
                │ Evidence         │
                │ Validation       │
                └────────┬─────────┘
                         ▼
                       User
```

---

# 60. Architecture Summary

A arquitetura proposta deliberadamente não tenta antecipar a arquitetura de uma plataforma fitness completa.

Ela otimiza para o problema real do MVP:

```text
dataset estruturado
      ↓
métricas confiáveis
      ↓
mudanças detectadas
      ↓
evidências
      ↓
interpretação por IA
      ↓
investigação pelo gestor
```

A divisão fundamental fica:

```text
PostgreSQL
     ↓
source of truth

Metrics Engine
     ↓
what happened?

Insight Engine
     ↓
what deserves attention?

AI Context Builder
     ↓
what facts can the AI see?

LLM
     ↓
how can these facts be explained?

Evidence Validator
     ↓
is the explanation grounded?

Frontend
     ↓
how does the manager investigate it?
```

Isso preserva exatamente o diferencial do produto:

> **observar → detectar → investigar → compreender**.

E mantém a regra arquitetural mais importante do projeto:

> **O software calcula fatos.**
> **A IA interpreta fatos.**

A decisão que eu congelaria para começarmos a implementação é, portanto: **Next.js + React + TypeScript, monólito modular, PostgreSQL/Supabase, Supabase Auth + RLS, Vercel, OpenAI via gateway server-side, métricas e insights determinísticos, e nenhuma infraestrutura adicional até existir um requisito concreto para ela.** Isso nos dá complexidade suficiente para demonstrar arquitetura profissional sem transformar o MVP em uma demonstração de infraestrutura.
