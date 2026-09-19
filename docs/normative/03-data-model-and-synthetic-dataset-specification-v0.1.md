# AI Fitness Operations Copilot

## Data Model & Synthetic Dataset Specification — v0.1

---

# 1. Decisões de modelagem

O modelo do MVP será propositalmente pequeno.

Não vamos modelar contratos, planos, cobranças, CRM, treino, pagamentos ou outras entidades de um ERP fitness, pois isso está explicitamente fora do escopo do produto. 

A base será composta por cinco grupos conceituais:

```text
Identity & Authorization
    User
    GymUnit
    UserGymUnit

Operational Data
    Member
    AccessRecord

Derived Analysis
    OperationalInsight

AI Interaction
    AIConversation
    AIMessage
    AIRun

Configuration
    InsightRuleConfiguration
    (conceitualmente; inicialmente versionada na aplicação)
```

A entidade `AttendanceMetric` apresentada originalmente como possibilidade **não será uma tabela persistente no MVP**. A própria especificação admite que essas métricas podem ser calculadas dinamicamente, e a arquitetura coloca essa responsabilidade no Metrics Engine.  

---

# 2. Conceptual Data Model

```text
Supabase Auth User
       │
       │ 1:1
       ▼
   App User
       │
       │ N:M
       ▼
 UserGymUnit
       │
       ▼
    GymUnit
       │
       ├────────────── 1:N ──────────────► Member
       │                                      │
       │                                      │ 1:N
       │                                      ▼
       │                                 AccessRecord
       │
       ├────────────── 1:N ──────────────► OperationalInsight
       │
       └────────────── 1:N ──────────────► AIConversation
                                                │
                                                ├── 1:N AIMessage
                                                │
                                                └── 1:N AIRun
```

Há uma regra transversal:

> Todo dado operacional pertencente a uma unidade deve ser identificável por `gym_unit_id`.

Isso é consistente com a arquitetura, que determina associação User → membership → GymUnit e exige `gym_unit_id` em consultas operacionais. 

---

# 3. Relational Model

## 3.1 `app_users`

Representa o usuário da aplicação.

Não armazena senha.

Autenticação continua pertencendo ao Supabase Auth.

| Campo        | Tipo conceitual | Regra                     |
| ------------ | --------------- | ------------------------- |
| id           | UUID            | PK e FK → `auth.users.id` |
| display_name | VARCHAR(120)    | NOT NULL                  |
| status       | ENUM            | ACTIVE / INACTIVE         |
| created_at   | TIMESTAMPTZ     | NOT NULL                  |
| updated_at   | TIMESTAMPTZ     | NOT NULL                  |
| deleted_at   | TIMESTAMPTZ     | nullable                  |

### Decisão

`id` deverá reutilizar o UUID gerado pelo Supabase Auth.

Não criar um identificador de autenticação paralelo.

---

# 3.2 `gym_units`

Representa a unidade da academia.

Mesmo com apenas uma unidade na demonstração, ela permanece entidade explícita porque isolamento de dados é requisito arquitetural.

| Campo      | Tipo conceitual | Regra             |
| ---------- | --------------- | ----------------- |
| id         | UUID            | PK                |
| name       | VARCHAR(150)    | NOT NULL          |
| code       | VARCHAR(40)     | UNIQUE, NOT NULL  |
| timezone   | VARCHAR(64)     | NOT NULL          |
| status     | ENUM            | ACTIVE / INACTIVE |
| created_at | TIMESTAMPTZ     | NOT NULL          |
| updated_at | TIMESTAMPTZ     | NOT NULL          |
| deleted_at | TIMESTAMPTZ     | nullable          |

### Timezone

Para a unidade sintética:

```text
America/Sao_Paulo
```

Esse campo é importante porque:

```text
2026-09-18T21:00:00Z
```

não necessariamente corresponde ao mesmo dia operacional local.

Agrupamentos por:

* dia;
* hora;
* dia da semana;

devem usar o timezone da unidade.

---

# 3.3 `user_gym_units`

Tabela associativa User ↔ GymUnit.

| Campo       | Tipo        | Regra                           |
| ----------- | ----------- | ------------------------------- |
| user_id     | UUID        | FK → `app_users.id`             |
| gym_unit_id | UUID        | FK → `gym_units.id`             |
| role        | ENUM        | MANAGER / COORDINATOR / ANALYST |
| status      | ENUM        | ACTIVE / INACTIVE               |
| created_at  | TIMESTAMPTZ | NOT NULL                        |

Primary key composta:

```text
(user_id, gym_unit_id)
```

Isso materializa a regra de autorização definida anteriormente: o usuário somente pode consultar unidades às quais possui acesso. 

---

# 3.4 `members`

Representa o aluno.

A estrutura deve ser propositalmente limitada para evitar transformar o MVP em cadastro/CRM.

| Campo          | Tipo         | Regra                |
| -------------- | ------------ | -------------------- |
| id             | UUID         | PK                   |
| gym_unit_id    | UUID         | FK                   |
| member_code    | VARCHAR(32)  | identificador humano |
| display_name   | VARCHAR(120) | sintético            |
| status         | ENUM         | ACTIVE / INACTIVE    |
| joined_at      | TIMESTAMPTZ  | NOT NULL             |
| deactivated_at | TIMESTAMPTZ  | nullable             |
| created_at     | TIMESTAMPTZ  | NOT NULL             |
| updated_at     | TIMESTAMPTZ  | NOT NULL             |
| deleted_at     | TIMESTAMPTZ  | nullable             |

