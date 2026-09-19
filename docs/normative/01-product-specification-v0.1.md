# AI Fitness Operations Copilot

## Especificação Inicial de Produto — v0.1

## 1. Product Vision

O **AI Fitness Operations Copilot** é uma aplicação de apoio à gestão operacional de academias que transforma dados de frequência, alunos e operação em informações compreensíveis e acionáveis.

O produto deve permitir que um gestor identifique rapidamente situações relevantes da unidade, como:

- redução de frequência;
- alunos com sinais de abandono;
- períodos com baixa ou alta ocupação;
- indicadores operacionais fora do comportamento esperado;
- mudanças relevantes no comportamento da unidade.

Além da visualização tradicional por indicadores, o sistema oferece um **copiloto baseado em inteligência artificial**, capaz de interpretar os dados disponíveis e responder perguntas em linguagem natural.

Exemplos:

> “Por que a frequência caiu esta semana?”

> “Quais alunos apresentam maior sinal de abandono?”

> “Quais horários estão com menor utilização?”

> “Existe algum indicador que precisa da minha atenção hoje?”

O objetivo não é substituir o gestor nem tomar decisões automaticamente, mas **reduzir o esforço necessário para transformar dados operacionais em entendimento e ação**.

---

# 2. Problema que o produto resolve

Academias geram continuamente informações relacionadas a alunos, acessos, frequência e utilização da unidade.

O problema não é necessariamente a falta de dados.

O problema é que o gestor precisa:

1. localizar os dados relevantes;
2. interpretar indicadores;
3. comparar períodos;
4. perceber padrões;
5. investigar possíveis causas;
6. decidir onde concentrar atenção.

Esse processo pode exigir tempo, experiência analítica e navegação por diversas informações.

O AI Fitness Operations Copilot propõe uma camada de inteligência operacional que responde principalmente à pergunta:

> **“O que está acontecendo na minha academia e onde devo investigar?”**

O sistema transforma dados estruturados em:

**dados → indicadores → sinais → explicações → investigação**

---

# 3. Principais usuários

## Persona 1 — Gestor de unidade

Responsável pela operação diária de uma academia.

### Necessidades

- entender rapidamente o estado atual da unidade;
- acompanhar frequência;
- identificar mudanças relevantes;
- observar alunos com sinais de abandono;
- visualizar horários de maior e menor utilização;
- identificar situações que merecem atenção.

### Comportamento esperado

É o principal usuário do MVP.

---

## Persona 2 — Coordenador operacional

Responsável por acompanhar uma ou mais unidades ou apoiar gestores locais.

### Necessidades

- comparar comportamento ao longo do tempo;
- identificar unidades ou períodos anormais;
- acompanhar indicadores operacionais;
- investigar situações sinalizadas pelo sistema.

### MVP

Pode utilizar o sistema, mas suporte completo a múltiplas unidades não precisa fazer parte da primeira versão.

---

## Persona 3 — Analista ou liderança estratégica

Usuário interessado em tendências e padrões operacionais.

### Necessidades

- consultar indicadores;
- entender tendências;
- formular perguntas sobre os dados.

### MVP

Usuário secundário.

---

# 4. User Problems

## UP-01 — Dificuldade em identificar rapidamente o que mudou

O gestor consegue visualizar números, mas pode não perceber imediatamente quais mudanças são realmente relevantes.

---

## UP-02 — Investigação manual das causas

Quando um indicador cai ou sobe, o gestor precisa realizar diversas consultas para entender possíveis causas.

---

## UP-03 — Identificação tardia de abandono

Alguns alunos reduzem gradualmente sua frequência antes de interromper completamente as atividades.

Esses sinais podem passar despercebidos.

---

## UP-04 — Dificuldade em interpretar ocupação

Visualizar registros de acesso não necessariamente torna evidente quais horários estão sobrecarregados ou subutilizados.

---

## UP-05 — Excesso de informação sem priorização

Nem toda mudança merece atenção.

O gestor precisa distinguir:

- comportamento normal;
- variações esperadas;
- situações relevantes;
- situações potencialmente críticas.

---

# 5. Objetivos do produto

## Objetivo principal

Permitir que gestores compreendam rapidamente a situação operacional da academia utilizando indicadores e consultas em linguagem natural.

## Objetivos secundários

O produto deverá:

