# Lab 2.4 — Exportador de Relatório HTML Interativo

## Objetivo

Gerar um relatório HTML autossuficiente que combina tabela de métricas e gráfico de barras em `<canvas>` com JavaScript inline — o artefato final de um pipeline de dados: dados agregados injetados num template HTML via concatenação de strings.

## Conceito

Relatórios HTML interativos são a saída mais portável de um job batch: um único `.html` com tabela + canvas que abre em qualquer browser. O padrão é:

1. **Computar métricas**: mesmo `computeMetrics` do Lab 2.2 (count/total/mean por cidade) — reutilização intencional.
2. **Injetar em template**: `buildHtml` concatena `<table>` rows (`buildRows` com `htmlEscape` para `&<>`) e um bloco `<script>` que recebe os dados como JS literal (`buildJsData`) e desenha barras no canvas 2D.
3. **Canvas JS**: loop `for` em `data[]`, `fillRect` proporcional a `total/maxV`, rótulos com `fillText` — idêntico em lógica ao `barSvg` do Lab 2.3, mas renderizado no browser.

Todo HTML/JS é string concatenation pura — sem engine de template externa, sem dependência.

## Diagrama

```
 customers+transactions ─► computeMetrics ─► [MetricRow(city,count,total,mean)]
                                                    │
                           ┌────────────────────────┼────────────────────────┐
                           ▼                        ▼                        ▼
                      buildRows              buildJsData              buildHtml
                    <tr><td>...</td>       [{city:"SP",total:..}]   <!DOCTYPE html>
                           │                        │                        │
                           └────────────────────────┼────────────────────────┘
                                                    ▼
                                             File.writeText(report.html)
                                                    │
                                                    ▼
                                           browser opens → table + <canvas> bars
```

## Dataset

- `datasets/customers.jsonl` + `datasets/transactions.jsonl` (mesma fonte dos Labs 2.2/2.3).

## Comandos

```bash
kof run modulo-02-dataframe/04-html-report/lab.kof
kof test modulo-02-dataframe/04-html-report/exercise.kof
# abrir o resultado:
# xdg-open modulo-02-dataframe/04-html-report/report.html
```

## Padrões & Idiomática Kof

- **`htmlEscape` manual** para `&<>` — sem lib de template; XSS evitado mesmo em dados controlados.
- **`buildJsData` gera JS literal** com `city` como string quoted e `total` como número — `toString()` de Double já é JS-parseable.
- **`File.writeText` para o `.html`** — mesmo idiom dos Labs 1.2/2.3.
- **Métricas reutilizadas** — `computeMetrics` é cópia canônica de `groupByCity` adaptada para `MetricRow`.

## Gaps & Limitações

- Sem engine de template (`kof.web` template em desenvolvimento) — concatenação manual é o idiom atual.
- JS do canvas assume browser; validar HTML via `contains("<canvas")` e `contains("data = [")` nos testes.
- `htmlEscape` cobre só `&<>` — suficiente para cities ASCII; para i18n, escapar `"` também.
