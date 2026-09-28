# Lab 8.1 — Lakehouse Incremental (Partição + Watermark + Time Travel)

## Objetivo
Implementar ingestão incremental particionada por `city` (`lake/city=<city>/part-v<ver>.jsonl`, estilo hive) com watermark `watermark.csv` (`lastTxId,version`) e `time travel` via histórico de watermarks.

## Conceito
Lakehouse = arquivos particionados + catálogo de versões. `incrementalIngest` filtra `tx_id > lastTxId`, cria o diretório da partição com `Directory(...).createDirectories()` e escreve `part-v<ver>.jsonl` por cidade, depois appenda `watermark.csv`. Segunda ingestão sem dados é idempotente; terceira com `tx 108` cria `v2`. Partições são `jsonl` por cidade, permitindo `time travel` lendo `v1` vs `v2`.

## Comandos
```bash
kof run modulo-08-data/01-lakehouse/lab.kof
kof test modulo-08-data/01-lakehouse/exercise/exercise.kof
```

## Padrões
- `cityForTx` linear scan (datasets pequenos); produção usaria `Map`.
- `Directory(...).createDirectories()` + `File.writeText` para partições (`File.mkdir()` voltou a funcionar em 0.5.0, mas `Directory` fica — ver `docs/LIMITACOES-KOF-0.1.3.md`).
- Watermark como `csv` append-only — auditável.

## Gaps
- Sem `kof.db` catálogo ainda; próxima iteração usa SQLite nativo.
- `File.mkdir()` era no-op silencioso até 0.4.x (corrigido em 0.5.0); `Directory.createDirectories()` segue recomendado.
