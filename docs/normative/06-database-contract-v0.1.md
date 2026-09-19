# AI Fitness Operations Copilot

## Database Contract — v0.1

**Status:** Normative
**Target:** PostgreSQL / Supabase
**Purpose:** definir integralmente o contrato relacional do MVP antes da geração de migrations.

---

# 1. Database Contract Summary

Este documento congela o contrato de banco do MVP.

Uma migration futura deverá ser uma **tradução deste contrato**, não uma nova etapa de modelagem.

## 1.1 Princípios obrigatórios

1. PostgreSQL é o **source of truth operacional**.
2. Supabase Auth é o **source of truth de autenticação**.
3. `app_users.id` reutiliza `auth.users.id`.
4. Todo dado operacional tenant-scoped possui `gym_unit_id`.
5. `gym_unit_id` participa de constraints relacionais sempre que necessário para impedir cross-tenant references.
6. RLS funciona como **defense in depth**, não como substituto da autorização da Application Layer.
7. `access_records` representa fatos históricos.
8. Métricas não são persistidas no MVP.
9. `operational_insights` contém snapshots derivados e reproduzíveis, nunca a realidade operacional canônica.
10. `ai_runs` contém a trilha de auditoria das execuções do Copilot.
11. JSONB é permitido somente para snapshots flexíveis e versionados.
12. Regras do Insight Engine permanecem versionadas na aplicação.
13. O dataset sintético deve ser determinístico.
14. Timestamps operacionais são armazenados como `TIMESTAMPTZ`.
15. Períodos analíticos usam semântica half-open: `[start, end)`.

O modelo aprovado já determina explicitamente que métricas não devem virar tabela persistida, que todo dado operacional deve ser identificável pela unidade e que o dataset deve continuar pequeno e relacional.

## 1.2 Tabelas do MVP

Exatamente:

- `app_users`
- `gym_units`
- `user_gym_units`
- `members`
- `access_records`
- `operational_insights`
- `ai_conversations`
- `ai_messages`
- `ai_runs`

Não criar no MVP:

- `attendance_metrics`;
- `ai_analysis_contexts`;
- `insight_rule_configs`;
- tabelas de planos;
- contratos;
- pagamentos;
- CRM;
- embeddings;
- documentos;
- vetores;
- classificações sintéticas de comportamento.

---

# 2. Global Database Conventions

## 2.1 Identificadores

Todas as entidades principais usam `UUID`.

Para tabelas criadas pela aplicação, o default deverá ser UUID gerado pelo PostgreSQL.

Exceção:

`app_users.id` não gera um novo UUID. Ele deve ser exatamente igual ao UUID correspondente em `auth.users.id`.

## 2.2 Timestamps

Todo instante temporal deve usar:

`TIMESTAMPTZ`

Não utilizar `TIMESTAMP WITHOUT TIME ZONE` para fatos operacionais ou auditáveis.

Convenção:

- `created_at`: instante de criação;
- `updated_at`: última alteração mutável;
- `deleted_at`: remoção lógica;
- `deactivated_at`: encerramento temporal de atividade do membro;
- `voided_at`: anulação de fato histórico;
- `detected_at`: instante de detecção do insight;
- `resolved_at`: instante de resolução do insight;
- `started_at`: início de execução AI;
- `completed_at`: término da execução AI.

Defaults de criação devem representar o instante atual do banco.

`updated_at` deve ser mantido automaticamente pelo banco nas tabelas em que estiver presente.

## 2.3 Strings

Identificadores técnicos versionados como:

- `rule_code`;
- `rule_version`;
- `prompt_version`;
- `context_schema_version`;
- `response_schema_version`;
- `provider`;
- `model`;
- `intent`;
- `error_code`;

devem ser colunas relacionais, não propriedades escondidas em JSONB.

## 2.4 ENUM strategy

Os enums abaixo são **enums de domínio**, porém devem ser implementados no MVP usando:

`TEXT/VARCHAR + CHECK`

e não PostgreSQL native ENUM.

### Justificativa

Os valores são fechados pelo contrato, mas alguns poderão evoluir durante o desenvolvimento do MVP.

`CHECK + text`:

- mantém validação no banco;
- facilita evolução por migration;
- evita dependência forte do lifecycle de PostgreSQL ENUM;
- continua simples para TypeScript/Zod;
- não reduz integridade.

Nenhum agente poderá adicionar um valor novo sem atualizar este contrato.

---

# 3. Table Contracts

# 3.1 `app_users`

## Propósito

Perfil da aplicação associado 1:1 a um usuário autenticável do Supabase Auth.

Credenciais continuam exclusivamente em `auth.users`.

## Colunas

| ColunaTipoNullDefaultRegra |              |     |                   |                                 |
| -------------------------- | ------------ | --- | ----------------- | ------------------------------- |
| `id`                       | UUID         | NO  | nenhum            | PK e FK para `auth.users.id`    |
| `display_name`             | VARCHAR(120) | NO  | nenhum            | nome apresentado pela aplicação |
| `status`                   | TEXT         | NO  | `ACTIVE`          | `user_status`                   |
| `created_at`               | TIMESTAMPTZ  | NO  | current timestamp | criação                         |
| `updated_at`               | TIMESTAMPTZ  | NO  | current timestamp | manutenção automática           |
| `deleted_at`               | TIMESTAMPTZ  | YES | NULL              | soft delete                     |

## Primary Key

`id`

## Foreign Keys

`id → auth.users.id`

Delete behavior: `RESTRICT/NO ACTION`.

A exclusão física do Auth User não faz parte do fluxo normal. Primeiro deve ocorrer desativação lógica.

## Unique Constraints

Nenhuma além da PK.

O e-mail não deve ser duplicado aqui apenas para criar uma segunda fonte de verdade.

## Check Constraints

- `display_name` não vazio;
- `deleted_at IS NULL` ou `status = INACTIVE`;
- `updated_at >= created_at`.

## Indexes

Somente PK.

## Tenant Key

Não possui `gym_unit_id`.

A associação tenant ocorre por `user_gym_units`.

## Update/Delete

Pode alterar:

- `display_name`;
- `status`;
- `updated_at`;
- `deleted_at`.

Hard delete proibido em operação normal.

## NÃO deve conter

- senha;
- password hash;
- refresh token;
- JWT;
- permissões por unidade;
- lista JSON de unidades;
- role global do usuário;
- dados de métricas.

---

# 3.2 `gym_units`

## Propósito

Representar uma unidade operacional da academia.

A unidade continua explícita mesmo com apenas uma unidade no MVP porque é a raiz de tenancy.

## Colunas

| ColunaTipoNullDefault |              |     |                     |
| --------------------- | ------------ | --- | ------------------- |
| `id`                  | UUID         | NO  | UUID gerado pelo DB |
| `name`                | VARCHAR(150) | NO  | —                   |
| `code`                | VARCHAR(40)  | NO  | —                   |
| `timezone`            | VARCHAR(64)  | NO  | —                   |
| `status`              | TEXT         | NO  | `ACTIVE`            |
| `created_at`          | TIMESTAMPTZ  | NO  | current timestamp   |
| `updated_at`          | TIMESTAMPTZ  | NO  | current timestamp   |
| `deleted_at`          | TIMESTAMPTZ  | YES | NULL                |

## Primary Key

`id`

## Unique Constraints

`UNIQUE(code)`

## Foreign Keys

Nenhuma.

## Check Constraints

