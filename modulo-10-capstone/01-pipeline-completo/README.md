# Lab 10.1 — Capstone Pipeline Produtivo (Batch + RAG + Registry)

## Objetivo
Pipeline completo que integra `08-01` (lake), `08-02` (DQ), `08-04` (feature), `03-06` (drift proxy), `04-05` (registry), `05-04` (RAG) e `06-05` (serve) em único `main` — artefato de portfólio.

## Conceito
`ingest → validate → feature → rag (cosine) → register → serve → report.html`. Cada estágio reusa função pura de labs anteriores, com `log.info` por estágio.

## Comandos
```bash
kof run modulo-10-capstone/01-pipeline-completo/lab.kof
kof test modulo-10-capstone/01-pipeline-completo/exercise/exercise.kof
```

## Padrões
- Funções puras compostas, `main` orquestra I/O ↔ lógica.
- `ModelVersion` com `List<Double>` idiomático (workaround `paramsCsv` removido em 0.3.22+) + `registry.jsonl`.
- Formato legível (compact era workaround 0.3.2 `LineNumberTable`, corrigido em 0.3.22+).
