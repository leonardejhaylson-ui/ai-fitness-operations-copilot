# AI Fitness Operations Copilot

## UI Screen Specification — v0.1

**Status:** pronta para implementação de frontend após resolução das Open Questions classificadas como não bloqueantes.

**Idioma da interface:** PT-BR.

**Princípio estrutural:**

> O software calcula fatos.
> O Insight Engine detecta situações.
> A IA interpreta fatos e situações.
> O frontend apresenta, navega e preserva contexto.

O frontend **não calcula métricas de negócio**, **não determina severidade**, **não infere causalidade** e **não converte ausência de dados em conclusão**.

---

# 1. Critical Blockers — Resolução normativa

## 1.1 Average Attendance

A métrica canônica permanece:

`total_accesses / active_members`

Sua unidade é:

**visitas por aluno ativo no período selecionado**.

Isso vale tanto para 7 quanto para 30 dias. Em 30 dias, a métrica continua representando visitas por aluno ativo naquele período e **não visitas por semana**.

### Copy canônica

**Label**

> Visitas médias por aluno ativo

**Supporting text**

> no período selecionado

Exemplo:

> **2,5**
> Visitas médias por aluno ativo
> Últimos 30 dias

Não utilizar:

- `/semana`;
- `por semana`;
- `frequência semanal média`;
- `média semanal`;

para essa métrica.

A métrica individual de frequência de aluno pode continuar semanalizada, pois é um conceito distinto.

---

# 2. Terminologia de distribuição horária

Os dados disponíveis registram entradas/acessos. Eles não registram saída, duração de permanência nem pessoas presentes simultaneamente.

A métrica horária conta acessos válidos por hora/faixa horária.

## Terminologia canônica

### Nome principal da seção

**Distribuição de acessos por horário**

### Termos auxiliares permitidos

- fluxo de acessos;
- volume de acessos;
- horários com maior volume de acessos;
- horários com menor volume de acessos;
- utilização por horário baseada em acessos.

### Termos proibidos como representação direta da métrica

- ocupação;
- lotação;
- academia cheia;
- número de pessoas presentes;
- capacidade utilizada;
- presença simultânea.

Se a palavra “ocupação” aparecer em artefatos internos ou nomes de regra legados, não deve ser refletida diretamente na UI.

### Limitação canônica

Quando necessário:

> Os dados representam registros de acesso por horário e não medem quantas pessoas permaneceram simultaneamente na unidade.

---

# 3. Modelo canônico de Situações

O termo **Attention** deixa de existir na interface PT-BR.

Quatro conceitos diferentes passam a ter nomes próprios.

| ConceitoLabel canônico                                   |                               |
| -------------------------------------------------------- | ----------------------------- |
| Área do produto                                          | **Situações**                 |
| Quantidade de insights atualmente ativos                 | **Situações ativas**          |
| Quantidade de alunos únicos atingidos por regra de aluno | **Alunos com situação ativa** |
| Classificação de um insight                              | **Severidade**                |

## Badge da navegação

Exemplo:

> Situações **4**

O número significa exclusivamente:

**quantidade de situações ativas no período/contexto atual e visíveis ao usuário.**

Não é:

- quantidade de alunos;
- quantidade de evidências;
- soma de regras disparadas por aluno;
- severidade;
- notificações não lidas.

Uma situação resolvida não entra na contagem.

Itens INFO não entram nessa contagem.

---

# 4. Severity Mapping v0.1

A severidade pertence ao Insight Engine.

O frontend recebe a severidade pronta.

O frontend nunca pode transformar magnitude em severidade por conta própria.

Os thresholds básicos das regras existentes permanecem os aprovados: queda geral de 10%, queda individual de 40% com baseline mínimo, ausência de 10 dias e queda horária de 25% com baseline relevante.

## 4.1 Semântica dos níveis

### INFO

Informação contextual não acionável.

No MVP:

- não gera “situação ativa”;
- não aparece por padrão na página Situações;
- não entra no badge da navegação;
- pode aparecer apenas como contexto complementar de outra situação.

Não haverá regras independentes INFO no Rule Set v0.1.

### WARNING

Situação determinística que cruzou o threshold inicial da regra e merece investigação.

UI:

**Atenção**

### HIGH

Situação cuja magnitude cruza um segundo threshold determinístico.

UI:

**Alta**

Não utilizar:

- crítica;
- urgente;
- emergência;
- risco alto;

porque essas expressões implicam interpretação operacional adicional.

---

## 4.2 Mapping determinístico

| Rule code internoWARNINGHIGH |                                                                       |                                                                    |
| ---------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `ATTENDANCE_DROP`            | variação ≤ -10% e > -20%                                              | variação ≤ -20%                                                    |
| `MEMBER_FREQUENCY_DROP`      | variação ≤ -40% e > -60%, baseline ≥ 4 acessos e queda absoluta ≥ 2   | variação ≤ -60%, mantendo baseline ≥ 4 e queda absoluta ≥ 2        |
| `PROLONGED_ABSENCE`          | 10–20 dias sem acesso e frequência histórica ≥ 1 visita/semana        | ≥ 21 dias sem acesso e frequência histórica ≥ 1 visita/semana      |
| `UNUSUALLY_LOW_OCCUPANCY`\*  | variação horária ≤ -25% e > -40%, share baseline ≥ 5% e baseline ≥ 20 | variação horária ≤ -40%, mantendo os mesmos requisitos de baseline |

\* O nome interno pode permanecer por compatibilidade. Na UI o tipo será apresentado como **Redução relevante no fluxo de acessos por horário**.

### Regra de fronteira

Valores exatamente no threshold pertencem ao nível mais alto aplicável.

Exemplo:

- -19,9% → WARNING;
- -20,0% → HIGH.

### Sem comparação válida

Quando o valor de referência necessário for zero ou indisponível:

- nenhuma severidade percentual é criada;
- UI recebe `comparison_unavailable`;
- não há fallback inventado pelo frontend.

---

# 5. Glossário UI PT-BR

| Conceito internoUI PT-BR |                                     |
| ------------------------ | ----------------------------------- |
| Overview                 | Visão geral                         |
| Attendance               | Frequência                          |
| Members                  | Alunos                              |
| Member                   | Aluno                               |
| Attention / Insights     | Situações                           |
| Insight                  | Situação                            |
| Active insights          | Situações ativas                    |
| Severity                 | Severidade                          |
| Warning                  | Atenção                             |
| High                     | Alta                                |
| Info                     | Informação                          |
| Active members           | Alunos ativos                       |
| Accesses                 | Acessos                             |
| Average attendance       | Visitas médias por aluno ativo      |
| Attendance change        | Variação de acessos                 |
| Previous period          | Período anterior                    |
| Current period           | Período atual                       |
| Hourly distribution      | Distribuição de acessos por horário |
| Flow                     | Fluxo de acessos                    |
| Last visit               | Último acesso                       |
| Frequency reduction      | Redução de frequência               |
| Prolonged absence        | Ausência prolongada                 |
| Evidence                 | Evidências                          |
| Current context          | Contexto da análise                 |
| Limitations              | Limitações                          |
| Copilot                  | Copiloto                            |
| Insufficient data        | Dados insuficientes                 |
| Stale data               | Dados possivelmente desatualizados  |