Constraint:

```text
UNIQUE (gym_unit_id, member_code)
```

Também deverá existir unicidade lógica que permita:

```text
(id, gym_unit_id)
```

ser alvo de FK composta.

### Por que existe `deactivated_at`?

Porque `status = ACTIVE` sozinho não preserva histórico.

Imagine:

```text
Junho:
500 alunos ativos

Setembro:
aluno #123 é desativado
```

Se recalculássemos junho usando apenas seu status atual, junho passaria artificialmente a ter 499 alunos ativos.

Para consultas históricas:

```text
ativo em T =
joined_at <= T
AND
(deactivated_at IS NULL OR deactivated_at > T)
AND
deleted_at IS NULL
```

Isso mantém o histórico reproduzível.

---

# 3.5 `access_records`

É a tabela factual central do sistema.

Um registro representa uma visita registrada na academia, conforme a regra de produto. 

| Campo       | Tipo        | Regra          |
| ----------- | ----------- | -------------- |
| id          | UUID        | PK             |
| gym_unit_id | UUID        | FK             |
| member_id   | UUID        | FK             |
| occurred_at | TIMESTAMPTZ | NOT NULL       |
| status      | ENUM        | VALID / VOIDED |
| created_at  | TIMESTAMPTZ | NOT NULL       |

FK importante:

```text
(member_id, gym_unit_id)
→
members(id, gym_unit_id)
```

Isso impede um erro como:

```text
access_record:
member = aluno da unidade A
gym_unit = unidade B
```

mesmo que ambos os UUIDs existam.

### Não armazenar separadamente

Não precisamos persistir:

```text
access_date
access_hour
weekday
week_number
month
```

Esses valores são derivados de `occurred_at`.

Persisti-los criaria risco de inconsistência.

---

# 3.6 `operational_insights`

Aqui existe uma decisão arquitetural importante.

## Não usar `operational_insights` como fonte da verdade

O Insight Engine deve continuar capaz de calcular:

```text
metrics
        ↓
rules
        ↓
insight
```

a qualquer momento.

Um registro persistido de insight será apenas um:

> **snapshot auditável de uma detecção determinística.**

Não será o dado canônico.

Estrutura proposta:

| Campo             | Tipo        | Regra                         |
| ----------------- | ----------- | ----------------------------- |
| id                | UUID        | PK                            |
| gym_unit_id       | UUID        | FK                            |
| type              | ENUM        | NOT NULL                      |
| severity          | ENUM        | INFO / WARNING / HIGH         |
| subject_type      | ENUM        | GYM_UNIT / MEMBER / TIME_SLOT |
| subject_id        | UUID        | nullable                      |
| period_start      | TIMESTAMPTZ | NOT NULL                      |
| period_end        | TIMESTAMPTZ | NOT NULL                      |
| comparison_start  | TIMESTAMPTZ | nullable                      |
| comparison_end    | TIMESTAMPTZ | nullable                      |
| rule_code         | VARCHAR     | NOT NULL                      |
| rule_version      | VARCHAR     | NOT NULL                      |
| evidence_snapshot | JSONB       | NOT NULL                      |
| detected_at       | TIMESTAMPTZ | NOT NULL                      |
| resolved_at       | TIMESTAMPTZ | nullable                      |
| created_at        | TIMESTAMPTZ | NOT NULL                      |

Tipos iniciais:

```text
ATTENDANCE_DROP
MEMBER_FREQUENCY_DROP
PROLONGED_ABSENCE
UNUSUALLY_LOW_OCCUPANCY
```

### Persistir ou calcular dinamicamente?

Minha decisão para o MVP é:

> **modelo híbrido.**

O estado atual deve ser recalculável deterministicamente.

Mas ocorrências importantes podem ser persistidas como snapshots para:

* auditabilidade;
* demonstração;
* reproduzir exatamente o que o usuário viu;
* referenciar evidências em conversas da IA;
* testar evolução dos sinais;
* investigar posteriormente por que um insight apareceu.

A arquitetura já define insights como objetos determinísticos compostos por tipo, período, métrica, valores e evidências. 

### O que não fazer

Não implementar:

```text
dashboard
    ↓
SELECT * FROM operational_insights
```

como se a tabela definisse a realidade.

O fluxo correto continua sendo:

```text
raw data
   ↓
Metrics Engine
   ↓
Insight Engine
   ↓
current deterministic result

        + optional persistence

OperationalInsight snapshot
```

---

# 4. Estrutura para IA

A auditabilidade exige conseguir identificar pergunta, contexto utilizado, dados consultados e resposta produzida. Isso já é requisito explícito do produto. 

---

# 4.1 `ai_conversations`

| Campo       | Tipo                   |
| ----------- | ---------------------- |
| id          | UUID PK                |
| gym_unit_id | UUID FK                |
| user_id     | UUID FK                |
| title       | VARCHAR nullable       |
| status      | ENUM ACTIVE / ARCHIVED |
| created_at  | TIMESTAMPTZ            |
| updated_at  | TIMESTAMPTZ            |
| deleted_at  | TIMESTAMPTZ nullable   |

Uma conversa:

```text
pertence a 1 usuário
pertence a 1 unidade
possui N mensagens
possui N execuções de IA
```

---

# 4.2 `ai_messages`

