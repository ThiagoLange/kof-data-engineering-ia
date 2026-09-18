# Lab 7.1 — Pipeline Batch End-to-End (CSV → Join → GroupBy → HTML)

## Objetivo

Encadear em um único `main` os labs `01-01` (parser), `02-02` (join/agg) e `02-04` (HTML com canvas) — o fluxo batch clássico: ingestão → transformação → relatório.

## Conceito

Dados cruzam módulos como funções puras: `loadCustomers/Transactions` (json), `computeAgg` (join linear + groupby), `buildHtml` (tabela + `jsData` para canvas). `loadIrisSummary` apenas referencia `iris.csv`/`iris_full.csv` para provar que o pipeline lê múltiplos datasets.

É a integração horizontal que faltava — cada lab isolado vira estágio de pipeline.

## Diagrama

```
customers.jsonl ─┐
                 ├─► computeAgg ─► [Agg(city,cnt,tot,mean)]
transactions.jsonl┘          │
iris.csv ─► loadIrisSummary ─┘
                             ▼
                         buildHtml ─► report.html (tabela + canvas)
```

## Comandos

```bash
kof run modulo-07-integracao/01-pipeline-batch/lab.kof
kof test modulo-07-integracao/01-pipeline-batch/exercise/exercise.kof
```

## Padrões

- Funções puras compostas; `main` orquestra I/O ↔ lógica.
- `htmlEscape`/`jsData` idênticos ao Lab 02-04 — reutilização intencional.
- Formato legível (compact era workaround 0.3.2 `LineNumberTable`, corrigido em 0.3.22+).