- consolidar indicadores operacionais importantes;
- facilitar comparação entre períodos;
- identificar comportamentos fora do padrão;
- detectar sinais de possível abandono;
- apresentar distribuição de frequência por horário;
- permitir investigação por linguagem natural;
- explicar de onde os insights foram derivados;
- priorizar situações que merecem atenção.

---

# 6. Princípios do produto

O desenvolvimento deverá seguir alguns princípios.

### IA como copiloto, não como decoração

IA somente deverá ser utilizada quando houver ganho real de usabilidade ou interpretação.

### Dados antes de IA

Todos os insights deverão ser fundamentados em dados disponíveis no sistema.

### Explicabilidade

O usuário deverá conseguir entender por que determinado insight foi apresentado.

### Simplicidade

A primeira versão deve resolver poucos problemas claramente.

### Investigação orientada

O sistema deve ajudar o gestor a encontrar informações relevantes, não apenas exibir gráficos.

### Decisão humana

O sistema pode identificar sinais e sugerir pontos de investigação, mas a decisão operacional continua pertencendo ao gestor.

---

# 7. Funcionalidades possíveis

## Dashboard operacional

Apresentação dos principais indicadores da unidade.

Possíveis indicadores:

- alunos ativos;
- acessos no período;
- frequência média;
- variação de frequência;
- quantidade de alunos com queda de frequência;
- distribuição de acessos por horário;
- quantidade de situações que precisam de atenção.

---

## Análise de frequência

Permitir acompanhar a evolução da frequência da unidade.

Exemplos:

- últimos 7 dias;
- últimos 30 dias;
- comparação com período anterior.

---

## Análise de ocupação

Mostrar distribuição de acessos por:

- dia da semana;
- horário;
- faixa horária.

Objetivo:

identificar períodos de maior e menor utilização.

---

## Sinais de abandono

Identificar alunos que apresentam mudança relevante de comportamento.

Exemplos:

- frequência reduzida;
- ausência prolongada;
- redução consistente de visitas.

O sistema não deve afirmar:

> “Esse aluno vai cancelar.”

Deve apresentar algo como:

> “Este aluno apresentou redução significativa de frequência.”

---

## Central de atenção

Área que destaca situações relevantes.

Exemplos:

- frequência caiu significativamente;
- aumento inesperado de ausência;
- horário com utilização muito baixa;
- grupo de alunos com forte redução de frequência.

---

## Copiloto de IA

Interface onde o gestor pode formular perguntas sobre os dados.

Exemplos:

- “Como está a unidade?”
- “Por que a frequência caiu?”
- “Quais alunos tiveram maior queda de frequência?”
- “Qual horário está mais vazio?”
- “O que mudou em relação à semana passada?”

---

## Explicação dos insights

Todo insight importante deverá apresentar evidências.

Exemplo:

**Insight**

A frequência caiu 12% nesta semana.

**Evidências**

- segunda-feira: -8%;
- terça-feira: -15%;
- quarta-feira: -18%;
- maior queda entre 18h e 20h.

---

# 8. Funcionalidades essenciais

Para a primeira versão funcional:

1. autenticação;
2. dashboard da unidade;
3. indicadores principais;
4. histórico de frequência;
5. distribuição de acessos por horário;
6. lista de alunos;
7. análise individual de frequência;
8. identificação de sinais de abandono;
9. central de situações que merecem atenção;
10. copiloto de IA;
11. respostas da IA baseadas exclusivamente nos dados disponíveis;
12. indicação das evidências utilizadas na resposta.

---

# 9. Funcionalidades futuras

Não fazem parte inicialmente do MVP.

- múltiplas unidades;
- comparação entre unidades;
- envio automático de alertas;
- integração com WhatsApp;
- integração com e-mail;
- campanhas de recuperação;
- previsão de cancelamento utilizando machine learning;
- recomendação automática de ações comerciais;
- análise financeira;
- gestão de planos;
- gestão completa de alunos;
- CRM;
- controle de pagamentos;
- prescrição de treino;
- acompanhamento físico;
- reconhecimento facial;
- análise por câmera;
- integração com catracas reais;
- aplicativo para aluno;
- aplicativo mobile nativo;
- comandos por voz;
- agentes autônomos executando ações;
- geração automática de campanhas.

---

# 10. MVP Scope

O MVP deve responder quatro perguntas principais.