- `name` não vazio;
- `code` não vazio;
- `timezone` não vazio;
- status válido;
- deleted implica `status = INACTIVE`;
- `updated_at >= created_at`.

A validade como IANA timezone deverá ser validada pela Application Layer contra timezones reconhecidos pelo PostgreSQL/runtime.

## Tenant Key

`id` é a raiz do tenant.

## Indexes

- PK;
- unique index de `code`.

Nenhum outro inicialmente.

## Delete

Hard delete proibido em produção quando houver qualquer dado dependente.

## NÃO deve conter

- métricas;
- thresholds de insights;
- configurações do LLM;
- membros em JSON;
- permissões de usuários em JSON.

A especificação já exige timezone explícito da unidade porque agrupamentos por dia, hora e weekday devem acontecer no horário local.

---

# 3.3 `user_gym_units`

## Propósito

Materializar autorização User ↔ GymUnit.

## Colunas

| ColunaTipoNullDefault |             |    |                   |
| --------------------- | ----------- | -- | ----------------- |
| `user_id`             | UUID        | NO | —                 |
| `gym_unit_id`         | UUID        | NO | —                 |
| `role`                | TEXT        | NO | —                 |
| `status`              | TEXT        | NO | `ACTIVE`          |
| `created_at`          | TIMESTAMPTZ | NO | current timestamp |
| `updated_at`          | TIMESTAMPTZ | NO | current timestamp |

`updated_at` é um refinamento normativo deste contrato porque role e status podem mudar.

## Primary Key

Composta:

`(user_id, gym_unit_id)`

## Foreign Keys

- `user_id → app_users.id`
- `gym_unit_id → gym_units.id`

Ambas com hard delete restrito.

## Unique Constraints

A própria PK impede associações duplicadas.

## Check Constraints

- role válida;
- status válido;
- `updated_at >= created_at`.

## Tenant Key

`gym_unit_id`

## Indexes

A PK `(user_id, gym_unit_id)` é suficiente para o principal lookup de autorização:

authenticated user + requested unit.

Não criar índice invertido inicialmente.

## Delete

Não remover membership para representar perda de acesso.

Preferir:

`status = INACTIVE`.

Hard delete somente para correção administrativa/test fixtures.

## NÃO deve conter

- regras de negócio;
- array de permissões;
- dados de membros;
- métricas;
- permissões definidas pelo LLM.

---

# 3.4 `members`

## Propósito

Representar um aluno pertencente a exatamente uma GymUnit.

## Colunas

| ColunaTipoNullDefault |              |     |                   |
| --------------------- | ------------ | --- | ----------------- |
| `id`                  | UUID         | NO  | UUID DB           |
| `gym_unit_id`         | UUID         | NO  | —                 |
| `member_code`         | VARCHAR(32)  | NO  | —                 |
| `display_name`        | VARCHAR(120) | NO  | —                 |
| `status`              | TEXT         | NO  | `ACTIVE`          |
| `joined_at`           | TIMESTAMPTZ  | NO  | —                 |
| `deactivated_at`      | TIMESTAMPTZ  | YES | NULL              |
| `created_at`          | TIMESTAMPTZ  | NO  | current timestamp |
| `updated_at`          | TIMESTAMPTZ  | NO  | current timestamp |
| `deleted_at`          | TIMESTAMPTZ  | YES | NULL              |

## Primary Key

`id`

## Foreign Keys

`gym_unit_id → gym_units.id`

Delete restricted.

## Unique Constraints

1. `(gym_unit_id, member_code)`
2. `(id, gym_unit_id)`

A segunda existe expressamente para permitir FKs compostas tenant-safe.

## Check Constraints

- `member_code` não vazio;
- `display_name` não vazio;
- `deactivated_at IS NULL OR deactivated_at >= joined_at`;
- se `status = ACTIVE`, `deactivated_at` deve ser NULL;
- se `deactivated_at IS NOT NULL`, status deve ser `INACTIVE`;
- deleted implica status `INACTIVE`;
- `updated_at >= created_at`.

## Tenant Key

`gym_unit_id`

## Indexes

Obrigatório:

`(gym_unit_id, status)`

Uso:

- lista de alunos;
- conjunto atual de ativos;
- filtros do dashboard.

Não criar inicialmente índices separados em:

- `joined_at`;
- `deactivated_at`.

O volume do MVP não os justifica ainda.

## Update/Delete

Status de aluno pode mudar.

Desativação:

- status → `INACTIVE`;
- `deactivated_at` recebe o instante efetivo.

`deleted_at` significa exclusão lógica administrativa, não saída normal da academia.

O histórico aprovado depende explicitamente de `joined_at` e `deactivated_at`, pois utilizar somente o status atual alteraria retrospectivamente métricas antigas.

## NÃO deve conter

- frequência calculada;
- última visita persistida;
- score de abandono;
- `synthetic_profile`;
- risco previsto;
- contagens;
- labels como `progressive_decline`;
- arrays de acessos.

---

# 3.5 `access_records`

## Propósito

Tabela factual central.

Cada row representa um fato histórico de visita.

## Colunas

| ColunaTipoNullDefault |             |     |                   |
| --------------------- | ----------- | --- | ----------------- |
| `id`                  | UUID        | NO  | UUID DB           |
| `gym_unit_id`         | UUID        | NO  | —                 |
| `member_id`           | UUID        | NO  | —                 |
| `occurred_at`         | TIMESTAMPTZ | NO  | —                 |
| `status`              | TEXT        | NO  | `VALID`           |
| `created_at`          | TIMESTAMPTZ | NO  | current timestamp |
| `voided_at`           | TIMESTAMPTZ | YES | NULL              |

`voided_at` é refinamento normativo necessário para que a anulação de um fato histórico também seja temporalmente auditável.

## Primary Key

`id`

## Foreign Keys

### FK tenant-safe obrigatória

`(member_id, gym_unit_id) → members(id, gym_unit_id)`

Esta FK é mandatória.

Não substituir por duas FKs independentes.

Ela impede que um `member_id` da unidade A seja usado em um registro declarado como unidade B. Essa proteção já havia sido explicitamente definida no modelo aprovado.

## Check Constraints

- status ∈ access record statuses;
- `VALID → voided_at IS NULL`;
- `VOIDED → voided_at IS NOT NULL`;
- `voided_at IS NULL OR voided_at >= created_at`.

## Tenant Key

`gym_unit_id`

## Indexes

### IDX-AR-01

`(gym_unit_id, occurred_at)`

Justifica:

- total de acessos do período;
- evolução diária;
- distribuição horária;
- comparação entre períodos.

### IDX-AR-02

`(gym_unit_id, member_id, occurred_at)`

Justifica:

- histórico individual;
- última visita;
- frequência do membro;
- comparação individual.

Não criar também `(member_id, occurred_at)` no MVP, porque consultas devem ser tenant-scoped e IDX-AR-02 já cobre o caso autorizado.

## Update/Delete

Fato histórico não deve ser editado arbitrariamente.

Após criação, somente a transição:

`VALID → VOIDED`

é permitida em operação normal.

Não permitir:

`VOIDED → VALID`

sem processo administrativo explícito futuro.

Hard DELETE proibido em produção.

## Efeito em métricas

Somente:

`status = VALID`

participa de métricas de frequência.

Um registro `VOIDED` permanece no banco para auditoria, mas deixa de compor cálculos.

## NÃO deve conter