| Campo           | Tipo                  |
| --------------- | --------------------- |
| id              | UUID PK               |
| conversation_id | UUID FK               |
| gym_unit_id     | UUID FK               |
| role            | ENUM USER / ASSISTANT |
| content         | TEXT                  |
| ai_run_id       | UUID nullable         |
| created_at      | TIMESTAMPTZ           |

O `gym_unit_id` aparentemente é redundante.

Aqui a redundância é intencional.

Ela simplifica:

* RLS;
* filtros;
* auditoria;
* defesa em profundidade.

Mas deve ser protegida por uma FK composta associando conversa + unidade.

---

# 4.3 `ai_runs`

É a principal tabela de observabilidade e auditoria do copiloto.

| Campo                   | Tipo                 |
| ----------------------- | -------------------- |
| id                      | UUID PK              |
| conversation_id         | UUID FK              |
| gym_unit_id             | UUID FK              |
| user_id                 | UUID FK              |
| request_message_id      | UUID                 |
| response_message_id     | UUID nullable        |
| intent                  | VARCHAR              |
| question                | TEXT                 |
| context_snapshot        | JSONB                |
| evidence_snapshot       | JSONB                |
| response_snapshot       | JSONB nullable       |
| provider                | VARCHAR              |
| model                   | VARCHAR              |
| prompt_version          | VARCHAR              |
| context_schema_version  | VARCHAR              |
| response_schema_version | VARCHAR              |
| status                  | ENUM                 |
| latency_ms              | INTEGER nullable     |
| input_tokens            | INTEGER nullable     |
| output_tokens           | INTEGER nullable     |
| error_code              | VARCHAR nullable     |
| started_at              | TIMESTAMPTZ          |
| completed_at            | TIMESTAMPTZ nullable |
| created_at              | TIMESTAMPTZ          |

Status:

```text
STARTED
SUCCEEDED
FAILED_PROVIDER
FAILED_TIMEOUT
FAILED_VALIDATION
INSUFFICIENT_DATA
```

Essa estrutura deriva diretamente do fluxo arquitetural de contexto estruturado → LLM → resposta estruturada → validação de evidência → auditoria. 

---

# 4.4 `AIAnalysisContext`

Não criar tabela específica.

A arquitetura já admite esse conceito sem exigir uma entidade persistente. O melhor desenho é:

```text
runtime AIAnalysisContext
            ↓
serialized immutable snapshot
            ↓
ai_runs.context_snapshot
```

Isso evita outra tabela altamente acoplada ao formato atual do Context Builder.

---

# 5. Onde usar JSON

## Usar JSONB

### `ai_runs.context_snapshot`

Porque representa um documento imutável e versionado como:

```text
facts
breakdowns
limitations
period
capability
```

### `ai_runs.evidence_snapshot`

Porque uma execução pode possuir evidências heterogêneas:

```text
unit metric
daily breakdown
hourly breakdown
member metric
```

### `ai_runs.response_snapshot`

Para armazenar a resposta estruturada original validada.

### `operational_insights.evidence_snapshot`

Adequado porque cada tipo de insight pode carregar estruturas diferentes de evidência.

---

# 6. Onde NÃO usar JSON

Não usar JSON para:

```text
members
access records
user permissions
gym units
timestamps
member status
access status
foreign keys
metric values primários
rule thresholds
period boundaries
```

Exemplo ruim:

```text
member.data = {
  "gymUnitId": "...",
  "status": "active",
  "joinedAt": "..."
}
```

Esses valores precisam participar de:

* joins;
* constraints;
* índices;
* RLS;
* agregações;
* filtros.

Portanto pertencem a colunas relacionais.

---

# 7. Soft delete

Soft delete não deverá ser aplicado indiscriminadamente.

## `members`

Usar `deleted_at`.

Mas:

```text
inactive ≠ deleted
```

Aluno que deixou de frequentar:

```text
status = INACTIVE
deactivated_at = timestamp
```

Registro excluído administrativamente:

```text
deleted_at = timestamp
```

---

## `app_users`

Pode possuir `deleted_at`.

A autenticação real também deverá ser desabilitada no Supabase Auth.

---

## `gym_units`

Pode possuir `deleted_at`, embora improvável no MVP.

---

## `access_records`

Não usar soft delete tradicional.

Como registros de acesso são fatos históricos:

```text
status = VOIDED
```

é melhor do que `deleted_at`.

Isso preserva auditabilidade.

---

## Conversas

`ai_conversations.deleted_at` pode representar remoção lógica.

Mensagens e AI runs não devem ser apagados individualmente durante o funcionamento normal porque fazem parte da trilha de auditoria.

---

# 8. Regras de integridade

Principais invariantes:

```text
member.gym_unit_id deve existir

access_record.member_id deve pertencer
ao mesmo gym_unit_id

user_gym_units só pode apontar
usuários/unidades existentes

period_start < period_end

comparison_start < comparison_end

member.deactivated_at >= member.joined_at

occurred_at deve representar timestamp válido

latency_ms >= 0

token counts >= 0

operational insight deve possuir
rule_code + rule_version

AIRun SUCCEEDED deve possuir
completed_at e response_snapshot
```

E:

```text
previous period length
=
current period length
```

quando uma métrica estiver realizando comparação equivalente.

---

# 9. Index Strategy

O volume é pequeno, então não devemos criar dezenas de índices preventivamente.

Índices principais:

### AccessRecord

```text
(gym_unit_id, occurred_at)

(member_id, occurred_at)

(gym_unit_id, member_id, occurred_at)
```