### 1. Como está a unidade?

Mostrar visão geral da operação.

### 2. A frequência está mudando?

Mostrar evolução e comparação com período anterior.

### 3. Existem alunos reduzindo frequência?

Identificar alunos com mudança relevante de comportamento.

### 4. O que merece atenção?

Apresentar automaticamente situações operacionais relevantes.

A IA deverá permitir investigação adicional desses pontos.

---

# 11. Fluxo principal do MVP

O fluxo esperado é:

**Login**

→

**Dashboard da unidade**

→

Visualização dos principais indicadores

→

Sistema apresenta situações que merecem atenção

→

Gestor seleciona uma situação

→

Visualiza dados relacionados

→

Pode perguntar ao copiloto sobre aquela situação

→

Copiloto consulta os dados relevantes

→

Retorna explicação baseada nos dados

---

# 12. Functional Requirements

## FR-01 — Autenticação

O sistema deve permitir que usuários autorizados realizem login.

---

## FR-02 — Identificação da unidade

Todo dado operacional exibido deve estar associado a uma unidade.

---

## FR-03 — Dashboard

O sistema deve apresentar um resumo operacional da unidade.

O dashboard deverá incluir pelo menos:

- total de alunos ativos;
- total de acessos no período;
- média de frequência;
- variação em relação ao período anterior;
- alunos com redução relevante de frequência;
- distribuição de acessos por horário.

---

## FR-04 — Seleção de período

O usuário deve poder visualizar informações de diferentes períodos.

Inicialmente:

- últimos 7 dias;
- últimos 30 dias;
- período anterior equivalente.

---

## FR-05 — Histórico de frequência

O sistema deve apresentar a evolução de acessos ao longo do tempo.

---

## FR-06 — Ocupação por horário

O sistema deve agrupar acessos por horário ou faixa horária.

---

## FR-07 — Lista de alunos

O usuário deve conseguir visualizar alunos da unidade.

Informações mínimas:

- identificação;
- status;
- frequência recente;
- última visita;
- indicador de mudança de frequência.

---

## FR-08 — Detalhes do aluno

O usuário deve conseguir consultar o comportamento de frequência de um aluno.

---

## FR-09 — Detecção de redução de frequência

O sistema deve identificar alunos cuja frequência recente tenha caído significativamente em relação ao histórico utilizado como referência.

---

## FR-10 — Indicadores de atenção

O sistema deve gerar automaticamente sinais baseados em regras previamente definidas.

---

## FR-11 — Copiloto

O usuário deve poder enviar perguntas em linguagem natural relacionadas aos dados da unidade.

---

## FR-12 — Respostas baseadas em dados

O copiloto deve responder utilizando somente informações disponíveis e autorizadas no sistema.

---

## FR-13 — Evidências da resposta

Quando possível, respostas analíticas devem informar quais dados sustentam a conclusão apresentada.

---

## FR-14 — Tratamento de perguntas não respondíveis

Caso não existam dados suficientes, o sistema deve informar isso claramente.

Exemplo:

> “Os dados disponíveis não permitem determinar a causa dessa alteração.”

---

## FR-15 — Perguntas contextuais

O copiloto deverá compreender contexto básico da página atual.

Exemplo:

ao visualizar um aluno específico, o usuário poderá perguntar:

> “O que mudou na frequência dele?”

---

# 13. Non-functional Requirements

## NFR-01 — Segurança

Dados de usuários e alunos deverão possuir acesso controlado.

---

## NFR-02 — Isolamento de dados

Usuários não poderão consultar dados pertencentes a unidades às quais não possuem acesso.

---

## NFR-03 — Privacidade

Informações pessoais devem ser limitadas ao necessário para a demonstração do produto.

---

## NFR-04 — Auditabilidade da IA

Consultas ao copiloto deverão permitir identificar:

- pergunta realizada;
- contexto utilizado;
- dados consultados;
- resposta gerada.

---

## NFR-05 — Confiabilidade

Cálculos de indicadores deverão ser determinísticos e independentes da IA.

---

## NFR-06 — Explicabilidade

Insights relevantes deverão possuir evidências verificáveis.

---

## NFR-07 — Performance

Operações comuns de dashboard devem apresentar resposta suficientemente rápida para interação normal do usuário.

---

## NFR-08 — Resiliência da IA