## Vocabulário canônico de ações

Usar:

- **Investigar**
- **Ver evidências**
- **Abrir aluno**
- **Ver frequência**
- **Ver alunos**
- **Perguntar ao Copiloto**
- **Alterar contexto**
- **Limpar filtros**
- **Tentar novamente**
- **Voltar**
- **Entrar**
- **Sair**

Evitar variações para a mesma intenção, como:

- Ver análise;
- Explorar;
- Abrir análise;
- Ask Copilot;
- Open in Attendance.

---

# 6. Canonical Content Ownership Matrix

A mesma informação pode ser referenciada em várias telas, mas apenas uma superfície é responsável por sua apresentação completa.

| ConteúdoOwner canônicoOutras telas                     |                               |                                                      |
| ------------------------------------------------------ | ----------------------------- | ---------------------------------------------------- |
| Estado resumido da unidade                             | Visão geral                   | somente link/resumo                                  |
| Métricas principais                                    | Visão geral                   | frequência pode repetir somente métricas pertinentes |
| Série temporal de acessos                              | Frequência                    | Visão geral recebe versão resumida                   |
| Decomposição por dia                                   | Frequência                    | resumo em evidências                                 |
| Distribuição por horário                               | Frequência                    | Visão geral recebe síntese                           |
| Lista completa de alunos                               | Alunos                        | outras telas apenas subconjunto/link                 |
| Frequência individual                                  | Detalhe do aluno              | tabelas mostram resumo                               |
| Visitas recentes do aluno                              | Detalhe do aluno              | outras telas não duplicam                            |
| Lista completa de situações                            | Situações                     | Visão geral exibe máximo 3–5                         |
| Regra + snapshot de evidência de uma situação complexa | Detalhe de situação           | somente quando página dedicada for necessária        |
| Interpretação em linguagem natural                     | Copiloto                      | nenhuma outra tela replica conversação               |
| Evidências determinísticas usadas pela IA              | tela determinística de origem | Copiloto referencia e linka                          |
| Causalidade                                            | nenhuma                       | somente limitação explícita                          |

### Regra

**Resumo nunca vira segunda implementação do conteúdo canônico.**

Exemplo:

Visão geral pode mostrar:

> Acessos -12,1%

Mas a decomposição completa por dia/horário pertence à Frequência.

---

# 7. Navigation v0.2

## Desktop

Sidebar:

1. **Visão geral**
2. **Frequência**
3. **Alunos**
4. **Situações** `N`
5. divisor
6. **Copiloto**

O divisor reforça que o Copiloto direto é uma superfície complementar.

O principal acesso ao Copiloto continua ocorrendo por ações contextuais como:

> Perguntar ao Copiloto

## Rotas conceituais

Labels de UI permanecem em português; nomes internos podem permanecer em inglês.

- Login → `/login`
- Visão geral → `/overview`
- Frequência → `/attendance`
- Alunos → `/members`
- Aluno → `/members/:memberId`
- Situações → `/insights`
- Situação dedicada → `/insights/:insightId`
- Copiloto → `/copilot`
- Conversa existente → `/copilot/:conversationId`

## Navegação profunda

Breadcrumb apenas quando necessário:

> Alunos / Ana Souza

ou:

> Situações / Queda de acessos

Não mostrar breadcrumb em telas de primeiro nível.

---

# 8. Insight Detail — regra de existência

A página Detalhe de situação **não é obrigatória para toda situação**.

## Abrir diretamente Frequência quando

A situação:

- é `ATTENDANCE_DROP`;
- é redução de fluxo por horário;
- depende somente de decomposição temporal já pertencente à Frequência.

A página recebe:

- período original;
- situação de origem;
- trecho/horário destacado;
- link de retorno para Situações.

## Abrir diretamente Alunos filtrado quando

A situação representa:

- conjunto de alunos com queda de frequência;
- conjunto relacionado por uma regra de membro.

O filtro derivado da situação fica visível.

## Abrir diretamente Detalhe do aluno quando

A situação possui exatamente um aluno como subject.

## Criar Detalhe de situação dedicado quando

Pelo menos uma condição é verdadeira:

1. evidências combinam múltiplas entidades ou superfícies;
2. a explicação da regra é importante para compreender o sinal;
3. não existe uma tela canônica que consiga representar o evidence snapshot completo;
4. o snapshot histórico precisa ser preservado independentemente do estado atual.

Não criar uma página intermediária apenas para repetir métricas.

---

# 9. Causalidade e linguagem analítica

O sistema pode responder:

- o que mudou;
- quando mudou;
- onde a mudança se concentrou;
- quais alunos participaram da mudança observada;
- quais horários apresentaram maior variação;
- quais dados sustentam a observação.

O sistema não pode concluir causa sem dados causais.

## Copy recomendada

> A queda se concentrou principalmente na terça e quarta-feira.

> O período entre 18:00 e 20:00 apresentou redução maior que as demais faixas.

> 18 alunos atenderam à regra de redução relevante de frequência.

## Quando perguntado “por quê?”

Resposta deve separar:

**O que os dados mostram**

de:

**O que os dados não permitem determinar**

Exemplo:

> Os dados mostram que a redução se concentrou principalmente na terça e quarta-feira, com maior queda entre 18:00 e 20:00. Os dados disponíveis não permitem determinar a causa dessa mudança, pois não incluem informações como clima, campanhas, alterações de preço ou motivos declarados pelos alunos.

Nunca substituir “causa desconhecida” por correlação.

---

# 10. Copilot Context Contract v0.1

O contexto do Copiloto possui duas camadas:

## 10.1 Conversation Context

Estado atual da conversa.

Pode conter:

- `gym_unit`;
- período selecionado;
- rota/origem;
- entidade;
- situação selecionada.

É exibido ao usuário como:

**Contexto da análise**

Exemplo:

> Unidade Centro
> Frequência
> Últimos 7 dias
> Situação: queda de acessos

## 10.2 Run Context Snapshot

Cada envio cria um snapshot imutável.

Cada execução deve registrar, no mínimo:

- unidade;
- usuário autorizado;
- período atual;
- período de comparação;
- rota de origem;
- entidade, se houver;
- situação, se houver;
- IDs das métricas/evidências utilizadas;
- timestamp da execução.

Uma resposta antiga nunca muda de significado quando o contexto atual é alterado.

---

## 10.3 Contexto herdado

### Da Visão geral

Herdar:

- unidade;
- período;
- situação, se acionada por uma situação.

### Da Frequência

Herdar:

- unidade;
- período;
- comparison period;
- seção/filtro temporal relevante;
- situação originadora, se houver.