- `access_date`;
- `access_hour`;
- weekday;
- month;
- week number;
- métricas;
- timezone convertido;
- snapshot do membro.

---

# 3.6 `operational_insights`

## Propósito

Persistir snapshots auditáveis de detecções realizadas pelo Insight Engine.

Nunca é fonte de verdade operacional.

O estado atual continua derivável de fatos brutos + Metrics Engine + rule version.

## Colunas

| ColunaTipoNullDefault |             |     |                   |
| --------------------- | ----------- | --- | ----------------- |
| `id`                  | UUID        | NO  | UUID DB           |
| `gym_unit_id`         | UUID        | NO  | —                 |
| `type`                | TEXT        | NO  | —                 |
| `severity`            | TEXT        | NO  | —                 |
| `subject_type`        | TEXT        | NO  | —                 |
| `subject_id`          | UUID        | YES | NULL              |
| `period_start`        | TIMESTAMPTZ | NO  | —                 |
| `period_end`          | TIMESTAMPTZ | NO  | —                 |
| `comparison_start`    | TIMESTAMPTZ | YES | NULL              |
| `comparison_end`      | TIMESTAMPTZ | YES | NULL              |
| `rule_code`           | VARCHAR(80) | NO  | —                 |
| `rule_version`        | VARCHAR(40) | NO  | —                 |
| `evidence_snapshot`   | JSONB       | NO  | —                 |
| `detected_at`         | TIMESTAMPTZ | NO  | current timestamp |
| `resolved_at`         | TIMESTAMPTZ | YES | NULL              |
| `created_at`          | TIMESTAMPTZ | NO  | current timestamp |

## Primary Key

`id`

## Foreign Keys

`gym_unit_id → gym_units.id`

### Member subject

`subject_id` possui FK composta:

`(subject_id, gym_unit_id) → members(id, gym_unit_id)`

Como FKs aceitam NULL, isso permite `subject_id = NULL` nos demais tipos.

### Semântica obrigatória

- `subject_type = MEMBER` → `subject_id NOT NULL`;
- `subject_type = GYM_UNIT` → `subject_id IS NULL`;
- `subject_type = TIME_SLOT` → `subject_id IS NULL`.

Para `GYM_UNIT`, a entidade sujeita é o próprio `gym_unit_id`.

Para `TIME_SLOT`, o intervalo/faixa fica descrito no `evidence_snapshot`; não existe entidade `time_slots` no MVP.

Isso mantém integridade sem criar FK polimórfica inválida.

## Check Constraints

- `period_start < period_end`;
- comparison start/end devem ser ambos NULL ou ambos não NULL;
- quando existentes: `comparison_start < comparison_end`;
- `rule_code` não vazio;
- `rule_version` não vazio;
- `evidence_snapshot` deve ser JSON object;
- `resolved_at IS NULL OR resolved_at >= detected_at`;
- subject rules acima.

A igualdade de duração entre current/reference é uma invariante do engine/testes quando a regra declarar períodos equivalentes; não é adequadamente expressável como constraint genérica de toda row.

## Tenant Key

`gym_unit_id`

## Indexes

### IDX-OI-01

`(gym_unit_id, detected_at DESC)`

Uso:

Central de atenção e histórico recente.

### IDX-OI-02

`(gym_unit_id, subject_type, subject_id, detected_at DESC)`

Uso:

investigar insights de um membro.

Não criar inicialmente:

- índice por severity;
- índice por type isolado;
- GIN em evidence JSON.

## Update/Delete

Rows são essencialmente snapshots imutáveis.

A única alteração funcional normal é preencher `resolved_at`.

Não reescrever:

- rule version;
- período;
- evidência;
- severidade histórica.

Hard delete somente por política administrativa futura ou reset de ambiente não produtivo.

## NÃO deve conter

- métricas usadas como source of truth;
- thresholds configuráveis globais;
- texto gerado pelo LLM;
- previsão de cancelamento;
- estado atual canônico do dashboard.

---

# 3.7 `ai_conversations`

## Propósito

Agrupar uma sequência de interação entre um único usuário e o Copilot dentro de uma única GymUnit.

## Colunas

| ColunaTipoNullDefault |              |     |                   |
| --------------------- | ------------ | --- | ----------------- |
| `id`                  | UUID         | NO  | UUID DB           |
| `gym_unit_id`         | UUID         | NO  | —                 |
| `user_id`             | UUID         | NO  | —                 |
| `title`               | VARCHAR(160) | YES | NULL              |
| `status`              | TEXT         | NO  | `ACTIVE`          |
| `created_at`          | TIMESTAMPTZ  | NO  | current timestamp |
| `updated_at`          | TIMESTAMPTZ  | NO  | current timestamp |
| `deleted_at`          | TIMESTAMPTZ  | YES | NULL              |

## Primary Key

`id`

## Foreign Keys

- `user_id → app_users.id`;
- `gym_unit_id → gym_units.id`.

### Tenant authorization FK

Deve existir:

`(user_id, gym_unit_id) → user_gym_units(user_id, gym_unit_id)`

Assim uma conversa nunca pode ser criada para um par User/GymUnit sem membership correspondente.

A Application Layer ainda exige membership `ACTIVE`.

## Unique Constraints adicionais

- `(id, gym_unit_id)`
- `(id, gym_unit_id, user_id)`

São chaves candidatas de suporte às FKs compostas de mensagens e runs.

## Check Constraints

- title nulo ou não vazio;
- deleted implica status `ARCHIVED`;
- `updated_at >= created_at`.

## Tenant Key

`gym_unit_id`

## Index

`(user_id, gym_unit_id, updated_at DESC)`

Uso:

listar conversas recentes do usuário na unidade.

## Delete

Soft delete via `deleted_at`.

Não cascadear delete para mensagens ou runs.

## NÃO deve conter

- histórico inteiro serializado;
- contexto da IA;
- resposta agregada;
- arrays de mensagens;
- métricas.

---

# 3.8 `ai_messages`

## Propósito

Persistir mensagens concretas exibidas na conversa.

Mensagens são histórico.

## Colunas

| ColunaTipoNullDefault |             |     |                   |
| --------------------- | ----------- | --- | ----------------- |
| `id`                  | UUID        | NO  | UUID DB           |
| `conversation_id`     | UUID        | NO  | —                 |
| `gym_unit_id`         | UUID        | NO  | —                 |
| `role`                | TEXT        | NO  | —                 |
| `content`             | TEXT        | NO  | —                 |
| `ai_run_id`           | UUID        | YES | NULL              |
| `created_at`          | TIMESTAMPTZ | NO  | current timestamp |

## Primary Key

`id`

## Foreign Keys

### Conversation tenant-safe

`(conversation_id, gym_unit_id) → ai_conversations(id, gym_unit_id)`

Obrigatória.

### Run association

Quando `ai_run_id` não for NULL:

`(ai_run_id, conversation_id, gym_unit_id) → ai_runs(id, conversation_id, gym_unit_id)`

Essa FK é criada somente após `ai_runs` existir, devido ao ciclo de dependência.

## Unique Constraints adicionais

`(id, conversation_id, gym_unit_id)`

Necessária para que AIRun possa apontar tenant-safe para request/response messages.

## Check Constraints

- `content` não vazio;
- role válida;
- `role = USER → ai_run_id IS NULL`;
- `role = ASSISTANT → ai_run_id` normalmente não NULL para respostas do Copilot.

Mensagens de erro de UI não devem ser gravadas artificialmente como resposta de IA.

