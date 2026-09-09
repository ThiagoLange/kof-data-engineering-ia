# Lab 5.3 — Motor de Similaridade Vetorial (Cosine Distance)

## Objetivo

Implementar cosine similarity/distance sobre `List<Double>` com validação de dims, batch scoring, e recuperação top-k — a primitiva matemática por trás de todo ranking de embeddings em RAG.

## Conceito

Dados `a, b` vetores:

```
cos_sim(a,b) = dot(a,b) / (|a|·|b|)      ∈ [-1,1]  (1 = idêntico, 0 = ortogonal)
cos_dist = 1 - cos_sim                   ∈ [0,2]
```

- `dot` acumula `a_i·b_i` com checagem de dimensão; `norm = sqrt(dot(a,a))`.
- `cosineSimilarityBatch` aplica sobre `candidates × query`.
- `topK` é selection iterativo O(n·k) por máximo linear (sem `sort`).

Verificação: ortogonais `[1,0] vs [0,1] → 0`; escalados `[1,1] vs [2,2] → 1.0` (invariante a escala).

## Diagrama

```
 query [4] ─┬─► dot(query, doc_i) ─► / (norm(query)·norm(doc_i)) ─► sim_i
            │                                                      │
 doc_0 [4] ─┤                                                      ├─► [sim_0..sim_4]
 doc_1 [4] ─┤                                                      │
 ...        └──────────────────────────────────────────────────────┘
                              │
                              ▼
                           topK(k=2) ─► [idx_best, idx_2nd] (descending)
```

## Dataset

Vetores estáticos 4-D codificados no código (5 docs: Kof, Data Eng, Vector Store... + query Kof-like). Sem arquivo externo — embeddings reais viriam do Lab 5.1/5.4.

## Comandos

```bash
kof run modulo-05-llms/03-cosine-similarity/lab.kof
kof test modulo-05-llms/03-cosine-similarity/exercise.kof
```

## Padrões & Idiomática Kof

- **`throw` em dim mismatch / empty / zero-norm** — erro de programação, não NaN silencioso.
- **`List<List<Double>>` para batch** — matriz de embeddings (rows=docs, cols=dims).
- **`1.0 * n` não necessária** (sem contagens); `Double` domina desde o início.
- **Sem `sort`** — `topK` é seleção manual (bubble-like mas sobre scores, nãoDocs).

## Gaps & Limitações

- Sem SIMD/Native accel; `dot` é O(d) puro.
- Sem `Map` de id→vector — `labels` é lista paralela (mesmo idiom dos labs de decisão-tree).
- Native gap irrelevante (curso é JVM); JS igual.