### De Aluno

Herdar:

- unidade;
- aluno;
- período;
- situação originadora, se houver.

### De Situação

Herdar:

- unidade;
- insight ID;
- rule version;
- período;
- evidence snapshot;
- subject.

---

# 11. Alteração de contexto do Copiloto

O usuário pode alterar:

- período;
- entidade;
- situação;

dentro da mesma conversa.

Cada alteração cria uma nova **versão de contexto** para execuções futuras.

Não altera mensagens anteriores.

## UI

Ao alterar:

> Contexto atualizado para: Ana Souza · Últimos 30 dias

Não inserir essa mudança como fala artificial do Copiloto.

## Evidências antigas

Continuam:

- visíveis;
- clicáveis;
- associadas ao snapshot original.

Mostrar metadata:

> Evidência referente ao contexto desta resposta: últimos 7 dias

Não reinterpretar automaticamente evidência antiga sob novo período.

---

# 12. Página direta do Copiloto

É secundária.

Quando acessada sem contexto herdado:

Contexto inicial:

- unidade;
- período padrão: 7 dias;
- nenhuma entidade;
- nenhuma situação.

Título:

> **Investigue os dados da unidade**

Supporting copy:

> Faça uma pergunta sobre frequência, alunos, situações detectadas ou distribuição de acessos.

Sugestões:

- O que mudou nos últimos 7 dias?
- Onde a frequência mais mudou?
- Quais alunos apresentam redução relevante?
- Quais situações estão ativas?

Evitar:

> Por que a frequência caiu?

como sugestão inicial, pois induz expectativa causal.

---

# 13. Histórico do Copiloto

Histórico é de **conversas**, não apenas lista global de mensagens.

Cada item apresenta:

- título sintético;
- data da última execução;
- contexto inicial resumido.

Exemplo:

> Queda de acessos — últimos 7 dias
> 19 set 2026, 10:42

O histórico não ganha protagonismo visual equivalente a um aplicativo de chat.

---

# 14. Evidence Contract

Uma resposta analítica deve apresentar, quando disponíveis:

1. conclusão/interpretação;
2. evidências;
3. período;
4. comparação;
5. limitações.

A UX aprovada exige evidência próxima da conclusão.

## Estrutura

**Resposta**

> A redução se concentrou principalmente na terça e quarta-feira.

**Evidências**

> Acessos totais: -12,1%
> Terça-feira: -15,0%
> Quarta-feira: -18,0%
> 18:00–20:00: -21,0%

**Período**

> 12–18 set 2026
> Comparado com 5–11 set 2026

**Limitação**

> Os dados disponíveis não permitem determinar a causa da redução.

Evidência deve oferecer:

**Ver frequência**, **Abrir aluno** ou equivalente conforme sua origem.

---

# 15. State Matrix

Estados não devem ser inferidos visualmente. Sempre que possível, backend/API envia metadata explícita.

## 15.1 Metric Strip

| EstadoComportamento    |                                                                          |
| ---------------------- | ------------------------------------------------------------------------ |
| Default                | valores + comparação pertinente                                          |
| Loading                | skeleton preservando largura e altura                                    |
| Empty                  | `—` + “Sem dados no período”                                             |
| Partial                | métricas válidas permanecem; bloco afetado sinaliza indisponibilidade    |
| Comparison unavailable | valor atual permanece; “Comparação indisponível”                         |
| Error                  | bloco específico + Tentar novamente                                      |
| Unauthorized           | não renderizar dados; estado de página                                   |
| Stale                  | manter último valor com “Dados possivelmente desatualizados” e timestamp |
| AI unavailable         | sem efeito                                                               |
| Insufficient data      | valor disponível continua; derived metric mostra “Dados insuficientes”   |

## 15.2 Gráficos

| EstadoComportamento    |                                              |
| ---------------------- | -------------------------------------------- |
| Default                | gráfico completo                             |
| Loading                | área final reservada + skeleton              |
| Empty                  | nenhuma plotagem; texto explicativo          |
| Partial data           | gaps reais; nunca interpolar silenciosamente |
| Comparison unavailable | somente série atual                          |
| Error                  | placeholder analítico + Tentar novamente     |
| Unauthorized           | página bloqueada                             |
| Stale                  | gráfico mantido com metadata                 |
| AI unavailable         | sem efeito                                   |
| Insufficient data      | não gerar tendência artificial               |

## 15.3 Distribuição horária

Mesmas regras de gráficos.

Quando existem acessos válidos, mas algumas horas têm `0`, mostrar **0**, não `null`.

`null` significa dado ausente/desconhecido.

## 15.4 Tabela de alunos

| EstadoComportamento    |                                                           |
| ---------------------- | --------------------------------------------------------- |
| Default                | linhas paginadas                                          |
| Loading                | cabeçalho e filtros preservados; skeleton só nas linhas   |
| Empty                  | “Nenhum aluno encontrado”                                 |
| Partial                | linhas disponíveis + mensagem de limitação                |
| Comparison unavailable | coluna Variação mostra `—` + tooltip                      |
| Error                  | filtros permanecem; tabela mostra erro + Tentar novamente |
| Unauthorized           | estado de página                                          |
| Stale                  | dados preservados com aviso                               |
| AI unavailable         | sem efeito                                                |
| Insufficient data      | campos analíticos específicos usam `—`                    |

## 15.5 Lista de situações

| EstadoComportamento    |                                                     |
| ---------------------- | --------------------------------------------------- |
| Default                | WARNING/HIGH ordenadas deterministicamente          |
| Loading                | skeleton de linhas                                  |
| Empty                  | “Nenhuma situação relevante detectada”              |
| Partial                | situações válidas + indicação de regra indisponível |
| Comparison unavailable | regra dependente de comparação não cria situação    |
| Error                  | mensagem de sistema                                 |
| Unauthorized           | estado de página                                    |
| Stale                  | snapshot marcado                                    |
| AI unavailable         | lista continua funcionando                          |
| Insufficient data      | nenhuma situação falsa é gerada                     |

## 15.6 Evidências

Evidence inexistente não pode ser substituída por texto do LLM.

Estado:

> Evidência indisponível para esta afirmação.

A conclusão deve ser rebaixada ou omitida se a arquitetura exigir evidência para esse tipo de resposta.

## 15.7 Copiloto

| EstadoComportamento    |                                                                                  |
| ---------------------- | -------------------------------------------------------------------------------- |
| Default                | composer + contexto + histórico da conversa                                      |
| Loading                | pergunta permanece; “Analisando dados…”                                          |
| Empty                  | sugestões contextuais                                                            |
| Partial                | resposta identifica limitações                                                   |
| Comparison unavailable | explica impossibilidade de comparar                                              |
| Error                  | mensagem funcional + Tentar novamente                                            |
| Unauthorized           | pergunta não executa                                                             |
| Stale                  | evidência mostra timestamp                                                       |
| AI unavailable         | “Copiloto temporariamente indisponível”; restante do produto permanece funcional |
| Insufficient data      | resultado analítico válido, não erro                                             |

