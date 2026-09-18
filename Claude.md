# CLAUDE.md - Diretrizes de Desenvolvimento: Treinamento em Kof para IA e Dados

Este repositório contém o material didático, labs executáveis e referências do curso da **Linguagem Kof (https://koflang.github.io/)** voltado a Engenharia de Dados, Ciência de Dados, Machine Learning, Deep Learning, LLMs e Agentes Autônomos.

---

## 1. Perfil e Diretrizes Gerais

- **Perfil:** Arquiteto de Dados e Engenheiro de Machine Learning / IA.
- **Abordagem:** Orientada a código limpo, tipado, modular e pronto para produção (*production-ready*).
- **Idioma:** Explicações conceituais em Português do Brasil; identificadores de código, testes, logs e comentários de documentação em inglês técnico padrão.
- **Rigor Sintático:** Respeitar a especificação e sintaxe canônica documentada em `https://koflang.github.io/`. Havendo gaps de bibliotecas nativas de ponta, demonstrar o padrão arquitetural equivalente em Kof (parsers, structs, math primitives) ou bridging/FFI.

---

## 2. Estrutura Modular e Relação de Exemplos Práticos

Cada lição deve conter: `README.md` (conceito + diagrama), `lab.kof` (código completo comentado) e `exercise.kof` (com asserções `assert`). **Total: 51 labs em 11 módulos (0–10), 100% em `kof 0.4.4-beta`.**

### Módulo 00: Setup & Toolchain
- **Exemplo 0.1: Verificação da Toolchain Kof** — `kof version/info/check/inspect` + validação de `datasets/` (8 arquivos, `iris_full.csv` 150 linhas).

### Módulo 01: Fundamentos de Kof para Engenharia de Dados
- **Exemplo 1.1: Parser e Leitura Streamed de Arquivos Delimitados (CSV/TSV)**
- **Exemplo 1.2: Serialização e Desserialização de Schemas JSON e JSONL**
- **Exemplo 1.3: Pipeline de Transformação Concorrente / Paralela** — `spawn` + `Handle<T>` + `await` memoizado (fix #31, mantido em 0.4.4; `spawn f(var)` funciona)
- **Exemplo 1.4: I/O Binário e Compressão de Dados** — formato `KOF1` + RLE
- **Exemplo 1.5: Observabilidade e Validação (`kof.log`)** — `log.info/error` JSON + validação manual (`isEmail`, `required`)
- **Exemplo 1.6: PII + Secrets + RateLimit (`kof.security`)** — `maskEmail`/`maskSsn` + `secrets.get` + `RateLimiter`

### Módulo 02: Manipulação e Visualização de Dados
- **Exemplo 2.1: Implementação de Estrutura DataFrame em Kof**
- **Exemplo 2.2: Agregações, GroupBy e Joins Relacionais**
- **Exemplo 2.3: Motor de Geração de Gráficos em SVG Puro**
- **Exemplo 2.4: Exportador de Relatório HTML Interativo**
- **Exemplo 2.5: Gráficos para a Web (SVG + Canvas KofJS)** — `dashboard.html` com `scatter/bar` SVG + `<canvas>` `kof.ui`/`KofJS`, servível via `kof serve`/`kof.web`

### Módulo 03: Machine Learning Clássico
- **Exemplo 3.1: Normalização e Engenharia de Features**
- **Exemplo 3.2: Regressão Linear com Gradiente Descendente Estocástico (SGD)**
- **Exemplo 3.3: Classificador de Árvore de Decisão Simples (ID3 / Gini Impurity)**
- **Exemplo 3.4: Suíte de Avaliação de Métricas Preditivas** — `falseNeg` (renomeado de `fn`, `PARSE085` mantido em 0.4.4)
- **Exemplo 3.5: Hold-out e K-Fold Cross-Validation** — `holdout(0.7)` `11/4` + `kFoldSplits(3)` → `0.978` em `iris_full.csv`
- **Exemplo 3.6: PSI / Drift e Calibration (ECE)** — `psi` 5 bins `iris vs iris_full` + `ECE` 5 bins

### Módulo 04: Deep Learning & Tensores
- **Exemplo 4.1: Classe Tensor N-Dimensional e Operações de Álgebra Linear**
- **Exemplo 4.2: Grafo Computacional e Diferenciação Automática (Autograd)** — `Value` + `backward` recursivo (bug `Value==Value` corrigido em 0.3.22+, verificado em 0.4.4)
- **Exemplo 4.3: Perceptron Multicamadas (MLP) para Classificação Não-Linear**
- **Exemplo 4.4: Otimizadores e Checkpoint de Modelos** — `Adam` + `Checkpoint` `List<Double>` idiomático (workaround `paramsCsv` removido em 0.3.22+)
- **Exemplo 4.5: Model Registry (`kof.log` + `kof.web` simulado)** — `ModelVersion` + promoção por `accuracy` + `registry.jsonl`

### Módulo 05: LLMs & Engenharia de Embeddings
- **Exemplo 5.1: Cliente HTTP para Inferência de Modelos Fundacionais**
- **Exemplo 5.2: Tokenizador e Estratégia de Chunking Semântico**
- **Exemplo 5.3: Motor de Similaridade Vetorial (Cosine Distance)**
- **Exemplo 5.4: Banco Vetorial Simples em Memória (Vector Store RAG)** — `DocEntry` `List<Double>` idiomático (workaround `embeddingCsv` removido em 0.3.22+)
- **Exemplo 5.5: Chunking Semântico (por sentença)** — `chunkBySentence` vs `chunkSemantic(maxWords=10)`
- **Exemplo 5.6: Avaliação RAG (`hit@k`, `MRR`)** — 3 queries sintéticas sobre `docs.jsonl`
- **Exemplo 5.7: Avaliação LLM (`latency`/`tokens` + `ECE` real)** — `fakeLLM` + `wordSplit` + `ECE` 5 bins

### Módulo 06: Agentes de IA e Tool Calling
- **Exemplo 6.1: Schema de Ferramentas e Serialização de Chamadas**
- **Exemplo 6.2: Loop de Raciocínio ReAct (Reasoning + Acting)**
- **Exemplo 6.3: Execução Segura e Sandboxing de Ferramentas** — 280 linhas legível (formato compact não mais necessário desde 0.3.22+)
- **Exemplo 6.4: Gerenciamento de Memória Conversacional e Estado de Agente**
- **Exemplo 6.5: MCP-like Tool Server (`kof.web` simulado)** — `ToolServer` + `register`/`call`
- **Exemplo 6.6: Avaliação de Agente (`success@k`, `tool_error_rate`)** — `evalTraces`

### Módulo 07: Integração End-to-End
- **Exemplo 7.1: Pipeline Batch (`CSV → Join → GroupBy → HTML`)** — compõe `01-01 + 02-02 + 02-04`
- **Exemplo 7.2: RAG Completo (`Chunking → VectorStore → Retrieval → Prompt`)** — compõe `05-02 + 05-04 + 05-03`
- **Exemplo 7.3: Agente com Memória (`ReAct + Sandbox + Conversation`)** — compõe `06-02 + 06-03 + 06-04`

### Módulo 08: Data Engineering Moderna
- **Exemplo 8.1: Lakehouse Incremental (Partição + Watermark + Time Travel)** — `lake_<city>_v<ver>.jsonl` + `watermark.csv`
- **Exemplo 8.2: Data Quality (Expectations + `kof.log`)** — `validateCustomer` + `report.html`
- **Exemplo 8.3: Streaming com `kof.mq` (Tumbling Window)** — `SimpleMQ` + janela 3 `sum`
- **Exemplo 8.4: Feature Store (`kof.db` + `kof.cache` simulado)** — `FeatureStore` `put`/`get`
- **Exemplo 8.5: Orquestrador DAG (`scheduler` + `health`)** — `Scheduler` `ingest→validate→feature→evaluate`
- **Exemplo 8.6: Contratos & Linhagem (`correlationId`)** — `Schema` `version` + `Lineage` `lineage.jsonl`
- **Exemplo 8.7: CDC + Exactly-Once (`WAL` + `watermark` + `compaction`)**
- **Exemplo 8.8: Feature Store Online (`kof.cache` TTL)** — `Cache` `List<Double> nowBox` + `tick`

### Módulo 09: Portabilidade & Performance
- **Exemplo 9.1: Portabilidade Native/JS (`LOG001`)** — `log` + `File` nos 3 targets
- **Exemplo 9.2: Perf Native vs JVM (`kof profile`)** — `1M loop` + gates `CONC001`/`DB001`
- **Exemplo 9.3: Contributing (`kof inspect`/`kof debug`)** — `IR` + `known-bugs`

### Módulo 10: Capstone Produtivo
- **Exemplo 10.1: Pipeline Completo (`ingest→validate→feature→RAG→register→serve`)** — integra `08-01 + 08-02 + 08-04 + 03-06 + 04-05 + 05-04 + 06-05`

---

## 3. Padrões de Implementação de Código

- **Sem dependências ocultas:** Todo script que use dados de exemplo deve consumir arquivos localizados na pasta raiz `./datasets/` (ex: `datasets/boston.csv`, `datasets/docs.jsonl`).
- **Tratamento Robusto de Erros:** Não use retorno nulo silencioso nem `panic`/`abort` injustificados; trate exceções e retorne tipos `Result`/erros explícitos conforme a semântica da linguagem Kof.
- **Assertividade:** Todos os arquivos de exercício (`exercise.kof`) devem conter asserções comentadas (`assert eq(result, expected)`) para conferência imediata via CLI.
- **Credenciais:** Chaves de API e segredos devem ser lidos obrigatoriamente de variáveis de ambiente do sistema (`ENV["LLM_API_KEY"]`), jamais gravados estaticamente no código.

---

## 4. Workflows e Comandos Padrão

- **Executar script:** `kof run path/to/script.kof`
- **Rodar asserções/testes:** `kof test path/to/exercise/exercise.kof`
- **Formatação:** `kof fmt path/to/file.kof`