## Tenant Key

`gym_unit_id`

## Index

`(conversation_id, created_at, id)`

Uso:

ordenação estável do chat.

## Update/Delete

Mensagens são append-only.

Nenhum UPDATE de conteúdo após persistência.

Nenhum DELETE individual em fluxo normal.

## NÃO deve conter

- context snapshot;
- token counts;
- provider;
- model;
- evidence snapshot;
- prompt.

---

# 3.9 `ai_runs`

## Propósito

Registro auditável de uma execução do Copilot.

É a principal tabela de observabilidade histórica do comportamento da IA.

O produto já exige rastrear pergunta, contexto, dados consultados e resposta, e a arquitetura define o AIRun especificamente para esse propósito.

## Colunas

| ColunaTipoNullDefault     |              |     |                   |
| ------------------------- | ------------ | --- | ----------------- |
| `id`                      | UUID         | NO  | UUID DB           |
| `conversation_id`         | UUID         | NO  | —                 |
| `gym_unit_id`             | UUID         | NO  | —                 |
| `user_id`                 | UUID         | NO  | —                 |
| `request_message_id`      | UUID         | NO  | —                 |
| `response_message_id`     | UUID         | YES | NULL              |
| `intent`                  | VARCHAR(80)  | NO  | —                 |
| `question`                | TEXT         | NO  | —                 |
| `context_snapshot`        | JSONB        | NO  | —                 |
| `evidence_snapshot`       | JSONB        | NO  | —                 |
| `response_snapshot`       | JSONB        | YES | NULL              |
| `provider`                | VARCHAR(80)  | NO  | —                 |
| `model`                   | VARCHAR(120) | NO  | —                 |
| `prompt_version`          | VARCHAR(40)  | NO  | —                 |
| `context_schema_version`  | VARCHAR(40)  | NO  | —                 |
| `response_schema_version` | VARCHAR(40)  | NO  | —                 |
| `status`                  | TEXT         | NO  | `STARTED`         |
| `latency_ms`              | INTEGER      | YES | NULL              |
| `input_tokens`            | INTEGER      | YES | NULL              |
| `output_tokens`           | INTEGER      | YES | NULL              |
| `error_code`              | VARCHAR(80)  | YES | NULL              |
| `error_message`           | TEXT         | YES | NULL              |
| `started_at`              | TIMESTAMPTZ  | NO  | current timestamp |
| `completed_at`            | TIMESTAMPTZ  | YES | NULL              |
| `created_at`              | TIMESTAMPTZ  | NO  | current timestamp |

`error_message` é refinamento necessário para cumprir integralmente o requisito de auditar o erro, sem transformar erros em JSON genérico.

O texto deve ser sanitizado e nunca conter API keys, authorization headers ou segredos.

## Primary Key

`id`

## Foreign Keys

### Conversation + tenant + owner

`(conversation_id, gym_unit_id, user_id) → ai_conversations(id, gym_unit_id, user_id)`

Isso impede:

- cross-tenant run;
- run atribuído a usuário diferente do dono da conversa.

### Request message

`(request_message_id, conversation_id, gym_unit_id) → ai_messages(id, conversation_id, gym_unit_id)`

### Response message

`(response_message_id, conversation_id, gym_unit_id) → ai_messages(id, conversation_id, gym_unit_id)`

nullable até existir uma resposta.

## Unique Constraints adicionais

`(id, conversation_id, gym_unit_id)`

necessária para o FK reverso de `ai_messages.ai_run_id`.

## Check Constraints

### Gerais

- question não vazia;
- provider/model/version strings não vazias;
- JSON snapshots devem ser objetos;
- `latency_ms >= 0`;
- `input_tokens >= 0`;
- `output_tokens >= 0`;
- `completed_at IS NULL OR completed_at >= started_at`.

### STARTED

Obrigatório:

- `completed_at IS NULL`;
- `response_message_id IS NULL`;
- `response_snapshot IS NULL`;
- `error_code IS NULL`.

### SUCCEEDED

Obrigatório:

- `completed_at NOT NULL`;
- `response_message_id NOT NULL`;
- `response_snapshot NOT NULL`;
- `error_code IS NULL`;
- `error_message IS NULL`;
- input/output token counts não NULL.

### INSUFFICIENT_DATA

Terminal.

Obrigatório:

- `completed_at NOT NULL`;
- `response_message_id NOT NULL`;
- `response_snapshot NOT NULL`;
- nenhum provider error.

O snapshot deverá registrar explicitamente as limitações.

### FAILED_PROVIDER / FAILED_TIMEOUT / FAILED_VALIDATION

Obrigatório:

- `completed_at NOT NULL`;
- `error_code NOT NULL`;
- `response_message_id IS NULL`.
`response_snapshot` deve ser NULL se nenhuma resposta validada puder ser utilizada.

## Tenant Key

`gym_unit_id`

## Indexes

### IDX-AIR-01

`(conversation_id, created_at, id)`

Uso:

reconstrução/auditoria de uma conversa.

### IDX-AIR-02

`(gym_unit_id, created_at DESC)`

Uso:

auditoria operacional de runs da unidade.

Não criar inicialmente índice por `status`.

Falhas operacionais devem primariamente aparecer em observabilidade/logging; um índice adicional será justificado somente se consultas reais passarem a depender dele.

Não criar GIN nos snapshots.

## Update/Delete

AIRun é append-mostly.

Atualizações permitidas somente durante a transição:

`STARTED → terminal status`.

Após estado terminal, row é imutável.

Hard delete proibido durante operação normal.

## NÃO deve conter

- API key;
- secrets;
- SQL arbitrário;
- autorização concedida pelo LLM;
- fatos não presentes no contexto autorizado.

---

# 4. Enum Contracts

## 4.1 `user_status`

Valores:

- `ACTIVE`
- `INACTIVE`

Usado em:

`app_users.status`

Implementação:

`TEXT + CHECK`

---

## 4.2 `gym_unit_status`

Valores:

- `ACTIVE`
- `INACTIVE`

Usado em:

`gym_units.status`

Implementação:

`TEXT + CHECK`

---

## 4.3 `user_gym_unit_role`

Valores:

- `MANAGER`
- `COORDINATOR`
- `ANALYST`

Usado em:

`user_gym_units.role`

Implementação:

`TEXT + CHECK`

A role não substitui membership.

---

## 4.4 `membership_status`

Valores:

- `ACTIVE`
- `INACTIVE`

Usado em:

`user_gym_units.status`

Separado de `user_status` porque representam lifecycles distintos.

---

## 4.5 `member_status`

Valores:

- `ACTIVE`
- `INACTIVE`

Usado em:

`members.status`

---

## 4.6 `access_record_status`

Valores:

- `VALID`
- `VOIDED`

Usado em:

`access_records.status`

Não adicionar `DELETED`.

---

## 4.7 `insight_type`

Valores MVP:

- `ATTENDANCE_DROP`
- `MEMBER_FREQUENCY_DROP`
- `PROLONGED_ABSENCE`
- `UNUSUALLY_LOW_OCCUPANCY`

Usado em:

`operational_insights.type`

Esses quatro tipos já foram aprovados para o MVP.

---

## 4.8 `insight_severity`

Valores:

- `INFO`
- `WARNING`
- `HIGH`

Usado em:

`operational_insights.severity`

Nenhum significado preditivo deve ser inferido.

---

## 4.9 `insight_subject_type`

Valores:

