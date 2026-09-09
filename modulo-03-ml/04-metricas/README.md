# Lab 3.4 — Suíte de Avaliação de Métricas Preditivas

## Objetivo

Implementar métricas de classificação binária (Matriz de Confusão, Acurácia, Precisão, Recall, F1-Score) a partir de vetores `y_true`/`y_pred` 0/1, lendo o dataset real `datasets/classification_eval.jsonl` e tratando divisões por zero (caso `TP+FP=0`).

## Conceito

Dados `TP` (verdadeiros positivos), `TN`, `FP`, `FN` contados por varredura linear:

- **Acurácia** = (TP+TN)/N — proporção de acertos totais.
- **Precisão** = TP/(TP+FP) — dentre os preditos positivos, quantos são reais (evita falsos alarmes). Zero quando `TP+FP=0`.
- **Recall** = TP/(TP+FN) — dentre os reais positivos, quantos foram capturados (evita perdas). Zero quando `TP+FN=0`.
- **F1** = 2·P·R/(P+R) — média harmônica que penaliza desequilíbrio entre precisão e recall.

O dataset tem 10 amostras com 1 erro de cada tipo (FP=1, FN=1) → métricas 0.8/0.833.

## Diagrama

```
 classification_eval.jsonl ─► loadEval (scanIntArray ×2) ─► [y_true, y_pred]
                                                             │
                                                             ▼
                                                    confusionMatrix ─► Confusion(TP,TN,FP,FN)
                                                             │
                                        ┌────────────────────┼────────────────────┐
                                        ▼                    ▼                    ▼
                                    accuracy           precision              recall
                                        │                    │                    │
                                        └────────────────────┼────────────────────┘
                                                             ▼
                                                         f1Score
```

## Dataset

- `datasets/classification_eval.jsonl` — 1 linha JSON com `y_true` e `y_pred` (10 ints 0/1 cada). Parsing via `scanIntArray` (evita gap de `json.decode` com `List<Int>` aninhado).

## Comandos

```bash
kof run modulo-03-ml/04-metricas/lab.kof
kof test modulo-03-ml/04-metricas/exercise.kof
```

## Padrões & Idiomática Kof

- **Records `Confusion`/`Metrics`** como valores imutáveis retornados por funções puras.
- **Guard de divisão por zero** — `precision`/`recall` retornam 0.0 quando denominador é 0 (sem throw; convenção ML).
- **`throw` para inputs inválidos** (tamanhos diferentes, labels fora de {0,1}, vazio).
- **`1.0 * n` para Int→Double** (COMP002).
- **String scanning** ao invés de `json.decode<List<Int>>` aninhado — workaround de gap JSN00x.

## Gaps & Limitações

- Métricas binárias apenas; extensão multiclasses requer média macro/micro.
- `json.decode` com `List<Int>` aninhado em record não suportado no beta — mitigação por scanning manual (ver `docs/LIMITACOES-KOF-0.1.3.md`).
- Sem `Map` de labels — labels fixos 0/1; para K classes, usar `List<Int>` de contagens por classe.