Primeiro índice:

```text
dashboard
daily distribution
hourly distribution
period comparison
```

Segundo:

```text
member frequency
last visit
individual history
```

Terceiro:

```text
member analysis dentro da unidade
```

---

### Member

```text
(gym_unit_id, status)

(gym_unit_id, joined_at)

(gym_unit_id, deactivated_at)
```

---

### UserGymUnit

```text
PK (user_id, gym_unit_id)

INDEX (gym_unit_id, user_id)
```

---

### OperationalInsight

```text
(gym_unit_id, detected_at DESC)

(gym_unit_id, type, detected_at DESC)

(gym_unit_id, subject_type, subject_id)
```

---

### AIConversation

```text
(user_id, gym_unit_id, updated_at DESC)
```

---

### AIMessage

```text
(conversation_id, created_at)
```

---

### AIRun

```text
(gym_unit_id, created_at DESC)

(conversation_id, created_at)

(status, created_at)
```

Não criar índices GIN sobre JSONB inicialmente.

Só adicionar se queries concretas passarem a consultar conteúdo interno desses snapshots.

---

# 10. RLS considerations

A arquitetura já determinou **autorização na aplicação + RLS como defesa em profundidade**. 

A regra conceitual será:

```text
auth.uid()
   ↓
user_gym_units
   ↓
gym_unit_id permitido
```

Todas as tabelas operacionais devem aplicar esse isolamento.

Exemplo conceitual:

```text
Member.gym_unit_id
AccessRecord.gym_unit_id
OperationalInsight.gym_unit_id
AIConversation.gym_unit_id
AIMessage.gym_unit_id
AIRun.gym_unit_id
```

Nenhuma política deve confiar no LLM para autorização.

O fluxo continuará:

```text
authenticated user
       ↓
authorized GymUnit
       ↓
deterministic query
       ↓
authorized facts
       ↓
AI Context Builder
       ↓
LLM
```

conforme a fronteira arquitetural aprovada. 

---

# 11. Synthetic Dataset Specification

Agora podemos desenhar o dataset.

## Parâmetros globais

```text
units:                 1
members:               500
history:               ~180 days
timezone:              America/Sao_Paulo
random seed:           fixed
access records:        ~25,000–35,000
```

Um volume nessa faixa é mais adequado do que apenas 5–10 mil registros.

Com 500 alunos, seis meses e média aproximada de 2–3 idas por semana, dezenas de milhares de acessos ainda são pequenos para PostgreSQL, mas produzem gráficos e análises muito mais convincentes.

A arquitetura já determina que o dataset seja reproduzível por `fixed random seed + scenario definitions`, permitindo encadear `dataset → expected metrics → expected insights`. Esse será o princípio central do gerador.

---

# 12. Reprodutibilidade

A geração deverá depender apenas de entradas explícitas:

```text
seed
dataset_version
as_of_date
gym_unit_id
scenario_configuration
```

Nunca:

```text
new random seed
Date.now()
Math.random() sem seed
```

Para testes oficiais, definir:

```text
dataset_version = fitness-demo-v1
seed = valor fixo
as_of_date = data fixa
```

O gerador da demonstração poderá receber outra `as_of_date`, mas a data será sempre argumento explícito.

Assim:

```text
same seed
+
same config
+
same as_of_date

=

same dataset
```

---

# 13. Perfis sintéticos de alunos

Os 500 alunos serão distribuídos em arquétipos comportamentais.

| Perfil              |    Qtde |        % | Comportamento                            |
| ------------------- | ------: | -------: | ---------------------------------------- |
| Alta frequência     |      75 |      15% | 4–6 visitas/semana                       |
| Regular             |     175 |      35% | 2–4 visitas/semana                       |
| Baixa frequência    |      75 |      15% | 0.5–2 visitas/semana                     |
| Irregular           |      75 |      15% | alternância grande entre semanas         |
| Redução progressiva |      40 |       8% | frequência cai gradualmente              |
| Abandono aparente   |      25 |       5% | frequência normal seguida por quase zero |
| Ausência prolongada |      35 |       7% | padrão prévio estável, depois desaparece |
| **Total**           | **500** | **100%** |                                          |

Esses perfis são conhecidos pelo **gerador e pelos testes**, mas não devem aparecer na aplicação como se fossem classificações reais do aluno.

Ou seja:

```text
synthetic_profile
```

não precisa existir na tabela `members` de produção.

Pode existir apenas no manifesto do dataset/fixture.

Isso impede que o produto "trapaceie" usando a resposta do gerador.

---

# 14. Padrões de frequência individual

## Alta frequência

Baseline:

```text
5 ± 1 visitas / semana
```

Baixa variância.

Preferências:

```text
06h–09h
ou
18h–21h
```

---

## Regular

Baseline:

```text
3 ± 1 visitas / semana
```

Dias relativamente estáveis.

Exemplo:

```text
segunda
quarta
sexta
```
---

## Baixa frequência

Baseline aproximado:

```text
1–1.5 visitas / semana
```

Maior chance de semanas sem registro.

Importante para evitar falso positivo de "queda":

```text
1 → 0
```

não deve automaticamente ter a mesma importância que:

```text
12 → 4
```

---

## Irregular

Média razoável, mas alta variância.

Exemplo:

```text
Semana 1: 4
Semana 2: 1
Semana 3: 5
Semana 4: 2
```

Esse perfil é especialmente importante para testar falsos positivos.

---

## Redução progressiva