---

# 16. Freshness / stale contract

A UI não cria um limite temporal arbitrário para considerar dado stale.

O backend fornece:

- `generated_at`;
- `stale`;
- opcionalmente `snapshot_id`.

## Timestamp global

Somente mostrar:

> Dados consultados em 19 set 2026, 10:42

se os principais blocos da tela pertencem ao mesmo snapshot.

Se houver carga parcial, refresh falho ou snapshots diferentes:

- remover timestamp global;
- exibir timestamps no componente afetado.

Isso evita falsa impressão de consistência.

---

# 17. Chart Specification

Somente três famílias de visualização fazem parte do MVP:

1. linha temporal;
2. barras categóricas;
3. matriz/distribuição horária.

Não adicionar:

- donut;
- gauge;
- radar;
- area decorativa;
- sparklines gratuitas.

---

# 18. Gráfico 1 — Evolução de acessos

## Finalidade

Responder:

> Como o volume de acessos mudou ao longo do período?

## Dados

`daily_distribution`

Série:

- período atual;
- período anterior equivalente.

## Eixo X

Datas locais da unidade.

7 dias:

- um ponto por dia.

30 dias:

- um ponto por dia.

## Eixo Y

Quantidade de acessos.

Unidade:

**acessos**

## Escala

Linear.

Baseline:

**0 obrigatório** quando a visualização usar preenchimento ou quando a escala truncada produzir leitura enganosa.

Para line chart puro, a escala pode usar domínio otimizado desde que o eixo mostre valores explícitos e não exagere visualmente variações mínimas.

## Current vs previous

Atual:

- Action 700;
- linha sólida;
- 2px.

Anterior:

- Neutral 400;
- linha tracejada;
- 1,5px.

Não usar duas cores semanticamente diferentes.

## Null

Null:

- quebra de linha;
- sem interpolação.

0:

- valor real em zero.

## Tooltip

Exemplo:

> 18 set 2026
> Atual: 182 acessos
> Anterior: 205 acessos
> Variação: -11,2%

## Legenda

- Período atual
- Período anterior

## Loading

Skeleton com altura final.

## Empty

> Sem acessos registrados neste período.

## Mobile

Gráfico mantém eixo temporal.

Permitir scroll horizontal apenas se a legibilidade exigir; não comprimir labels até sobreposição.

## Acessibilidade

- descrição textual;
- valores acessíveis por teclado quando biblioteca permitir;
- não depender de cor;
- tabela alternativa.

## Alternativa tabular

Data | Atual | Anterior | Variação.

---

# 19. Gráfico 2 — Distribuição por dia

## Finalidade

Responder:

> Em quais dias o volume ou a variação se concentrou?

## Dados

`daily_distribution`

## X

Dia/data.

## Y

Acessos.

## Tipo

Barras verticais ou horizontais conforme espaço.

## Zero baseline

Obrigatório.

## Comparação

Preferência:

- barra atual;
- valor anterior em tooltip/label secundário.

Evitar pares de barras excessivamente densos quando houver 30 dias.

## Null

Sem barra + indicação de dado indisponível.

## Tooltip

> Terça, 15 set
> Atual: 164
> Anterior: 193
> Variação: -15,0%

## Mobile

Barras horizontais são permitidas para preservar labels.

## Alternativa

Tabela diária.

---

# 20. Gráfico 3 — Distribuição de acessos por horário

## Finalidade

Responder:

> Em quais horários os acessos se concentram e quais horários mudaram?

## Dados base

Contagem válida por hora local.

A UI pode agregar nas faixas já aprovadas:
- 06:00–09:00
- 09:00–12:00
- 12:00–15:00
- 15:00–18:00
- 18:00–21:00
- 21:00–23:00

O dado base permanece hora por hora.

## Desktop ≥1280

Matriz:

- Y = dia da semana;
- X = hora/faixa;
- intensidade = quantidade de acessos.

## Escala

Escala sequencial baseada no maior valor do período exibido.

Zero recebe tratamento visual mínimo.

Não utilizar vermelho/verde como escala.

## Tooltip

> Terça · 18:00–19:00
> 42 acessos
> Período anterior: 53
> Variação: -20,8%

## Null

Célula com marcador `—`.

## Zero

Célula com valor 0 acessível via tooltip/texto.

## Mobile

Não renderizar matriz comprimida.

Trocar para barras por uma das seis faixas horárias aprovadas.

## Acessibilidade

- contraste de intensidade;
- valor textual;
- não depender só de cor;
- tabela alternativa.

---

# 21. Members Table Specification

## Page size

Padrão:

**25 alunos**

Opções:

- 25
- 50

Não carregar 500 registros em uma única tabela visual.

## Paginação

Paginação por página.

Mostrar:

> 1–25 de 482

Ações:

- anterior;
- próxima;
- número da página quando desktop permitir.

Ao alterar filtro, voltar para página 1.

---

# 22. Busca

Campo:

> Buscar por nome ou código

Busca por:

- `display_name`;
- `member_code`.

Debounce pode existir na implementação, mas não altera contrato de UX.

---

# 23. Filtros

Padrão:

**Status**

- Todos
- Ativo
- Inativo

**Situação de frequência**

- Todas
- Redução relevante
- Ausência prolongada
- Sem situação ativa

Quando aberta por uma situação, filtros derivados aparecem como:

> Filtro da investigação: Redução relevante de frequência

Ação:

**Limpar filtros**

---

# 24. Ordenação

## Entrada direta

Padrão:

**Nome — A→Z**

Isso evita inventar “risk score” ou relevância subjetiva.

## Entrada por situação

Backend fornece a ordenação contextual.

Para queda de frequência:

1. maior redução percentual;
2. nome A→Z como desempate.

Para ausência:

1. maior número de dias desde último acesso;
2. nome A→Z.

A UI não cria score composto.

---

# 25. Colunas

Desktop:

1. Aluno
2. Status
3. Frequência recente
4. Variação
5. Último acesso
6. Situação ativa

### Sortable

- Aluno
- Status
- Frequência recente
- Variação
- Último acesso

`Situação ativa` não precisa ser sortable no MVP.

---

# 26. Row interaction

Clique na linha:

> Abrir aluno

Controles internos da linha, caso existam, não disparam row click.

Nenhuma ação destrutiva ou administrativa na row.

Não adicionar kebab menu sem ação real.

---

# 27. Persistência

Durante a sessão/navegação interna, preservar:

- busca;
- filtros;
- ordenação;
- page size.

Ao voltar de Detalhe do aluno:

- restaurar posição e filtros anteriores.

Filtros derivados de uma situação permanecem até:

- usuário limpar;
- sair deliberadamente para entrada direta de Alunos.

---

# 28. Mobile da tabela

<768px:

não transformar cada aluno em card visual.

Usar structured rows.