Falha no serviço de IA não deve impedir acesso aos indicadores tradicionais.

---

## NFR-09 — Usabilidade

O usuário deve conseguir compreender o estado geral da unidade sem precisar utilizar o copiloto.

---

## NFR-10 — Observabilidade

O sistema deverá permitir identificação de erros relevantes durante a execução.

---

## NFR-11 — Manutenibilidade

Regras de negócio, cálculo de indicadores e comportamento da IA deverão permanecer separados conceitualmente.

---

# 14. Initial Business Rules

## BR-01 — Acesso

Um usuário somente pode visualizar unidades às quais possui acesso.

---

## BR-02 — Aluno ativo

Somente alunos considerados ativos devem participar dos indicadores principais de frequência, salvo quando o indicador exigir explicitamente outro conjunto.

---

## BR-03 — Registro de acesso

Cada visita válida de um aluno deverá gerar um registro de acesso contendo pelo menos:

- aluno;
- unidade;
- data;
- horário.

---

## BR-04 — Frequência

A frequência de um aluno deverá ser calculada a partir dos registros válidos de acesso.

---

## BR-05 — Período de comparação

Toda análise de variação deverá declarar qual período está sendo comparado.

Exemplo:

últimos 7 dias versus 7 dias anteriores.

---

## BR-06 — Sinal de queda de frequência

Um aluno poderá receber um sinal de atenção quando sua frequência recente apresentar redução significativa em relação ao período de referência.

O limite exato deverá ser configurado posteriormente.

---

## BR-07 — Ausência prolongada

O sistema poderá gerar um sinal quando um aluno ativo permanecer determinado número de dias sem registrar acesso.

O limite também deverá ser definido posteriormente.

---

## BR-08 — Risco não significa cancelamento

Um indicador de possível abandono representa apenas comportamento incomum ou redução de frequência.

O sistema não poderá afirmar que um aluno irá cancelar.

---

## BR-09 — Indicadores calculados fora da IA

Cálculos como:

- frequência;
- média;
- percentual de variação;
- contagem;
- ranking;
- ocupação;

devem ser produzidos pelo sistema.

A IA poderá interpretar esses dados, mas não deverá ser responsável pelo cálculo primário.

---

## BR-10 — IA sem evidência

Quando não houver evidência suficiente para responder uma pergunta, o copiloto deverá declarar a limitação em vez de inventar uma explicação.

---

# 15. Main Entities

## User

Representa a pessoa que utiliza o sistema.

Possíveis atributos conceituais:

- identificação;
- nome;
- credenciais;
- perfil;
- unidades autorizadas.

---

## GymUnit

Representa uma unidade de academia.

Possíveis informações:

- identificação;
- nome;
- status.

---

## Member

Representa um aluno.

Possíveis informações:

- identificação;
- nome;
- status;
- data de entrada;
- unidade.

---

## AccessRecord

Representa uma entrada registrada na academia.

Possíveis informações:

- aluno;
- unidade;
- data;
- horário.

---

## AttendanceMetric

Representa indicadores calculados de frequência.

Pode ser calculado dinamicamente em vez de necessariamente persistido.

---

## OperationalInsight

Representa uma situação relevante detectada pelo sistema.

Exemplos:

- queda de frequência;
- ausência prolongada;
- alteração relevante de ocupação.

Possíveis informações:

- tipo;
- gravidade;
- período;
- evidências;
- entidade relacionada.

---

## AIConversation

Representa uma conversa realizada com o copiloto.

---

## AIMessage

Representa perguntas e respostas dentro de uma conversa.

---

## AIAnalysisContext

Representa os dados utilizados para fundamentar determinada resposta.

Essa entidade pode ser conceitual e não necessariamente armazenada como estrutura independente.

---

# 16. Onde IA agrega valor

A IA é especialmente útil em três situações.

## Interpretação

Transformar indicadores em linguagem compreensível.

Exemplo:

Dados estruturados:

- frequência -14%;
- maior queda terça e quarta;
- horário 18h–20h caiu 21%.

Resposta:

> “A queda desta semana está concentrada principalmente entre terça e quarta-feira e foi mais forte no período entre 18h e 20h.”

---

## Investigação

Permitir perguntas sem exigir que o usuário saiba exatamente onde procurar.

Exemplo:

> “O que mudou esta semana?”

---

## Síntese