Exemplo:

```text
semana -6: 4.2 visitas
semana -5: 3.8
semana -4: 3.2
semana -3: 2.7
semana -2: 2.1
semana -1: 1.4
```

Não significa cancelamento.

É apenas um comportamento observável.

Isso preserva a regra do produto de tratar abandono como sinal comportamental e nunca como previsão de cancelamento. 

---

## Abandono aparente

Exemplo:

```text
baseline:
3–4 visitas/semana

últimos 21 dias:
0 ou 1 visita
```

O nome "abandono aparente" só pertence ao dataset de testes.

O sistema deverá dizer:

```text
forte redução de frequência
```

ou:

```text
ausência prolongada
```

Nunca:

```text
este aluno abandonou
```

---

## Ausência prolongada

Baseline:

```text
2–4 visitas/semana
```

Depois:

```text
10–25 dias sem acesso
```

---

# 15. Padrão operacional da unidade

Distribuição típica dos acessos em dias úteis:

```text
06h–09h   pico matinal
09h–11h   moderado
11h–14h   pico secundário
14h–17h   baixo/moderado
17h–18h   crescimento
18h–21h   maior pico
21h–23h   redução
```

---

# 16. Dias da semana

Multiplicadores conceituais de baseline:

```text
segunda     1.12
terça       1.05
quarta      1.04
quinta      1.00
sexta       0.88
sábado      0.62
domingo     0.38
```

Não precisam representar um mercado real.

Precisam apenas produzir comportamento internamente coerente.

---

# 17. Variação natural

Mesmo sem anomalias:

```text
expected accesses
×
natural random factor
```

Exemplo:

```text
0.94–1.06
```

Pequenas variações impedem gráficos artificiais perfeitamente lisos.

O seed garante que a variação continue reproduzível.

---

# 18. Sazonalidade

O dataset deve conter sazonalidade leve, não dominante.

Exemplo mensal:

```text
Mês -6   0.97
Mês -5   1.00
Mês -4   1.03
Mês -3   1.01
Mês -2   0.98
Mês -1   1.00
```

A sazonalidade natural deve permanecer menor que as anomalias controladas.

Assim, quando houver uma queda de 15–25%, ela continuará visível.

---

# 19. Dataset Scenarios

Os cenários devem ser overlays independentes.

## SCN-BASELINE

Sem anomalia.

Serve como controle.

Expected:

```text
attendance_change ≈ pequenas variações
nenhum insight significativo
```

---

## SCN-ATTENDANCE-DROP

Últimos sete dias:

```text
-10% a -15%
```

comparados aos sete anteriores.

Expected:

```text
ATTENDANCE_DROP
```

---

## SCN-WEEKDAY-DROP

Queda concentrada em:

```text
terça
quarta
```

Por exemplo:

```text
Tuesday:   -16%
Wednesday: -19%
```

Os outros dias permanecem próximos do baseline.

---

## SCN-EVENING-DROP

Janela:

```text
18:00–20:00
```

reduzida aproximadamente:

```text
-20% a -30%
```

Enquanto:

```text
06:00–09:00
```

permanece estável.

Esse cenário é especialmente útil para a pergunta:

> "Por que a frequência caiu?"

A resposta fundamentada pode apontar que a queda está concentrada no período noturno, comportamento já previsto como exemplo de evidência na especificação. 

---

# 20. SCN-MEMBER-DECLINE

Aplicado ao grupo `progressive_decline`.

Exemplo de redução:

```text
baseline
100%

-4 weeks
85%

-3 weeks
70%

-2 weeks
55%

current
40%
```

---

# 21. SCN-PROLONGED-ABSENCE

Grupo selecionado possui:

```text
historical frequency >= 2/week
```

mas:

```text
days_since_last_visit >= 10
```

---

# 22. Cenário combinado de demonstração

A demo principal deverá utilizar cenário composto:

```text
BASELINE
+
small natural variation
+
general attendance drop
+
Tuesday/Wednesday concentration
+
18h–20h reduction
+
progressive member decline
+
prolonged absence
```

Isso cria uma narrativa muito boa:

```text
Dashboard
    ↓
"A frequência caiu"

Insight
    ↓
"-12%"

Investigação
    ↓
"onde?"

Daily breakdown
    ↓
"terça e quarta"

Hourly breakdown
    ↓
"principalmente 18h–20h"

Members
    ↓
"alguns alunos também reduziram frequência"

Copilot
    ↓
explica esses mesmos fatos
```

Sem inventar causas externas.

---

# 23. Metric Definitions

Considere um período:

```text
P = [start, end)
```

O intervalo será sempre half-open:

```text
>= start
< end
```

Isso evita duplicidade entre períodos adjacentes.

---

# 24. `active_members`

Para o MVP:

```text
active_members(P)
=
COUNT(members ativos no final de P)
```

Onde:

```text
joined_at < P.end

AND

(
 deactivated_at IS NULL
 OR
 deactivated_at >= P.end
)

AND deleted_at IS NULL
```

É uma métrica de snapshot.

---

# 25. `total_accesses`

```text
total_accesses(P)
=
COUNT(access_records)
```

onde:

```text
gym_unit_id = selected_unit
status = VALID
occurred_at >= P.start
occurred_at < P.end
```

---

# 26. `average_attendance`

Definição inicial:

```text
average_attendance(P)
=
total_accesses(P)
/
active_members(P)
```

Unidade:

```text
visitas por aluno ativo no período
```