- `GYM_UNIT`
- `MEMBER`
- `TIME_SLOT`

Usado em:

`operational_insights.subject_type`

---

## 4.10 `conversation_status`

Valores:

- `ACTIVE`
- `ARCHIVED`

Usado em:

`ai_conversations.status`

---

## 4.11 `ai_run_status`

Valores:

- `STARTED`
- `SUCCEEDED`
- `FAILED_PROVIDER`
- `FAILED_TIMEOUT`
- `FAILED_VALIDATION`
- `INSUFFICIENT_DATA`

Usado em:

`ai_runs.status`

---

## 4.12 `message_role`

Valores:

- `USER`
- `ASSISTANT`

Usado em:

`ai_messages.role`

Não persistir mensagens `SYSTEM` como parte da conversa do usuário.

System/developer prompts pertencem ao versionamento do prompt e execução, não ao histórico visual do chat.

---

# 5. Relationship Contract

```text
auth.users
    1
    │
    1
app_users
    │
    │ N
    ▼
user_gym_units
    N
    │
    1
gym_units
    │
    ├──── 1:N ──── members
    │                 │
    │                 └──── 1:N ──── access_records
    │
    ├──── 1:N ──── operational_insights
    │
    └──── 1:N ──── ai_conversations
                         │
                         ├──── 1:N ──── ai_messages
                         │
                         └──── 1:N ──── ai_runs
```

## 5.1 Mandatory composite tenant FKs

### AccessRecord

`access_records(member_id, gym_unit_id)`
→
`members(id, gym_unit_id)`

### OperationalInsight Member subject

`operational_insights(subject_id, gym_unit_id)`
→
`members(id, gym_unit_id)`

aplicável quando subject is MEMBER.

### AIConversation authorization

`ai_conversations(user_id, gym_unit_id)`
→
`user_gym_units(user_id, gym_unit_id)`

### AIMessage

`ai_messages(conversation_id, gym_unit_id)`
→
`ai_conversations(id, gym_unit_id)`

### AIRun

`ai_runs(conversation_id, gym_unit_id, user_id)`
→
`ai_conversations(id, gym_unit_id, user_id)`

### AIRun request/response messages

`ai_runs(request_message_id, conversation_id, gym_unit_id)`
→
`ai_messages(id, conversation_id, gym_unit_id)`

e equivalente para `response_message_id`.

### AIMessage → AIRun

`ai_messages(ai_run_id, conversation_id, gym_unit_id)`
→
`ai_runs(id, conversation_id, gym_unit_id)`

quando `ai_run_id` não for NULL.

---

# 6. Integrity Constraints

Integridade deve existir em três níveis:

1. PostgreSQL;
2. Application/Domain;
3. testes de integração.

O banco garante invariantes locais e relacionais.

A aplicação garante regras que dependem de semântica de negócio ou múltiplos estados.

## 6.1 Database-enforceable

Devem ser constraints:

- tenant-safe FKs;
- enum domains;
- nonnegative token counts;
- nonnegative latency;
- period start < end;
- deactivated >= joined;
- voiding consistency;
- terminal AIRun consistency;
- MEMBER subject requires subject_id;
- comparison bounds pair;
- nonempty required strings.

## 6.2 Application/test-enforceable

Devem ser invariantes testadas:

- membership deve estar ACTIVE para acesso;
- request message de AIRun deve possuir role USER;
- response message deve possuir role ASSISTANT;
- `ai_runs.question` deve representar exatamente a pergunta auditada no request message;
- periods declarados equivalent comparison devem ter mesma duração;
- timezone deve ser IANA válido;
- thresholds devem corresponder à `rule_version`;
- evidence IDs citados pela IA devem existir no contexto autorizado.

---

# 7. Index Contract

O MVP possui aproximadamente 500 membros e dezenas de milhares de AccessRecords, portanto indexação deve ser orientada a consultas reais, não preventiva. O dataset aprovado prevê \~180 dias e aproximadamente 25–35 mil registros de acesso.

## Obrigatórios além de PK/UNIQUE

| TabelaÍndiceCaso de uso |                                                             |                               |
| ----------------------- | ----------------------------------------------------------- | ----------------------------- |
| `members`               | `(gym_unit_id, status)`                                     | ativos/lista                  |
| `access_records`        | `(gym_unit_id, occurred_at)`                                | dashboard/períodos/ocupação   |
| `access_records`        | `(gym_unit_id, member_id, occurred_at)`                     | detalhe/frequência/last visit |
| `operational_insights`  | `(gym_unit_id, detected_at DESC)`                           | central de atenção            |
| `operational_insights`  | `(gym_unit_id, subject_type, subject_id, detected_at DESC)` | investigação de membro        |
| `ai_conversations`      | `(user_id, gym_unit_id, updated_at DESC)`                   | conversas recentes            |
| `ai_messages`           | `(conversation_id, created_at, id)`                         | ordenação                     |
| `ai_runs`               | `(conversation_id, created_at, id)`                         | audit trail                   |
| `ai_runs`               | `(gym_unit_id, created_at DESC)`                            | auditoria de unidade          |

## Não criar inicialmente

- GIN JSONB;
- indexes por provider;
- indexes por model;
- indexes por tokens;
- index isolado por severity;
- index isolado por role;
- indexes em cada timestamp;
- index de status de AIRun;
- três índices parcialmente redundantes de AccessRecord.

A especificação anterior já recomendava explicitamente não criar GIN sobre JSONB sem uma query concreta que dependa dele.

---

# 8. RLS Contract

## 8.1 Princípio

Authorization normal:

```text
auth.uid()
→ active user_gym_units
→ permitted gym_unit_id
→ row.gym_unit_id
```

RLS reforça a Application Layer.

Nenhuma policy pode depender de decisão do LLM.

## 8.2 `app_users`

### SELECT

Usuário autenticado:

- seu próprio perfil.

### INSERT

Exclusivamente server-side durante provisioning.

### UPDATE

Usuário pode alterar apenas campos de perfil permitidos através da aplicação.

Status/deletion: server-side administrativo.

### DELETE

Negado no fluxo normal.

---

# 8.3 `gym_units`

### SELECT

Usuário com `user_gym_units.status = ACTIVE` para a unidade.

### INSERT / UPDATE / DELETE

Exclusivamente server-side administrativo.

Nenhuma interface administrativa está no MVP.

---

# 8.4 `user_gym_units`

### SELECT

Usuário pode consultar suas próprias memberships.

### INSERT / UPDATE / DELETE

Somente server-side administrativo.

---

# 8.5 `members`

### SELECT

Membership ACTIVE para `members.gym_unit_id`.

### INSERT / UPDATE

MVP não possui gestão de alunos.

Escrita somente por:

- dataset seed;
- fixtures;
- processos administrativos controlados.

### DELETE

Hard delete não permitido.

---

# 8.6 `access_records`

### SELECT

Membership ACTIVE para `gym_unit_id`.

### INSERT

Não disponível ao usuário final no MVP.

Seed/fixture/processo controlado server-side.

### UPDATE

Somente processo autorizado de void.

### DELETE

Negado.

---

# 8.7 `operational_insights`

### SELECT

Membership ACTIVE na unidade.

### INSERT

Insight Engine server-side.

### UPDATE

Server-side, restrito à resolução/lifecycle autorizado.

### DELETE

Negado ao usuário.

---

# 8.8 `ai_conversations`

### SELECT

Somente se:

