# Lab 8.7 — CDC + Exactly-Once (WAL + Watermark Compaction)
## Objetivo
Simular CDC com `WAL` (`wal.jsonl` append-only), `applyWAL` idempotente via `watermark` e `compaction` (mantém só `txId > watermark`).
## Comandos
```bash
kof run modulo-08-data/07-cdc/lab.kof
kof test modulo-08-data/07-cdc/exercise.kof
```