Combinar diversos indicadores em uma visão executiva.

Exemplo:

> “A unidade apresentou redução moderada de frequência, concentrada no período noturno, enquanto os acessos matinais permaneceram estáveis.”

---

# 17. Onde IA não deve ser utilizada

A IA não deverá calcular:

- total de alunos;
- total de acessos;
- médias;
- percentuais;
- horários;
- intervalos;
- rankings;
- comparação numérica;
- regras de permissão.

Também não deverá ser responsável diretamente por:

- autenticação;
- autorização;
- persistência;
- validação de regras;
- controle de acesso;
- integridade de dados.

Essas operações devem ser determinísticas.

A IA atua principalmente como:

> **camada de interpretação e interação.**

---

# 18. Arquitetura conceitual da inteligência do produto

Mesmo sem definir tecnologia, o produto pode ser pensado em três camadas conceituais.

### Camada 1 — Dados

Registros operacionais.

Exemplo:

acessos, alunos, unidades.

### Camada 2 — Inteligência determinística

Transforma dados em métricas e sinais.

Exemplo:

“frequência caiu 14%”.

### Camada 3 — Inteligência generativa

Transforma métricas e sinais em interpretação.

Exemplo:

“a maior parte da queda ocorreu no horário noturno”.

Esse modelo reduz risco de respostas incorretas e mantém a IA longe de responsabilidades que sistemas tradicionais executam melhor.

---

# 19. Out of Scope

Para evitar que o projeto se transforme em uma plataforma completa de gestão de academias, ficam inicialmente fora do escopo:

- sistema financeiro;
- cobrança;
- controle de mensalidades;
- vendas;
- CRM;
- matrícula;
- gestão de contratos;
- planos;
- treinos;
- avaliações físicas;
- nutrição;
- aplicativo de aluno;
- integração com catracas físicas;
- folha de pagamento;
- gestão de funcionários;
- campanhas comerciais automáticas;
- envio automático de mensagens;
- previsão financeira;
- reconhecimento facial;
- análise de vídeo;
- recomendação de treino;
- substituição de sistemas de gestão existentes.

O sistema deve atuar como uma **camada de inteligência operacional**, não como um ERP de academia.

---

# 20. Riscos e ambiguidades

## Risco 1 — Escopo crescer excessivamente

O domínio fitness permite adicionar dezenas de funcionalidades.

Mitigação:

manter o foco em análise operacional.

---

## Risco 2 — Criar IA sem necessidade

Adicionar IA a operações determinísticas aumenta complexidade e reduz confiabilidade.

Mitigação:

usar IA somente para interpretação, síntese e interação.

---

## Risco 3 — Respostas inventadas

Modelos de IA podem fornecer explicações não sustentadas pelos dados.

Mitigação:

fornecer contexto estruturado, restringir respostas e exigir evidências.

---

## Risco 4 — Definição incorreta de “risco de abandono”

Uma redução de frequência não significa necessariamente que um aluno pretende cancelar.

Mitigação:

tratar o recurso inicialmente como **sinal comportamental**, não como previsão.

---

## Risco 5 — Poucos dados para demonstração

Um dataset pequeno ou artificial demais pode produzir análises pouco convincentes.
Mitigação:

criar dados demonstrativos com padrões coerentes.

---

## Risco 6 — Copiar funcionalidades já existentes

Um dashboard tradicional de gestão pode se aproximar de funcionalidades já presentes em produtos do mercado ou da própria empresa.

Mitigação:

o diferencial deve estar na camada de investigação e interpretação operacional.

---

# 21. Open Questions

As perguntas abaixo precisarão ser respondidas antes ou durante o desenho técnico.

### Produto

1. O MVP representará apenas uma unidade ou várias?
2. Qual período padrão será exibido?
3. Quais indicadores devem aparecer primeiro no dashboard?
4. O que exatamente caracteriza uma situação que merece atenção?
5. Os insights terão níveis de prioridade?

### Dados

6. Qual será o volume do dataset de demonstração?
7. Os dados serão totalmente sintéticos?
8. Quantos meses de histórico serão necessários?
9. Devemos simular sazonalidade?
10. Devemos simular alunos com diferentes padrões de frequência?

### Abandono

11. Qual regra inicial define redução significativa de frequência?
12. Quantos dias sem acesso devem gerar atenção?
13. Devemos combinar mais de um indicador para gerar o sinal?