- `user_id = auth.uid()`;
- membership da GymUnit continua ativa.

### INSERT

Somente para:

- `user_id = auth.uid()`;
- unidade autorizada.

A aplicação server-side executa o caso de uso.

### UPDATE

Somente owner, para operações permitidas como:

- title;
- archive;
- soft delete.

### DELETE

Hard delete negado.

---

# 8.9 `ai_messages`

### SELECT

Usuário deve ser owner da conversation e continuar autorizado à unidade.

### INSERT

User message:

server-side após autenticação/autorização.

Assistant message:

exclusivamente orquestrador do Copilot server-side.

### UPDATE / DELETE

Negados.

---

# 8.10 `ai_runs`

### SELECT

Somente owner da conversation correspondente e unidade autorizada.

### INSERT / UPDATE

Exclusivamente server-side Copilot orchestration.

### DELETE

Negado.

---

# 8.11 Service-role boundary

Service role pode bypassar RLS.

Logo:

**nunca deve chegar ao browser.**

Permitido somente para operações claramente controladas, como:

- seed;
- test fixtures;
- maintenance;
- tarefas administrativas internas.

Ela não deve ser o mecanismo padrão para requests normais de usuário se uma sessão autenticada puder preservar RLS. Essa fronteira já foi definida arquiteturalmente.

Mesmo server-side, usar service role não elimina a obrigação de validar explicitamente o tenant.

---

# 9. AI Audit Contract

Cada interação relevante deverá permitir reconstruir:

```text
quem perguntou
em qual unidade
em qual conversa
qual foi a pergunta
qual contexto foi apresentado
quais evidências foram apresentadas
qual provider/model foi selecionado
qual prompt version foi usada
qual schema de contexto foi usado
qual schema de resposta foi usado
quantos tokens foram consumidos
quanto tempo levou
qual status final ocorreu
qual resposta validada foi produzida
ou qual erro ocorreu
```

## Lifecycle normativo

### 1. User message

Criar `ai_messages` role USER.

### 2. Authorized deterministic context

Application Layer:

- autoriza GymUnit;
- consulta fatos;
- executa Metrics Engine;
- executa Insight Engine;
- constrói contexto e evidências.

### 3. AIRun STARTED

Persistir AIRun antes da chamada ao provider, contendo:

- request_message;
- question;
- context snapshot;
- evidence snapshot;
- provider/model;
- versions.

### 4. Provider execution

Capturar:

- latency;
- token usage;
- failure category.

### 5. Response validation

Validar:

- schema;
- evidence references;
- resposta autorizada.

A arquitetura determina que o modelo receba fatos estruturados autorizados e que a resposta seja validada antes de chegar ao usuário.

### 6. Assistant message

Somente após resposta utilizável.

### 7. Terminal AIRun

Atualizar uma única vez para status terminal.

---

# 10. JSON Snapshot Contract

JSONB deve representar documentos imutáveis/versionados.

Não é substituto para modelagem relacional.

O contrato aprovado já restringe JSONB a snapshots de IA e evidências de insights, mantendo entidades operacionais relacionais.

## 10.1 `ai_runs.context_snapshot`

Schema conceitual:

```text
{
  schemaVersion,
  gymUnit,
  period,
  questionContext,
  facts[],
  breakdowns[],
  relevantInsights[],
  limitations[],
  capabilities[]
}
```

### Regras

- somente dados já autorizados;
- fatos calculados deterministicamente;
- não conter dados de outra unidade;
- não conter secrets;
- não conter SQL;
- não conter acesso arbitrário ao DB.

`schemaVersion` deve ser igual a `context_schema_version`.

---

# 10.2 `ai_runs.evidence_snapshot`

Schema conceitual:

```text
{
  schemaVersion,
  evidence: [
    {
      id,
      kind,
      label,
      value,
      unit,
      period,
      subject
    }
  ]
}
```

Cada evidência deve possuir ID estável dentro da execução, por exemplo:

`E1`, `E2`, `E3`.

A resposta do modelo só pode referenciar IDs existentes nesse snapshot.

Evidência não é texto livre sem vínculo.

---

# 10.3 `ai_runs.response_snapshot`

Schema conceitual:

```text
{
  schemaVersion,
  answer,
  evidenceIds[],
  limitations[],
  followUpQuestions[]
}
```

Pode possuir campos adicionais definidos pela versão de response schema, mas nunca fatos operacionais novos.

`schemaVersion` deve ser igual a `response_schema_version`.

O snapshot salvo é a **resposta estruturada validada**, não qualquer payload bruto recebido do fornecedor.

---

# 10.4 `operational_insights.evidence_snapshot`

Schema conceitual mínimo:

```text
{
  schemaVersion,
  rule: {
    code,
    version
  },
  thresholds,
  currentPeriod,
  comparisonPeriod,
  metrics,
  breakdowns,
  subject
}
```

Deve conter evidência suficiente para reproduzir por que a regra disparou.

Não deve ser utilizado como substituto das tabelas factuais.

---

# 10.5 Versioning rules

Mudança backward-incompatible:

→ nova schema version.

Rows históricas nunca são reescritas para aparentar terem sido produzidas por schema mais recente.

Readers devem:

- interpretar versões suportadas;
- rejeitar versões desconhecidas;
- nunca assumir implicitamente latest schema.

---

# 11. Timezone Contract

## 11.1 Storage

Todos os instantes são armazenados em UTC semanticamente pelo PostgreSQL através de `TIMESTAMPTZ`.

Aplicação não deve gravar timestamps locais sem offset/zone.

## 11.2 GymUnit timezone

Cada GymUnit possui:

`gym_units.timezone`

MVP demo:

`America/Sao_Paulo`.

## 11.3 Grouping

Antes de derivar:

- local date;
- local hour;
- weekday;

`occurred_at` deve ser convertido para o timezone da unidade.

Nunca fazer análise diária simplesmente truncando UTC.

## 11.4 Example

Um acesso pode pertencer:

- a determinado dia UTC;
- ao dia operacional anterior ou seguinte no timezone local.

Portanto:

```text
UTC instant
→ gym timezone
→ local operational date/hour
→ grouping
```

## 11.5 Period semantics

Todo período analítico usa:

`[start, end)`

Ou seja:

- start inclusive;
- end exclusive.

Isto impede contagem duplicada entre períodos adjacentes.

O modelo de dados aprovado já utiliza essa semântica para as métricas.

## 11.6 DST

A aplicação não deve assumir offset fixo como `-03:00`.

Deve trabalhar com o nome IANA da zona.

Mesmo que a demo use São Paulo, o contrato deve continuar correto para unidades em zonas com DST.

---

# 12. Deletion / History Contract

## 12.1 `app_users`

Soft delete.

Também deve ocorrer desativação correspondente no Supabase Auth.

Hard delete não faz parte da operação normal.

## 12.2 `gym_units`

Soft delete possível, embora improvável.

Hard delete restrito.

## 12.3 `user_gym_units`

Perda de acesso:

`status = INACTIVE`.

Não remover historicamente a associação como comportamento padrão.

## 12.4 `members`

Desativação normal:

```text
status = INACTIVE
deactivated_at = effective timestamp
```

Exclusão administrativa:

`deleted_at`.

`INACTIVE ≠ deleted`.

## 12.5 Histórico de métricas

Métricas históricas não podem ser calculadas somente com `members.status` atual.

Membership temporal depende de:

- `joined_at`;
- `deactivated_at`;
- instante/período analítico.

