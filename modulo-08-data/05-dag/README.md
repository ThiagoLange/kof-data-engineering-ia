# Lab 8.5 — Orquestrador DAG (scheduler + observability)

location: modulo-08-data/05-dag
state: done
instructions:
  - test

## Objetivo
Simular DAG `ingest→validate→feature→evaluate` com `Scheduler` que `time.sleep` por step, `log.info` e `health()` check, demonstrando `kof.time.scheduler` e `kof.observability`.
## Comandos
```bash
kof run modulo-08-data/05-dag/lab.kof
kof test modulo-08-data/05-dag/exercise.kof
```