Mostrar prioritariamente:

- nome;
- frequência recente;
- variação;
- último acesso.

Status e situação ficam na segunda linha ou disclosure.

---

# 29. Responsividade — Breakpoints normativos

## ≥1280px — Desktop principal

- sidebar: 232px;
- conteúdo analítico até 1440px;
- grid 12 colunas;
- metric strip em uma linha;
- gráfico + Situações podem usar 8/4;
- contexto do Copiloto lateral;
- tabelas completas.

## 1024–1279px

- sidebar colapsável para versão compacta;
- conteúdo usa 12 colunas;
- regiões 8/4 somente quando mantiverem largura mínima;
- caso contrário tornam-se sequenciais;
- metric strip continua horizontal se todos os labels couberem;
- contexto do Copiloto vira drawer;
- filtros podem quebrar para segunda linha;
- tabela pode ocultar `Status` antes de campos analíticos.

## 768–1023px

- navegação compacta/drawer;
- metric strip 2×2;
- gráficos full width;
- Situações abaixo dos gráficos;
- contexto do Copiloto em drawer/sheet;
- filtros em duas linhas;
- tabela mostra prioridade de colunas;
- distribuição horária pode usar matriz com scroll controlado ou barras por faixa quando necessário.

## <768px

- navigation drawer;
- layout de uma coluna;
- metric strip sequencial ou 2×2 quando ≥480px;
- Visão geral prioriza:
  1. métricas;
  2. situações;
  3. tendência principal;
  4. link para frequência;
- tabela vira structured rows;
- Copiloto ocupa a área principal;
- contexto abre em sheet;
- evidências são expansíveis;
- matriz horária vira barras por faixa;
- sem hover-only interactions.

Desktop permanece cenário prioritário.

---

# 30. Design Tokens Final

Os tokens abaixo deixam de ser “suggested” e tornam-se normativos.

## Cores

| TokenValorUso |           |                          |
| ------------- | --------- | ------------------------ |
| Ink 950       | `#17191C` | texto principal/sidebar  |
| Ink 800       | `#2D3035` | texto secundário forte   |
| Neutral 600   | `#646A73` | metadata/body secundário |
| Neutral 400   | `#989EA7` | comparação/disabled      |
| Neutral 200   | `#D9DDE2` | borders                  |
| Neutral 100   | `#ECEFF2` | regiões neutras          |
| Canvas        | `#F6F7F5` | fundo                    |
| Surface       | `#FFFFFF` | superfícies              |
| Action 700    | `#274C77` | primary/action/data      |
| Action 600    | `#315F91` | hover/secondary          |
| Action 100    | `#E8EFF6` | seleção                  |
| Attention 700 | `#8A5A19` | WARNING                  |
| Attention 100 | `#F7EEDC` | warning background       |
| High 700      | `#93443C` | HIGH                     |
| High 100      | `#F7E8E6` | high background          |
| Success 700   | `#3F6B56` | positividade explícita   |
| Success 100   | `#E8F0EB` | positive background      |

### Stable

**Stable é neutro.**

Usar Ink/Neutral.

Nunca usar verde apenas porque uma métrica não mudou.

Verde somente quando a semântica for explicitamente positiva.

---

# 31. Contrastes

Combinações aprovadas para texto normal incluem:

- Ink 950 / Surface: >17:1;
- Neutral 600 / Surface: >5,4:1;
- Action 700 / Surface: >8,7:1;
- Attention 700 / Attention 100: >5,1:1;
- High 700 / High 100: >5,6:1;
- Success 700 / Success 100: >5,2:1.

Mínimos:

- texto normal: 4,5:1;
- texto grande: 3:1;
- limites/foco relevantes: 3:1.

---

# 32. Typography

Fonte:

**IBM Plex Sans**

Fallback:

system sans-serif.

Pesos permitidos:

- 400 Regular;
- 500 Medium;
- 600 Semibold.

Não utilizar 700/800 como linguagem normal do produto.

## Uso

- Regular: body, metadata, tabelas.
- Medium: labels, navegação, botões.
- Semibold: H1/H2/H3, números-chave quando necessário.

## Escala

- Display: 32/40
- H1: 28/36
- H2: 22/30
- H3: 18/26
- Body L: 16/24
- Body: 14/21
- Small: 13/18
- Caption: 12/16
- Metric L: 32/36
- Metric M: 24/30

Numerais:

**tabular numerals**.

Uppercase não é padrão para headings.

Sentence case é padrão.

Uppercase pode ser usado apenas para pequenos labels técnicos/categoria com até aproximadamente 20 caracteres.

---

# 33. Spacing

Escala fechada:

4, 8, 12, 16, 20, 24, 32, 40, 48, 64px.

Convenção:

- 4–8: conteúdo interno;
- 12–16: controles;
- 20–24: grupos;
- 32: seções;
- 48–64: divisões principais.

---

# 34. Radius

- estrutural/tabela: 0px;
- controles pequenos: 4px;
- buttons/inputs: 6px;
- panels/dialogs: 8px.

Nenhum radius >8px no fluxo principal.

---

# 35. Borders

Padrão:

**1px / Neutral 200**

Preferir border a shadow.

---

# 36. Elevation

**Level 0:** sem sombra.

**Level 1:** popovers/menus; sombra discreta.

**Level 2:** dialogs.

Painéis analíticos normais permanecem Level 0.

---

# 37. Focus

Todos os controles interativos possuem focus visível.

Padrão:

- outline de 2px Action 700;
- offset de 2px;
- não remover outline sem substituição equivalente.

---

# 38. Data visualization colors

### Série atual

Action 700.

### Série anterior

Neutral 400.

### Stable/neutral

Neutral 600/400.

### WARNING

Attention 700 somente quando a própria informação é WARNING.

### HIGH

High 700 somente quando a própria informação é HIGH.

### Positive

Success 700 somente para significado positivo explícito.

Cores semânticas não são usadas para diferenciar séries arbitrárias.

---

# 39. Formatting Rules

## Datas

Data isolada:

> 19 set 2026

Com hora:

> 19 set 2026, 10:42

Intervalo no mesmo mês:

> 12–18 set 2026

Intervalos diferentes:

> 28 ago–3 set 2026

Não usar formato ambíguo americano.

---

## Horários

Formato 24h:

> 18:00

Faixa:

> 18:00–20:00

---

## Percentuais

Uma casa decimal por padrão:

> -12,1%

Zero:

> 0,0%

Sempre mostrar sinal quando representa mudança:

> +8,4%
> -12,1%

Não depender de seta.

---

## Contagens

Separador de milhar PT-BR:

> 1.240 acessos

---

## Médias

Uma casa decimal quando suficiente:

> 2,5

Supporting label:

> visitas médias por aluno ativo

---

## Frequência individual semanalizada

> 2,8 visitas/semana

Somente para a métrica individual explicitamente semanalizada.

---

## Duração

> 8 dias

Em Detail do aluno pode existir:

> há 8 dias

mas o valor exato da última visita deve ser acessível.

---

## Comparações

7 dias:

> Últimos 7 dias vs. 7 dias anteriores

30 dias:

> Últimos 30 dias vs. 30 dias anteriores

Nunca:

> vs. anterior

sem explicitar referência.

---

# 40. Screen Specification — Login

## Objetivo

Autenticar usuário autorizado.

## Rota

`/login`

## Contexto

Nenhum contexto operacional.

## Layout

Desktop:

- formulário central em composição de largura controlada;
- largura do formulário: aproximadamente 360–400px;
- nenhuma grande área institucional vazia usada apenas para decoração.

Pode haver coluna de marca discreta em desktop, desde que tenha função composicional real.

## Conteúdo exato

Título:

> AI Fitness Operations Copilot

Heading:

> Acesse sua conta

Campos:

- E-mail
- Senha

Ação:

**Entrar**

Erro de credencial:

> E-mail ou senha inválidos.

## Dados

Sessão/auth provider.

## Estados

- default;
- submitting;
- invalid credentials;
- provider error;
- session already valid.

## Permissões

Pública.

## Saída

Login válido → Visão geral.

## Responsividade

<768: formulário full-width com gutters de 24px.

## Acessibilidade

- labels permanentes;
- autocomplete apropriado;
- erro associado ao input;
- submit por Enter.

## Aceite

- nenhum marketing fictício;
- nenhuma métrica fake;
- sem gradient/glass;
- autenticação clara em uma viewport comum.

---

# 41. Screen Specification — Visão geral

## Objetivo

Responder rapidamente:

> O que está acontecendo na unidade e onde devo investigar?

## Rota

`/overview`

## Contexto

- unidade;
- período: 7 ou 30 dias;
- período anterior equivalente.

Default:

**7 dias**.

## Layout

1. Header
2. Metric strip
3. Evolução de acessos
4. Situações prioritárias
5. Distribuição de acessos por horário — resumo

Desktop:

preferência por 8/4 para tendência + situações.

## Header

Título:

> Visão geral

Mostrar:

- Unidade Centro
- Últimos 7 dias / Últimos 30 dias
- timestamp somente conforme Freshness Contract.

## Metric strip

Métricas:

1. **Alunos ativos**
2. **Acessos**
3. **Visitas médias por aluno ativo**
4. **Alunos com situação ativa**

O quarto número representa alunos únicos sujeitos a regras de membro ativas.

Não representa situações ativas.

## Situações

Máximo:

3–5.

Ordenação:

1. HIGH antes de WARNING;
2. `detected_at` desc;
3. `insight_id` como desempate estável.

Remover “relevância operacional” subjetiva.

Linha:

> Alta
> Acessos reduziram 22,4%
> 1.094 vs. 1.410 acessos
> Últimos 7 dias vs. 7 dias anteriores
> **Investigar**

## Distribuição horária resumida

Título:

> Distribuição de acessos por horário

Mostrar resumo, não análise completa.

Exemplo:

> Maior volume: 18:00–21:00
> Maior redução: 18:00–20:00 · -21,0%

Ação:

**Ver frequência**

## Copiloto

Ação contextual secundária:

**Perguntar ao Copiloto**

Herdar unidade + período.

## Estados

Aplicar State Matrix por componente.

## Permissões

MANAGER, COORDINATOR, ANALYST autorizados à unidade.

## Saídas

- Frequência;
- Situações;
- Alunos filtrados;
- Copiloto contextual.

## Responsividade

Conforme seção 29.

## Acessibilidade

Metric strip deve ter ordem de leitura linear; gráficos possuem alternativa textual/tabular.

## Aceite

- nenhum grid de quatro cards;
- nenhuma métrica `/semana`;
- nenhum uso de “ocupação”;
- Situações e alunos sinalizados não compartilham o mesmo label;
- IA não é necessária para usar a tela.

---

# 42. Screen Specification — Frequência

## Objetivo

Decompor mudanças de acessos no tempo e por horário.

## Rota

`/attendance`

Label de navegação:

**Frequência**

## Entrada

- direta;
- Visão geral;
- Situação;
- Evidência do Copiloto.

## Contexto

- unidade;
- 7d/30d;
- previous equivalent period;
- highlight opcional;
- source insight opcional.

## Layout

1. Header/context banner
2. métricas de frequência
3. evolução de acessos
4. decomposição por dia
5. distribuição de acessos por horário
6. situações relacionadas
7. ação contextual para Copiloto

## Métricas

- Acessos
- Variação de acessos
- Visitas médias por aluno ativo

Não duplicar Alunos ativos salvo necessidade de contexto.

## Entrada por situação

Mostrar faixa discreta:

> Investigação iniciada em: Queda de acessos · últimos 7 dias

Ação:

**Voltar para Situações**

Destacar período/faixa relevante sem esconder restante dos dados.

## Conteúdo

Heading:

> Frequência

Section headings:

- Evolução de acessos
- Distribuição por dia
- Distribuição de acessos por horário
- Situações relacionadas

## Ações

- 7 dias
- 30 dias
- Ver alunos
- Investigar
- Perguntar ao Copiloto

## Dados

- `total_accesses`;
- `average_attendance`;
- change percentage;
- daily distribution;
- hourly distribution;
- related deterministic insights.

## Estados

State Matrix.

## Permissões

Roles analíticos autorizados.

## Saída

- Alunos filtrados;
- Situações;
- Copiloto contextual;
- Visão geral.

## Responsividade

Charts full-width abaixo de 1024.

## Aceite

- nenhum gráfico além dos três aprovados;
- comparação explícita;
- `null` e zero tratados distintamente;
- nenhuma afirmação de lotação;
- acesso direto a evidências determinísticas.

---

# 43. Screen Specification — Alunos

## Objetivo

Localizar, comparar e abrir alunos.

## Rota

`/members`

## Entrada

- direta;
- Frequência;
- Situação;
- Copiloto/evidência.

## Contexto

- unidade;
- filtros;
- origem da investigação.

## Layout

1. Header
2. busca/filtros
3. applied investigation context, quando houver
4. tabela
5. paginação

## Conteúdo

Título:

> Alunos

Busca:

> Buscar por nome ou código

Filtros:

- Status
- Situação de frequência

## Row

Clique:

**Abrir aluno**

## Dados

- code;
- display name;
- status;- recent weekly frequency;
- change;
- last visit;
- member-targeting active situations.

## Estados

State Matrix.

## Permissões

Todos os papéis autorizados.

## Saída

Detalhe do aluno.

## Responsividade

Conforme Members Table Specification.

## Acessibilidade

Tabela semântica em desktop; structured list semântica no mobile; ordenação anunciada.

## Aceite

- page size 25;
- filtros persistem;
- entrada contextual permanece visível;
- nenhuma classificação de “risco”.

---

# 44. Screen Specification — Detalhe do aluno

## Objetivo