Alterar o status hoje não pode mudar artificialmente a população histórica de meses anteriores.

## 12.6 `access_records`

Não soft-delete.

Correção:

```text
status = VOIDED
voided_at = ...
```

Dados permanecem auditáveis.

A modelagem aprovada já determina explicitamente que AccessRecords históricos não sejam soft-deleted.

## 12.7 `operational_insights`

Snapshot histórico.

Resolver preenchendo `resolved_at`.

Não modificar evidência antiga para refletir regra nova.

## 12.8 Conversations

`deleted_at` remove logicamente a conversa da experiência do usuário.

Não apagar mensagens/runs individualmente.

## 12.9 AIMessage / AIRun

Não possuem soft delete individual.

São parte da audit trail.

Uma política formal de retenção futura poderá permitir purge administrativo, mas isso está fora do MVP.

---

# 13. Migration Dependency Order
Nenhuma migration SQL é produzida nesta fase.

A ordem futura deve ser:

## M01 — Database foundations

- extensão/função necessária para UUID;
- helpers comuns;
- mecanismo de `updated_at`.

## M02 — `app_users`

Depende de:

`auth.users`.

## M03 — `gym_units`

Sem dependência de tabelas da aplicação.

## M04 — `user_gym_units`

Depende de:

- app_users;
- gym_units.

## M05 — `members`

Depende de:

- gym_units.

Inclui unique `(id, gym_unit_id)`.

## M06 — `access_records`

Depende de:

- members.

Inclui composite tenant FK.

## M07 — `operational_insights`

Depende de:

- gym_units;
- members.

## M08 — `ai_conversations`

Depende de:

- app_users;
- gym_units;
- user_gym_units.

## M09 — `ai_messages` base

Criar tabela e FK para conversation.

`ai_run_id` poderá existir nullable, mas sua FK para `ai_runs` ainda não deve ser criada.

## M10 — `ai_runs`

Depende de:

- ai_conversations;
- ai_messages.

Criar FKs de request/response messages.

## M11 — Complete AIMessage ↔ AIRun relation

Adicionar FK:

`ai_messages.ai_run_id → ai_runs`

utilizando a composite tenant-safe key.

## M12 — Secondary indexes

Criar apenas índices aprovados neste contrato.

## M13 — RLS enablement and policies

Implementar contrato de acesso deste documento.

Não inventar regras adicionais.

## M14 — Database integration tests / invariants

Verificar:

- cross-tenant rejection;
- FKs;
- lifecycle;
- terminal AI states;
- deletion rules;
- RLS isolation.

---

# 14. Seed Contract

## 14.1 Classes de dados

### A. Structural seed

Dados necessários para tornar o ambiente utilizável:

- Auth demo user;
- `app_users`;
- `gym_units`;
- `user_gym_units`.

### B. Synthetic operational dataset

- `members`;
- `access_records`.

### C. Derived demo state

- `operational_insights` produzidos a partir dos fatos e rule version.

Não devem ser tratados como fatos canônicos.

### D. AI interaction data

`ai_conversations`, `ai_messages` e `ai_runs` não pertencem ao seed operacional base.

Uma fixture separada pode existir para demo/testes específicos.

---

# 14.2 Dataset manifest

O manifesto fica fora do modelo operacional.

Deve declarar pelo menos:

```text
dataset_version
seed
as_of_date
gym_unit_id
scenario_configuration
```

A geração aprovada depende exclusivamente dessas entradas explícitas; mesmos parâmetros devem produzir o mesmo dataset.

## Baseline aprovado

- 1 unidade;
- \~500 membros;
- \~180 dias;
- timezone `America/Sao_Paulo`;
- random seed fixo;
- aproximadamente 25k–35k access records.

## Proibição

Não persistir em `members`:

- `high_frequency`;
- `progressive_decline`;
- `apparent_abandonment`;
- outros synthetic labels.

Eles pertencem somente ao manifesto/fixture.

---

# 14.3 Idempotency

Todo seed oficial deve poder ser executado repetidamente sem duplicar dados.

Estratégia normativa:

### Structural records

Usar identificadores determinísticos/estáveis:

- GymUnit code;
- Auth demo UUID;
- user UUID;
- membership composite key.

### Members

`member_code` determinístico dentro da unidade.

UUIDs devem ser deterministicamente reproduzíveis pelo generator ou mantidos em fixture estável.

### AccessRecords

IDs devem ser determinísticos a partir do dataset/gerador.

Não depender de UUID aleatório novo em cada execução.

## Resultado obrigatório

```text
same dataset_version
+ same seed
+ same as_of_date
+ same scenarios

=> same entity identities
+ same facts
+ same expected metrics
+ same expected insights
```

---

# 14.4 Seed order

1. Supabase Auth demo user.
2. `app_users`.
3. `gym_units`.
4. `user_gym_units`.
5. `members`.
6. `access_records`.
7. executar deterministicamente Metrics/Insight Engine para fixtures derivadas.
8. persistir `operational_insights` derivados, se a fixture exigir.
9. opcionalmente criar fixtures isoladas de AI conversations/runs.

Não inserir AIRun “falso” no dataset operacional principal.

---

# 15. Formal Invariants

As migrations e testes deverão garantir formalmente:

### Identity / Authorization

**INV-001**
`app_users.id` deve corresponder a `auth.users.id`.

**INV-002**
Nenhuma senha existe em tabelas da aplicação.

**INV-003**
`user_gym_units` não pode referenciar User ou GymUnit inexistente.

**INV-004**
Membership duplicada `(user_id, gym_unit_id)` é impossível.

**INV-005**
Usuário não obtém acesso a GymUnit sem membership ACTIVE.

### Tenant

**INV-006**
Todo fato operacional possui `gym_unit_id`.

**INV-007**
Member pertence a exatamente uma GymUnit.

**INV-008**
AccessRecord e Member pertencem à mesma GymUnit.

**INV-009**
AIMessage e AIConversation pertencem à mesma GymUnit.

**INV-010**
AIRun e AIConversation pertencem à mesma GymUnit.

**INV-011**
AIRun user é o dono da conversation correspondente.

**INV-012**
OperationalInsight com subject MEMBER só pode referenciar Member da mesma GymUnit.

### Member history

**INV-013**
`deactivated_at >= joined_at`.

**INV-014**
Member ACTIVE não possui `deactivated_at`.

**INV-015**
Member desativado não deixa de existir historicamente.

**INV-016**
Métricas históricas não podem depender apenas do status atual do Member.

### AccessRecord

**INV-017**
AccessRecord é fato histórico.

**INV-018**
AccessRecord nunca é soft-deleted.

**INV-019**
Somente status VALID entra em métricas.

**INV-020**
VOIDED exige `voided_at`.

**INV-021**
VALID exige `voided_at = NULL`.

### Periods / timezone

**INV-022**
`period_start < period_end`.

**INV-023**
`comparison_start` e `comparison_end` aparecem juntos.

**INV-024**
`comparison_start < comparison_end`.

**INV-025**
Comparações declaradas equivalentes possuem mesma duração.

**INV-026**
Períodos usam `[start,end)`.

**INV-027**
Agrupamento diário/horário usa timezone da GymUnit, nunca UTC bruto.

### Metrics / insights

**INV-028**
Métricas de dashboard não são persistidas como tabela.

**INV-029**
OperationalInsight nunca substitui recalculabilidade determinística.

