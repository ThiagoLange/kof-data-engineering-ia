# Lab 8.2 — Data Quality (Expectations + kof.log)
## Objetivo
Validar `customers.jsonl` com expectations (`name required`, `city required`, `isEmail`) e `log.info`/`log.error` estruturado, gerando `report.html`.
## Comandos
```bash
kof run modulo-08-data/02-quality/lab.kof
kof test modulo-08-data/02-quality/exercise.kof
```
## Padrões
- `validateCustomer` retorna String vazia = pass; `log.error` para fails.
- `kof.validation` futuro substituirá checks manuais por `VAL001`.