Exemplo:

```text
1,250 accesses
500 active members

average_attendance = 2.50
```

Para 30 dias isso continua sendo "visitas por membro naquele período", não "visitas por semana".

Se quisermos uma métrica semanalizada posteriormente, ela deverá possuir outro nome.

---

# 27. `attendance_change_percentage`

Para períodos equivalentes:

```text
C = current total_accesses
R = reference total_accesses
```

Então:

```text
((C - R) / R) × 100
```

Exemplo:

```text
C = 1240
R = 1410

change =
((1240 - 1410) / 1410) × 100

≈ -12.06%
```

Esse mesmo exemplo já está previsto arquiteturalmente. 

### Edge case

Se:

```text
R = 0
```

a porcentagem será:

```text
NULL / not comparable
```

Nunca:

```text
Infinity
```

---

# 28. `daily_distribution`

Para cada data local `d`:

```text
daily_distribution[d]
=
COUNT(valid accesses on local date d)
```

Pode também retornar:

```text
count
percentage_of_period
comparison_count
change_percentage
```

---

# 29. `hourly_distribution`

Para cada hora local:

```text
h ∈ {0..23}
```

```text
hourly_distribution[h]
=
COUNT(valid accesses whose local hour = h)
```

Para a UI podem existir agrupamentos:

```text
06–09
09–12
12–15
15–18
18–21
21–23
```

Mas o dado base deve permanecer horário por horário.

---

# 30. `member_frequency`

Para permitir comparação entre 7 e 30 dias, recomendo frequência semanalizada:

```text
access_count(member, P)
×
7
/
duration_days(P)
```

Então:

```text
7 dias e 3 acessos → 3.0/week

30 dias e 12 acessos →
12 × 7 / 30
≈ 2.8/week
```

Isso facilita interpretação.

---

# 31. `member_frequency_change`

Para períodos equivalentes:

```text
FC = current frequency
FR = reference frequency
```

```text
member_frequency_change
=
((FC - FR) / FR) × 100
```

Se:

```text
FR = 0
```

retornar:

```text
not comparable
```

e não uma queda/aumento percentual artificial.

O Insight Engine deverá possuir ainda critérios de volume mínimo para impedir falsos positivos.

---

# 32. `days_since_last_visit`

Considerando um instante analítico `T`:

```text
last_visit =
MAX(valid access occurred_at <= T)
```

Então:

```text
days_since_last_visit
=
floor(
  local_date(T)
  -
  local_date(last_visit)
)
```

Se nunca houve visita:

```text
NULL
```

e pode ser classificado separadamente como:

```text
NO_VISIT_HISTORY
```

caso isso seja útil futuramente.

---

# 33. Insight Rules

Os insights são regras determinísticas sobre métricas.

Não são previsão.

Fluxo:

```text
Metric
   ↓
Rule
   ↓
Insight
   ↓
Evidence
```

---

# 34. Attendance Drop

Regra inicial:

```text
attendance_change_percentage <= -10%
```

para comparação equivalente.

### Threshold inicial

```text
-10%
```

### Motivo

Variações de poucos pontos percentuais podem ocorrer naturalmente.

Uma redução de 10% já é suficientemente grande para merecer investigação sem exigir comportamento extremamente raro.

É apenas uma heurística de MVP.

Não representa um padrão estatístico validado no mercado fitness.

### Testar

Fixtures:

```text
-5%   → no insight
-9.99% → no insight
-10%  → insight
-15%  → insight
```

Também:

```text
reference = 0
→ no percentual
→ no ATTENDANCE_DROP percentual
```

---

# 35. Member Frequency Drop

Threshold inicial:

```text
member_frequency_change <= -40%
```

A arquitetura já utilizava conceitualmente esse valor como exemplo de threshold configurável. 

Mas percentual sozinho não basta.

Regra:

```text
change <= -40%

AND

reference_access_count >= 4

AND

absolute_drop >= 2 accesses
```

para comparação de 30 dias.

### Por quê?

Evita:

```text
1 visita → 0
= -100%
```

ser automaticamente tratado como sinal tão forte quanto:

```text
10 visitas → 4
= -60%
```

### Testes

```text
10 → 7  = -30% → no signal
10 → 6  = -40% → signal
5  → 3  = -40% → signal
1  → 0  = -100% → no signal por baseline insuficiente
```

---

# 36. Prolonged Absence

Threshold inicial:

```text
10 dias
```

Regra:

```text
member.status = ACTIVE

AND

days_since_last_visit >= 10

AND

historical_frequency >= 1 visit/week
```

A arquitetura também usa 10 dias como exemplo conceitual. 

### Motivo

Um aluno que normalmente frequenta 2–4 vezes por semana e passa dez dias sem acesso apresenta um comportamento objetivamente diferente do padrão.

Mas ainda não sabemos:

* se está viajando;
* se está doente;
* se mudou de horário;
* se deseja cancelar.

Portanto:

> ausência prolongada é observação, não previsão de churn.

### Testes

```text
9 dias  → no signal
10 dias → signal

15 dias sem visita,
mas frequência histórica 0.3/week
→ não sinalizar inicialmente
```

---

# 37. Unusually Low Occupancy

Não devemos definir "ocupação baixa" apenas como:

```text
menos de X pessoas
```

porque um horário naturalmente vazio sempre dispararia.

A primeira regra deve detectar **mudança significativa em um horário que normalmente possui utilização relevante**.

Configuração:

```text
hourly_change <= -25%

AND

reference_share_of_accesses >= 5%

AND

reference_count >= 20
```

### Motivo

O filtro de baseline garante que:

```text
03h00:
2 → 0
```

não se torne um grande insight.

Enquanto:

```text
18h–20h:
280 → 195
```

merece investigação.

### Testes

```text
-15% → no insight
-24.9% → no insight
-25% → insight

-60% com baseline de 3 acessos
→ no insight
```

---

# 38. Initial Threshold Configuration

Configuração inicial:

```text
ATTENDANCE_DROP
change_percentage = -10%

MEMBER_FREQUENCY_DROP
change_percentage = -40%
minimum_reference_accesses = 4
minimum_absolute_drop = 2

PROLONGED_ABSENCE
days = 10
minimum_historical_frequency = 1.0/week

UNUSUALLY_LOW_OCCUPANCY
change_percentage = -25%
minimum_reference_share = 5%
minimum_reference_count = 20
```

---

# 39. Onde armazenar thresholds?

Para o MVP:

> **não recomendo uma tabela configurável pelo usuário ainda.**

Manter como configuração tipada e versionada do Insight Engine.

Exemplo conceitual:

```text
rule set:
MVP_RULES_V1
```

Cada insight persistido registra:

```text
rule_code
rule_version
```

e seu evidence snapshot registra os thresholds relevantes.

Benefícios:

* testes reproduzíveis;
* ninguém altera regras durante uma demo;
* versão das regras fica no Git;
* menor superfície administrativa.

Se futuramente cada unidade precisar configurar thresholds, aí faz sentido criar:

```text
insight_rule_configs
```

---

# 40. Expected Known Anomalies

O dataset de demonstração deverá possuir um manifesto de anomalias conhecidas.

Por exemplo:

| ID  | Situação conhecida                                         |
| --- | ---------------------------------------------------------- |
| A01 | queda geral >10% no último período de 7 dias               |
| A02 | terça-feira significativamente abaixo do período anterior  |
| A03 | quarta-feira significativamente abaixo                     |
| A04 | 18h–20h com queda >25%                                     |
| A05 | grupo de membros com redução ≥40%                          |
| A06 | membros ativos com ≥10 dias sem visita                     |
| A07 | manhã permanece aproximadamente estável                    |
| A08 | finais de semana naturalmente menores                      |
| A09 | alguns alunos irregulares não devem gerar falsos positivos |
| A10 | baseline sem anomalia não deve disparar insight            |

Isso vira o contrato de teste do dataset.

---

# 41. Test Fixtures Strategy

Teremos diferentes níveis.

## Fixture 1 — Micro
Pouquíssimos registros.

Exemplo:

```text
1 unit
3 members
20 accesses
```

Usada para testar matematicamente uma função.

---

## Fixture 2 — Rule Boundary

Criada especificamente para thresholds.

Exemplo:

```text
attendance drop:
-9.99%
-10%
-10.01%
```

Isso testa fronteiras.

---

## Fixture 3 — Member Behaviour

Um membro por cenário:

```text
stable
declining
irregular
absent
```

Permite testar regras isoladamente.

---

## Fixture 4 — Full Synthetic Dataset

```text
1 gym
500 members
6 months
~30k accesses
```

Usada para:

* integração;
* dashboard;
* performance;
* demonstração;
* E2E;
* IA.

---

# 42. Golden Dataset

O dataset completo deverá produzir um arquivo/manifesto conceitual de resultados esperados:

```text
dataset version

seed

as_of_date

expected:
  active_members
  total_accesses_7d
  total_accesses_previous_7d
  attendance_change_7d

  total_accesses_30d
  ...

  expected_insights

  expected_member_signals

  expected_peak_hours
```

Isso cria testes muito fortes:

```text
generate dataset
      ↓
Metrics Engine
      ↓
actual metrics

compare

expected metrics
```

Depois:

```text
metrics
  ↓
Insight Engine
  ↓
actual insights

compare

expected insights
```

A estratégia está diretamente alinhada à arquitetura, que prioriza testes unitários de métricas, regras, comparação de períodos e geração de evidências.

---

# 43. Testes do copiloto usando o mesmo dataset

O Golden Dataset também resolve um problema importante da IA.

Sabemos previamente que:

```text
attendance = down

Tuesday = down

Wednesday = down

18h–20h = down

morning = stable
```

Então uma avaliação da IA pode verificar propriedades:

```text
resposta cita evidências existentes?

mantém -12% como -12%?

menciona 18h–20h somente se estava no contexto?

inventa chuva?

inventa preço?

afirma cancelamento?

reconhece ausência de dados causais?
```

A arquitetura já determina exatamente esse estilo de teste: testar propriedades da resposta e não igualdade literal de texto.

---

# 44. Database Risks

## Risco 1 — métricas históricas mudarem retroativamente

Causa:

```text
usar status atual do Member
```

Mitigação:

```text
joined_at
deactivated_at
```

---

## Risco 2 — timezone incorreto

Pode alterar:

* datas;
* dia da semana;
* horários de pico.

Mitigação:

```text
gym_units.timezone
+
conversão explícita
```

---

## Risco 3 — inconsistência `member_id/gym_unit_id`

Mitigação:

```text
composite foreign key
```

---

## Risco 4 — JSON virar banco dentro do banco

Mitigação:

usar JSON somente para snapshots heterogêneos e imutáveis.

---

## Risco 5 — operational insights ficarem stale