Investigar o comportamento individual de frequência.

## Rota

`/members/:memberId`

## Contexto

- unidade;
- aluno;
- período;
- origem;
- situação selecionada opcional.

## Header

> Ana Souza
> Aluno A-0142
> Ativo

Ações:

- **Perguntar ao Copiloto**
- **Voltar para Alunos**

## Métricas

- Frequência recente
- Frequência anterior
- Variação
- Último acesso

Aqui a frequência individual pode usar `/semana`, pois utiliza a métrica semanalizada de membro, não `average_attendance`.

## Regiões

1. resumo;
2. histórico de frequência;
3. situações detectadas;
4. acessos recentes.

## Situações

Exemplo:

> Atenção
> Redução relevante de frequência
> 1,2 visitas/semana vs. 3,1 visitas/semana

> Atenção
> Ausência prolongada
> 12 dias desde o último acesso

## Copiloto

Contexto herdado obrigatório:

- aluno;
- período;
- unidade;
- situação, se acionado a partir dela.

## Estados

Inclui aluno sem histórico:

> Ainda não há acessos registrados para este aluno.

Isso é empty/insufficient, não erro.

## Permissões

Papéis autorizados à unidade.

## Saídas

- Alunos;
- situação relacionada;
- Copiloto contextual.

## Responsividade

Uma coluna <1024.

## Acessibilidade

Datas exatas disponíveis além de expressões relativas.

## Aceite

- nenhuma previsão de cancelamento;
- nenhuma linguagem “risco de churn”;
- evidências das regras visíveis;
- Copiloto recebe entity context correto.

---

# 45. Screen Specification — Situações

## Objetivo

Priorizar sinais determinísticos relevantes.

## Rota

`/insights`

## Contexto

- unidade;
- período;
- filtros.

## Header

> Situações

Metadata:

> 4 situações ativas

## Lista padrão

Mostrar:

- HIGH;
- WARNING.

Não mostrar INFO por padrão.

## Filtros

**Severidade**

- Todas
- Alta
- Atenção

**Tipo**

- Queda de acessos
- Redução de frequência de alunos
- Ausência prolongada
- Redução no fluxo de acessos por horário

## Ordenação

Determinística:

1. HIGH;
2. WARNING;
3. detected_at desc;
4. insight_id.

## Cada item

- severidade;
- título;
- fato principal;
- período;
- subject;
- ação.

Exemplo:

> Alta
> **Acessos reduziram 22,4%**
> 1.094 vs. 1.410 acessos
> Últimos 7 dias vs. 7 dias anteriores
> **Investigar**

## Routing

O botão Investigar resolve destino segundo as regras de Insight Detail.

## Dados

OperationalInsight determinístico + evidence snapshot.

## Estados

State Matrix.

## Permissões

Papéis autorizados.

## Saída

- Frequência;
- Alunos;
- Aluno;
- detalhe dedicado;
- Copiloto.

## Responsividade

Lista vira full-width, nunca grid de cards.

## Aceite

- INFO não gera ruído;
- badge da navegação coincide com contagem de situações ativas;
- severidade nunca é calculada pelo frontend.

---

# 46. Screen Specification — Detalhe de situação

## Condicional

Existe apenas conforme regras da seção 8.

## Rota

`/insights/:insightId`

## Objetivo

Explicar uma situação cuja evidência não cabe integralmente em outra superfície.

## Contexto

- insight ID;
- rule code/version;
- subject;
- período;
- comparação;
- evidence snapshot.

## Layout

1. título + severidade;
2. fato detectado;
3. condição da regra;
4. evidências;
5. período/comparação;
6. limitações;
7. destinos determinísticos;
8. Perguntar ao Copiloto.

## Copy

> Esta situação foi detectada porque a variação ultrapassou o threshold configurado para a regra.

Não usar:

> A IA detectou...

## Ações

- Ver frequência
- Abrir aluno
- Ver alunos
- Ver evidências
- Perguntar ao Copiloto

Ações aparecem apenas se aplicáveis.

## Estados

Snapshot antigo continua válido historicamente, mas recebe:

> Situação detectada em 18 set 2026, 10:42.

## Aceite

- não duplica uma tela canônica sem necessidade;
- regra e threshold são determinísticos;
- snapshot preservado.

---

# 47. Screen Specification — Copiloto

## Objetivo

Interpretar fatos autorizados dentro do contexto da investigação.

## Rota

`/copilot` ou conversa.

## Entrada principal

Ações contextuais de outras telas.

## Entrada secundária

Sidebar.

## Layout desktop ≥1280

Área principal:

- contexto resumido;
- turnos;
- evidências próximas das respostas;
- composer.

Lateral:

- Contexto da análise;
- período;
- entidade;
- situação;
- Alterar contexto.

Não estruturar como clone visual de ChatGPT.

## Empty direto

Heading:

> Investigue os dados da unidade

Descrição:

> Faça perguntas sobre frequência, alunos, situações ou distribuição de acessos.

## Turno do usuário

Texto da pergunta sem avatar.

## Resposta

Label discreto:

> Copiloto

Estrutura:

1. interpretação;
2. evidências;
3. período;
4. limitações.

## Composer

Placeholder:

> Pergunte sobre os dados deste contexto

Ação:

**Enviar**

## Loading

> Analisando dados…

Somente exibir subestágios se representarem estados reais.

Não utilizar:

- Pensando…
- digitando…
- avatar;
- mascote;
- persona humana.

## AI unavailable

> Copiloto temporariamente indisponível

> Os dados e análises determinísticas continuam disponíveis.

Ação:

**Tentar novamente**

## Insufficient data

Exemplo:

> Os dados disponíveis não permitem determinar a causa dessa alteração.

Isso é uma resposta válida.

## Context change

Conforme Copilot Context Contract.

## Permissões

Mesmo isolamento da unidade.

## Saídas

Cada evidência abre sua superfície determinística.

## Responsividade

- ≥1280: context panel lateral;
- 1024–1279: drawer;
- 768–1023: drawer;
- <768: context sheet.

## Acessibilidade

- mensagens em landmarks/list semantics;
- composer label acessível;
- status de processamento via live region não intrusiva;
- links de evidência descritivos.

## Aceite

- contexto sempre verificável;
- run snapshot imutável;
- evidência antiga mantém contexto original;
- página direta não domina experiência;
- causalidade nunca é inventada.

---

# 48. UI Acceptance Criteria — Globais

A UI só está aprovada se todos os itens abaixo forem verdadeiros.

### Semântica

-  `average_attendance` nunca aparece com `/semana`.
-  “Ocupação” não representa registros de acesso.
-  Situações, alunos afetados e severidade possuem labels distintos.
-  Severidade vem do backend/Insight Engine.
-  INFO não entra em Situações ativas.
-  comparação declara período de referência.
-  zero e null não são tratados como equivalentes.

### Arquitetura de informação

