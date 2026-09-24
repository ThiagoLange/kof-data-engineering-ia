# Visão Geral — Treinamento Kof para Engenharia de Dados & IA

> 51 labs, 11 módulos, 8 datasets, 100% em `kof 0.4.10-beta` (`~/.kof/bin/kof`).

## Mapa de Módulos

| Módulo | Labs | Foco | Datasets |
|--------|------|------|----------|
| 00 Setup | 1 | `kof version/info/check/inspect` + 8 datasets | `iris_full.csv` 150 |
| 01 Fundamentos | 6 | CSV, JSONL, `spawn/await` (fix #31), binário RLE, `kof.log`, PII | `employees.csv` |
| 02 Dataframe | 5 | `DataFrame`/`Series`, `GroupBy`/`Join`, SVG, HTML | `iris.csv` |
| 03 ML | 6 | `zscore`/`oneHot`, SGD, Tree `gini`, `falseNeg`, hold-out `70/30`, PSI | `houses.tsv` |
| 04 Deep | 5 | `Tensor`, `Value` Autograd, `MLP`, `Adam` (`List<Double>`), Registry | `iris.csv` |
| 05 LLMs | 7 | `LLMClient`, `tokenize`/`chunk`, `cosine`, `VectorStore` (`List<Double>`), semântico, RAG `MRR`, `ECE` | `docs.jsonl` |
| 06 Agentes | 6 | `Tool` JSON Schema, `ReAct`, `Sandbox` 280 linhas, `Conversation`, MCP, `evalTraces` | `customers/docs` |
| 07 Integração | 3 | Batch `CSV→HTML`, RAG `12 chunks`, Agente com memória | todos |
| 08 Data | 8 | Lakehouse `watermark`, DQ `log`, MQ `tumbling`, FeatureStore, DAG `health`, Contratos, CDC `WAL`, Cache TTL | `transactions` |
| 09 Portabilidade | 3 | `log` 3 targets, `profile` 1M, `inspect`/`debug` | — |
| 10 Capstone | 1 | Pipeline completo `ingest→serve` | todos |

## Comandos

```bash
export PATH="$HOME/.kof/bin:$PATH"
kof run <lab.kof>              # 51/51 OK
kof test <exercise/exercise.kof>        # 51 suítes, 0 failed
bash scripts/run-tests.sh      # fmt + testes (51 suítes, ~90s em 0.4.10)
kof inspect <lab.kof>          # IR
kof profile <lab.kof>          # CPU/RSS
kof build --target native|js <lab.kof> # gates CONC001/DB001
```

> **Passo a passo completo por lab:** `docs/GUIA_EXECUCAO.md` (00→10, cada lab com `kof run` + `kof test` + artefatos).

## Docs

- `Claude.md` — estrutura modular completa (51 labs)
- `docs/LIMITACOES-KOF-0.1.3.md` — migração `0.1.3→0.4.10` (2 gaps mantidos)
- `docs/GLOSSARIO.md` — Kof×Python/Spark
- `docs/BENCHMARKS.md` — `profile`/`bench` para `tensor`/`RLE`
- `docs/RUBRICA.md` — certificação Básica/Intermediária/Avançada
- `docs/EXERCISES.md` — padrão `TODO`
- `docs/TEMPLATE-LICAO.md` — template por lab (51)