### IA

14. Quais perguntas o copiloto deverá obrigatoriamente responder no MVP?
15. A IA poderá realizar consultas exploratórias ou trabalhará apenas com indicadores previamente calculados?
16. Quanto contexto de conversas anteriores deverá ser mantido?
17. Como as evidências das respostas serão exibidas?

### Demonstração

18. Qual história deverá ser demonstrada para a diretoria?
19. Qual cenário de problema será utilizado?
20. Quais ações do desenvolvimento precisam evidenciar explicitamente o processo AI-native?

---

# 22. Acceptance Criteria do MVP

O MVP será considerado funcional quando os critérios abaixo forem atendidos.

## AC-01 — Login

**Dado** um usuário autorizado
**Quando** realizar autenticação válida
**Então** deverá acessar o sistema.

---

## AC-02 — Dashboard

**Dado** um usuário autenticado
**Quando** acessar o dashboard
**Então** deverá visualizar os principais indicadores operacionais da unidade.

---

## AC-03 — Período

**Dado** o dashboard
**Quando** o usuário alterar o período de análise
**Então** os indicadores deverão refletir o período selecionado.

---

## AC-04 — Comparação

**Dado** um período selecionado
**Quando** houver dados anteriores disponíveis
**Então** o sistema deverá apresentar comparação com o período equivalente anterior.

---

## AC-05 — Frequência

**Dado** um conjunto de registros de acesso
**Quando** o usuário visualizar a análise de frequência
**Então** deverá ser possível identificar a evolução dos acessos ao longo do período.

---

## AC-06 — Ocupação

**Dado** um conjunto de acessos
**Quando** o usuário visualizar distribuição por horário
**Então** deverá identificar os períodos de maior e menor utilização.

---

## AC-07 — Aluno

**Dado** um aluno existente
**Quando** o gestor acessar seus detalhes
**Então** deverá visualizar seu histórico recente de frequência.

---

## AC-08 — Sinal de redução de frequência

**Dado** um aluno cuja frequência tenha caído além do limite definido
**Quando** o sistema processar os indicadores
**Então** o aluno deverá receber um sinal de atenção.

---

## AC-09 — Insight operacional

**Dado** que uma mudança relevante ocorreu nos dados
**Quando** o usuário acessar a área de atenção
**Então** o sistema deverá apresentar o evento e as evidências utilizadas.

---

## AC-10 — Pergunta ao copiloto

**Dado** um usuário autenticado
**Quando** enviar uma pergunta relacionada aos dados da unidade
**Então** o copiloto deverá interpretar a pergunta e produzir uma resposta baseada nos dados disponíveis.

---

## AC-11 — Evidência

**Dado** que o copiloto apresenta uma conclusão analítica
**Quando** houver dados que fundamentam essa conclusão
**Então** a resposta deverá indicar quais informações sustentam a análise.

---

## AC-12 — Dados insuficientes

**Dado** que uma pergunta não pode ser respondida com os dados disponíveis
**Quando** o copiloto processar a pergunta
**Então** deverá informar que não existem evidências suficientes para concluir.

---

## AC-13 — Segurança

**Dado** um usuário sem acesso a determinada unidade
**Quando** tentar consultar seus dados
**Então** o sistema deverá impedir o acesso.

---

## AC-14 — Independência da IA

**Dado** que o serviço de IA esteja indisponível
**Quando** o usuário acessar o dashboard
**Então** os indicadores tradicionais deverão continuar funcionando.

---

# 23. Definição resumida do MVP

O MVP pode ser descrito em uma única frase:

> **Um dashboard operacional de academia que detecta mudanças relevantes nos dados e permite que o gestor investigue essas mudanças conversando com um copiloto de IA fundamentado nos dados da unidade.**

O produto não pretende ser um sistema completo de gestão de academias.

Seu foco é demonstrar:

**observar → detectar → investigar → compreender.**

Essa sequência deve orientar as próximas decisões de produto e arquitetura.

Esse escopo já cria uma separação importante para o projeto: **o software calcula fatos; a IA interpreta fatos**. Isso permite demonstrar IA de maneira tecnicamente justificável e, ao mesmo tempo, abre espaço para mostrar requisitos, modelagem, segurança, testes, observabilidade e avaliação das respostas de IA durante as próximas etapas.