-  Visão geral resume.
-  Frequência decompõe.
-  Alunos localiza entidades.
-  Detalhe do aluno investiga indivíduo.
-  Situações prioriza.
-  Detalhe de situação só existe quando necessário.
-  Copiloto interpreta.
-  conteúdo canônico não é copiado integralmente entre telas.

### Copiloto

-  fluxo contextual é primário.
-  contexto é visível.
-  contexto de cada run é imutável.
-  mudar contexto não reescreve mensagens antigas.
-  evidências continuam ligadas ao contexto original.
-  indisponibilidade do LLM não bloqueia produto.
-  perguntas sugeridas não prometem causalidade.

### Design

-  IBM Plex Sans.
-  somente 400/500/600.
-  medium-dense.
-  bordas antes de sombras.
-  radius máximo normal de 8px.
-  sem gradients.
-  sem glassmorphism.
-  sem neon.
-  sem card grid predominante.
-  tabelas como componente de primeira classe.
-  stable é neutro.
-  verde apenas para significado positivo.
-  nenhuma informação depende somente de cor.

### Charts

-  somente visualizações aprovadas.
-  tooltip com valor exato.
-  alternativa tabular/textual.
-  null cria gap/indisponibilidade.
-  zero permanece zero.
-  previous visualmente secundário.
-  mobile não comprime matriz horária de forma ilegível.

### Tabela

-  25 registros padrão.
-  paginação.
-  filtros persistem.
-  direct entry ordena Nome A→Z.
-  contextual entry preserva filtro de origem.
-  row controls não acionam row click.
-  voltar do aluno restaura estado.

### Estados

-  loading não causa layout shift relevante.
-  empty não é erro.
-  insufficient data não é erro.
-  AI unavailable não é page unavailable.
-  partial mantém dados válidos.
-  stale é informado explicitamente.
-  unauthorized não aparece como 404.

---

# 49. Resolved Design Critic Findings

## Critical

**C1 — Average Attendance:** resolvido com unidade canônica por período.

**C2 — Occupancy:** resolvido com “Distribuição de acessos por horário” e proibição de semântica de presença simultânea.

**C3 — Attention:** resolvido em quatro conceitos independentes.

**C4 — Severity:** resolvido com mapping determinístico.

## Important

**I1 — Copiloto separado:** fluxo contextual definido como primário; rota direta secundária.

**I2 — Insight Detail redundante:** critérios formais de existência definidos.

**I3 — duplicação:** Canonical Content Ownership Matrix definida.

**I4 — causalidade:** linguagem e fallback causal definidos.

**I5 — ruído INFO:** INFO excluído da lista padrão e das situações ativas.

**I6 — relevância operacional vaga:** removida da ordenação.

**I7 — timestamp global:** contrato de snapshot/freshness definido.

**I8 — state matrix:** definida por componentes.

**I9 — charts:** especificação fechada.

**I10 — responsividade:** quatro breakpoints normativos.

**I11 — tabela de alunos:** comportamento operacional definido.

**I12 — contexto do Copiloto:** snapshot imutável por run.

**I13 — idioma:** PT-BR congelado.

**I14 — stable/positive:** stable passa a neutro.

## Minor

**M1 — Login vazio:** composição de largura controlada.

**M2 — uppercase:** sentence case como default.

**M3 — ações inconsistentes:** vocabulário canônico definido.

**M4 — font weights:** 400/500/600.

**M5 — tokens sugeridos:** transformados em normativos.

O Design Critic identificou corretamente que a versão anterior ainda permitia implementações semanticamente divergentes e apontou especificamente esses quatro blockers críticos antes de liberar o frontend.

---

# 50. Remaining Open Questions

Nenhum item abaixo impede a construção do MVP visual inicial, desde que os defaults desta especificação sejam seguidos.

## OQ-01 — HIGH thresholds

Os thresholds secundários definidos nesta especificação são agora o Severity Mapping v0.1.

Antes de produção real, devem ser validados com dados reais de negócio.

Eles são heurísticas de demonstração, não benchmarks do mercado fitness.

## OQ-02 — INFO no futuro

O schema mantém INFO.

O MVP não cria INFO independente.

Caso futuramente existam situações informativas, deve ser definido:

- por que são persistidas;
- onde aparecem;
- se podem ser filtradas.

## OQ-03 — Snapshot global

A API deverá decidir se consegue devolver um `snapshot_id` único para cada carregamento analítico.

Se não conseguir, a UI deve usar timestamps por componente.

## OQ-04 — Histórico do Copiloto

Ainda pode ser definido futuramente:

- limite de conversas;
- arquivamento;
- renomeação;
- retenção.

Nada disso é necessário para o fluxo principal do MVP.

## OQ-05 — Busca de alunos

A implementação pode decidir entre paginação/query server-side ou solução equivalente, desde que preserve os contratos funcionais desta especificação e não carregue/renderize 500 linhas indiscriminadamente.

## OQ-06 — Heat matrix

A biblioteca de charts pode variar.

O contrato visual e semântico permanece:

- hora/faixa × dia;
- intensidade baseada em acessos;
- valor exato acessível;
- zero diferente de null;
- alternativa tabular.

---

# 51. Definition of Ready para frontend

O agente de frontend pode implementar a interface sem decidir:

- o significado das métricas;
- o significado de “ocupação”;
- o que significa Attention;
- quando algo é HIGH;
- como Situações são ordenadas;
- quando Insight Detail existe;
- qual tela é dona de cada conteúdo;
- como contexto do Copiloto funciona;
- como uma mudança de contexto afeta respostas antigas;
- quais charts devem existir;
- como null/zero/comparison unavailable funcionam;
- como Members pagina, filtra e ordena;
- quais breakpoints utilizar;
- quais cores, fontes, pesos, spacing, radius e elevation utilizar;
- quais labels principais aparecem na interface;
- qual idioma utilizar;
- como tratar causalidade;
- como tratar falha do LLM.

Essas decisões passam a pertencer à **UI Screen Specification v0.1**.

---

## Fonte de verdade consolidada

Esta especificação deve ser interpretada em conjunto com os artefatos anteriores, mas possui precedência sobre eles para decisões de **UI, copy, ownership, responsividade, estados, severidade apresentada e interação do Copiloto** quando houver conflito explícito corrigido neste documento.

Ela não altera o princípio de produto nem a arquitetura técnica. A especificação original define o fluxo como identificação da situação → investigação dos dados → Copiloto fundamentado em evidências, e mantém a decisão operacional com o gestor.

O modelo de dados mantém insights como detecções determinísticas auditáveis com `severity`, `rule_code`, `rule_version` e `evidence_snapshot`; portanto, a UI deve consumir esses resultados e nunca recriar a regra visualmente.

Essa versão fecha os bloqueadores que impediam handoff seguro para frontend. O ponto mais importante é que agora um agente pode tomar decisões de implementação visual, mas não precisa — e não deve — inventar semântica de produto, regra de severidade, causalidade, ownership ou comportamento contextual.
