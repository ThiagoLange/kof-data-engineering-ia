# Lab 8.1 — Lakehouse Incremental (Partição + Watermark + Time Travel)

## Objetivo
Implementar ingestão incremental particionada por `city` (`lake_<city>_v<ver>.jsonl`) com watermark `watermark.csv` (`lastTxId,version`) e `time travel` via histórico de watermarks.

## Conceito
Lakehouse = arquivos particionados + catálogo de versões. `incrementalIngest` filtra `tx_id > lastTxId`, escreve partições por cidade e appenda `watermark.csv`. Segunda ingestão sem dados é idempotente; terceira com `tx 108` cria `v2`. Partições são `jsonl` por cidade, permitindo `time travel` lendo `v1` vs `v2`.

## Comandos
```bash
kof run modulo-08-data/01-lakehouse/lab.kof
kof test modulo-08-data/01-lakehouse/exercise.kof
```

## Padrões
- `cityForTx` linear scan (datasets pequenos); produção usaria `Map`.
- `File.writeText` para partições (flat, sem subdir para evitar `mkdir` em Kof).
- Watermark como `csv` append-only — auditável.

## Gaps
- Sem `kof.db` catálogo ainda; próxima iteração usa SQLite nativo.
- `mkdir` não existe em Kof 0.3.2 — partições são flat, não `city=SP/part-*.parquet`.
