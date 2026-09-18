# Kof — Treinamento para Engenharia de Dados & IA

> 51 labs executáveis em `kof 0.4.4-beta` (`~/.kof/bin/kof`), 11 módulos (00–10), 8 datasets, 100% `kof test` pass.

**Quickstart:**
```bash
export PATH="$HOME/.kof/bin:$PATH"
kof version  # 0.4.4-beta
kof run modulo-00-setup/01-kof-toolchain/lab.kof
bash scripts/run-tests.sh
```

**Módulos:**
- **00 Setup** (1) — toolchain
- **01 Fundamentos** (6) — CSV, JSONL, `spawn/await`, binário, `kof.log`, PII
- **02 Dataframe** (5) — `DataFrame`/`Series`, `GroupBy`, SVG, HTML, Web `dashboard.html` + Canvas `KofJS`
- **03 ML** (6) — `zscore`, SGD, Tree, `falseNeg`, hold-out `70/30`, PSI
- **04 Deep** (5) — `Tensor`, Autograd `Value`, `MLP`, `Adam`, Registry
- **05 LLMs** (7) — `LLMClient`, chunking, `cosine`, `VectorStore`, semântico, `MRR`, `ECE`
- **06 Agentes** (6) — Tool Schema, `ReAct`, Sandbox compact, `Conversation`, MCP, avaliação
- **07 Integração** (3) — Batch, RAG 12 chunks, Agente com memória
- **08 Data** (8) — Lakehouse `watermark`, DQ, MQ `tumbling`, FeatureStore, DAG, Contratos, CDC `WAL`, Cache TTL
- **09 Portabilidade** (3) — `log` 3 targets, `profile`, `inspect`/`debug`
- **10 Capstone** (1) — Pipeline `ingest→serve` end-to-end

**Docs:**
- `docs/OVERVIEW.md` — mapa completo (51 labs)
- `docs/GUIA_EXECUCAO.md` — **passo a passo para cada lab** (00→10, `kof run`/`test`/`serve`/`build`)
- `Claude.md` — estrutura modular detalhada
- `docs/LIMITACOES-KOF-0.1.3.md` — `0.1.3→0.4.4` migração (2 gaps mantidos)
- `docs/GLOSSARIO.md` — Kof×Python/Spark
- `docs/BENCHMARKS.md` / `docs/RUBRICA.md` / `docs/EXERCISES.md`

**Datasets:** `datasets/` 8 arquivos (`iris_full.csv` 150 linhas novo em 0.3.22).

**Toolchain:** `kof 0.4.4-beta` em `~/.kof` (`~/.bashrc:205`), `kof run`/`test`/`check`/`inspect`/`profile`/`build --target native|js`.

> **Primeira vez?** Siga `docs/GUIA_EXECUCAO.md` do `Módulo 00` ao `10` — cada lab tem `kof run` + `kof test` documentados.