**INV-030**
Todo OperationalInsight possui `rule_code`.

**INV-031**
Todo OperationalInsight possui `rule_version`.

**INV-032**
Todo OperationalInsight possui evidência reproduzível.

**INV-033**
Rule thresholds pertencem à configuração versionada da aplicação, não ao LLM.

### AI

**INV-034**
LLM nunca recebe fatos antes da autorização.

**INV-035**
AIRun sempre pertence a uma conversation válida.

**INV-036**
AIRun sempre referencia uma request message válida.

**INV-037**
Request message deve pertencer à mesma conversation e GymUnit.

**INV-038**
Response message, quando presente, deve pertencer à mesma conversation e GymUnit.

**INV-039**
SUCCEEDED exige `completed_at`.

**INV-040**
SUCCEEDED exige `response_snapshot`.

**INV-041**
SUCCEEDED exige `response_message_id`.

**INV-042**
SUCCEEDED não possui provider error.

**INV-043**
Terminal failure possui `completed_at`.

**INV-044**
latency nunca é negativa.

**INV-045**
token counts nunca são negativos.

**INV-046**
Snapshots não podem conter dados de outra GymUnit.

**INV-047**
Toda evidence ID apresentada na resposta deve existir no evidence snapshot daquela execução.

**INV-048**
O LLM não cria fatos numéricos primários.

### JSONB

**INV-049**
JSONB não armazena membros, acessos, permissions ou tenant relationships.

**INV-050**
Snapshots JSON possuem schema version.

**INV-051**
Snapshots históricos não são silenciosamente migrados para aparentar versão mais nova.

### Dataset

**INV-052**
Synthetic dataset é determinístico.

**INV-053**
Synthetic profiles não existem no modelo operacional.

**INV-054**
Same seed/config/as_of_date produz mesmos fatos.

---

# 16. Database Acceptance Criteria

O Database Contract v0.1 será considerado implementado corretamente quando:

## Schema

-  exatamente as nove tabelas do MVP existirem;
-  não existir tabela persistida de AttendanceMetric;
-  todos os tipos/nullabilities/defaults coincidirem com este contrato;
-  todos os CHECKs normativos estiverem representados;
-  todas as candidate keys necessárias às FKs compostas existirem.

## Tenant isolation

-  tentativa de criar AccessRecord apontando Member de outra GymUnit falhar;
-  tentativa de criar AIMessage para conversation de outra GymUnit falhar;
-  tentativa de criar AIRun com GymUnit diferente da conversation falhar;
-  tentativa de criar AIRun com User diferente do dono da conversation falhar;
-  insight MEMBER cross-tenant falhar.

## Historical correctness

-  desativar Member hoje não altera indevidamente métricas anteriores;
-  VOIDED AccessRecord deixa de ser contado sem ser apagado;
-  fatos históricos permanecem auditáveis.

## AI audit

-  cada run possui pergunta;
-  contexto versionado;
-  evidências;
-  provider;
-  model;
-  prompt version;
-  context schema version;
-  response schema version;
-  status;
-  timestamps;
-  usage quando aplicável;
-  latency;
-  resposta validada ou erro.

## JSONB

-  nenhuma relationship crítica depende de JSON;
-  nenhuma policy de RLS depende de JSON snapshot;
-  não existem GIN indexes prematuros;
-  JSON snapshots possuem versionamento explícito.

## RLS

-  usuário de Unit A não consegue SELECT de Unit B;
-  usuário de Unit A não consegue inserir row tenant B;
-  conversas são privadas por user + tenant;
-  AIRuns não podem ser criados diretamente pelo usuário;
-  service role não existe no browser bundle;
-  operações normais não dependem de bypass de RLS.

## Timezone

-  todos os fatos temporais usam TIMESTAMPTZ;
-  agrupamentos usam GymUnit timezone;
-  períodos adjacentes não duplicam eventos;
-  testes cobrem fronteiras de dia local.

## Seed

-  seed executado duas vezes não duplica rows;
-  mesmo manifesto produz dataset idêntico;
-  synthetic labels ficam fora das tabelas operacionais;
-  métricas esperadas e insights esperados são reproduzíveis.

---

# 17. Remaining Open Questions

Não existem questões de **schema relacional bloqueantes** para que um agente Codex gere as migrations após aprovação deste contrato.

Os pontos restantes são de configuração/implementação, não decisões de modelagem:

### OQ-01 — valor numérico/string definitivo do random seed

O contrato exige seed fixo, mas o valor concreto ainda pode ser escolhido quando o generator for implementado.

### OQ-02 — `as_of_date` canônica das fixtures oficiais

Deve ser uma data fixa e versionada.

Não altera schema.

### OQ-03 — nome inicial de provider/model

`provider` e `model` já estão modelados como dados auditáveis e não exigem alteração de schema.

### OQ-04 — política de retenção de AI audit

Nenhum purge automático deve existir no MVP.

Uma política futura de retenção poderá definir quando mensagens/runs antigos podem ser removidos administrativamente.

### OQ-05 — exposição futura de gestão de membros

No MVP, members/accesses são carregados pelo dataset e não possuem CRUD de gestão.

Se futuramente existir cadastro operacional real, o RLS contract de INSERT/UPDATE precisará ser revisto.

---

# 18. Contract Freeze

Após aprovação deste documento, o agente responsável pelas migrations:

**PODE**

- traduzir tipos;
- criar constraints;
- criar FKs;
- criar índices definidos;
- implementar timestamps;
- implementar RLS conforme este contrato;
- criar testes das invariantes.

**NÃO PODE**

- adicionar tabela;
- remover tabela;
- adicionar coluna de domínio;
- transformar JSON em relacionamento;
- substituir FK composta por FK simples;
- persistir métricas;
- adicionar synthetic labels;
- modificar enums;
- criar novos statuses;
- criar índices não previstos sem justificativa;
- mudar delete behavior;
- permitir service role no browser;
- permitir cross-tenant references;
- transformar OperationalInsight em source of truth;
- permitir SQL livre ao LLM;
- criar migrations que alterem decisões de modelagem por conveniência.

Qualquer necessidade desse tipo deve retornar para revisão do Database Contract.

---

## Final Database Model

```text
auth.users
    │
    ▼
app_users
    │
    ▼
user_gym_units ─────────────► gym_units
                                  │
                                  ├──── members
                                  │       │
                                  │       └──── access_records
                                  │
                                  ├──── operational_insights
                                  │
                                  └──── ai_conversations
                                           │
                                           ├──── ai_messages
                                           │       ▲
                                           │       │
                                           └──── ai_runs
```

Fronteiras finais:

```text
members + access_records
        =
canonical operational facts

PostgreSQL aggregations
+ Metrics Engine
        =
deterministic derived facts

Insight Engine
        =
deterministic detection

operational_insights
        =
reproducible detection snapshots

AI Context Builder
        =
authorized structured facts

ai_runs
        =
auditable interpretation snapshots

LLM
        =
interpretation only
```

**Database Contract v0.1: READY FOR MIGRATION DESIGN.**

Esse contrato fecha as decisões que normalmente fariam um agente de migrations “inventar” modelagem no caminho — principalmente FKs tenant-safe, lifecycle de AI run, polimorfismo de `OperationalInsight.subject_id`, estratégia de enums e dependência circular `AIMessage ↔ AIRun`. A próxima fase já pode exigir do Codex uma tradução mecânica desse contrato para migrations + testes de banco, sem redesenhar o schema.