Mitigação:

tratá-los como snapshots derivados, nunca como verdade operacional.

---

## Risco 6 — synthetic dataset "entregar a resposta"

Se o perfil sintético for persistido no Member:

```text
behavior = "churn"
```

o sistema poderia acidentalmente usar essa informação.

Mitigação:

labels de geração ficam fora do modelo operacional.

---

## Risco 7 — regra de frequência gerar falsos positivos

Exemplo:

```text
1 → 0 = -100%
```

Mitigação:

baseline mínimo + queda absoluta mínima.

---

## Risco 8 — soft delete distorcer fatos

Mitigação:

não soft-delete AccessRecords.

Usar:

```text
VALID
VOIDED
```

---

## Risco 9 — RLS excessivamente complexa

A própria arquitetura já identifica políticas RLS incorretas como risco relevante.

Mitigação:

manter:

```text
User
→ UserGymUnit
→ gym_unit_id
```

como única fronteira principal de tenancy e testar as políticas em integração.

---

# 45. ADRs relacionados aos dados

Proponho adicionar estes ADRs aos ADRs arquiteturais já aprovados.

## ADR-013 — Tenant Key on Operational Data

**Status:** Proposed → Recommended Accepted

### Decision

Todas as entidades operacionais relevantes possuirão `gym_unit_id`.

### Reason

RLS, autorização, query performance e futura expansão multiunidade.

### Consequence

Há pequena redundância em algumas tabelas, mas a fronteira de tenancy fica explícita.

---

# ADR-014 — AccessRecord as Immutable Fact

**Decision**

Registros de acesso são fatos históricos.

Não serão soft-deleted.

Correções serão representadas por:

```text
status = VOIDED
```

### Reason

Auditabilidade e métricas reproduzíveis.

---

# ADR-015 — Metrics Are Not Persisted

**Decision**

Métricas do dashboard não serão persistidas inicialmente.

### Reason

O volume permite cálculo rápido e determinístico.

Evita cache e materialização prematuros.

### Consequence

PostgreSQL realiza agregações; Metrics Engine realiza semântica e comparação, conforme a estratégia híbrida já estabelecida. 

---

# ADR-016 — Operational Insights as Derived Snapshots

**Decision**

`operational_insights` poderá ser persistido, mas somente como snapshot de uma detecção reproduzível.

### Source of truth

```text
raw facts
+
Metrics Engine
+
rule version
```

### Não source of truth

```text
operational_insights row
```

---

# ADR-017 — Historical Membership Window

**Decision**

Member terá:

```text
joined_at
deactivated_at
```

além do status atual.

### Reason

Evitar alteração retroativa de métricas históricas.

---

# ADR-018 — JSON Only for Flexible Snapshots

**Decision**

JSONB será restrito principalmente a:

```text
AI context snapshot
AI evidence snapshot
AI structured response
Insight evidence snapshot
```

Entidades operacionais permanecerão relacionais.

---

# ADR-019 — Deterministic Synthetic Dataset

**Decision**

Todo dataset sintético será identificado por:

```text
dataset_version
seed
as_of_date
scenario configuration
```

### Reason

Reprodutibilidade, testes e apresentação consistente.

---

# ADR-020 — Synthetic Labels Are Test Metadata

**Decision**

Labels como:

```text
high_frequency
progressive_decline
apparent_abandonment
```

não serão armazenados no modelo operacional utilizado pelo produto.

### Reason

Evitar data leakage e garantir que o Metrics/Insight Engine realmente descubra o comportamento.

---

# ADR-021 — Versioned Insight Rules

**Decision**

Thresholds do MVP serão configuração versionada da aplicação.

Cada insight armazenará sua `rule_version`.

### Reason

Testabilidade e rastreabilidade.

Configuração administrativa em banco fica fora do MVP.

---

# 46. Modelo final recomendado

A estrutura que eu congelaria para a próxima etapa é:

```text
auth.users
     │
     ▼
app_users
     │
     ▼
user_gym_units
     │
     ▼
gym_units
     │
     ├── members
     │      │
     │      └── access_records
     │
     ├── operational_insights
     │
     └── ai_conversations
            │
            ├── ai_messages
            │
            └── ai_runs
```

Com as seguintes fronteiras:

```text
members + access_records
        =
fatos operacionais

Metrics Engine
        =
fatos derivados

OperationalInsight
        =
snapshot de situação detectada

AIRun
        =
snapshot de interpretação realizada

LLM
        =
nenhum fato novo
```

---

# 47. Resultado da fase de Data Design

Com esta modelagem, o fluxo completo fica bem definido:

```text
Synthetic Dataset
       ↓
Members + AccessRecords
       ↓
PostgreSQL
       ↓
Metrics Engine
       ↓
deterministic metrics
       ↓
Insight Engine
       ↓
deterministic signals
       ↓
Evidence
       ↓
AI Context Builder
       ↓
LLM
       ↓
natural-language interpretation
       ↓
AI Run Audit
```

Isso preserva integralmente a arquitetura aprovada, em especial o princípio de que a IA não é a fonte da verdade operacional. 

A próxima etapa técnica natural, **ainda antes das migrations**, é transformar este documento em um **Database Contract v0.1**: tabela por tabela, com nomes finais de colunas, enums, nullability, unique constraints, FKs compostas e invariantes formais. Depois disso, as migrations deixam de ser uma atividade de design e passam a ser apenas tradução desse contrato para PostgreSQL.
