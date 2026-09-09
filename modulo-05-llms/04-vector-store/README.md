# Lab 5.4 — Banco Vetorial Simples em Memória (Vector Store RAG)

## Objetivo

Construir `VectorStore` em memória com fake embeddings determinísticos, busca k-NN por cosine similarity, persistência JSONL e demonstração RAG sobre `datasets/docs.jsonl`.

## Conceito

RAG indexa docs como vetores para recuperar contexto antes da chamada LLM:

```
fakeEmbed(text, dim=4): char-hash bucketed + L2-normalize  (determinístico)
add(id, text): embed + append DocEntry
search(query, k): embed query, score todas via cosineSim, topK por seleção
persist(path): json.encode per DocEntry, File.writeText
loadStore(path): read + json.decode per line
```

`fakeEmbed` soma `charAt` em `bucket = i % dim` e normaliza — não é semântico, mas determinístico e suficiente para validar o pipeline (embeddings reais viriam do Lab 5.1 provider).

## Diagrama

```
 datasets/docs.jsonl ─► loadDocsJsonl ─► [DocJson]
                                          │
                           for each doc ─► store.add(id, title+" "+body)
                                          │  fakeEmbed → DocEntry(embedding)
                                          ▼
                                     VectorStore(docs)
                                          │
                       search("Kof typed")─┼─► fakeEmbed(query) ─► cosineSim vs all ─► topK(2)
                                           │
                       persist ────────────┼─► File.writeText(json.encode per line) ─► store.jsonl
                                           │
                       loadStore ──────────┘─► reloaded.search(query,1) ─► same top-1
```

## Dataset

- `datasets/docs.jsonl` — 5 docs (d1..d5) indexados; truncado a 40 chars no log.

## Comandos

```bash
kof run modulo-05-llms/04-vector-store/lab.kof
kof test modulo-05-llms/04-vector-store/exercise.kof
```

## Padrões & Idiomática Kof

- **`class VectorStore` com `List<DocEntry>` mutável** — `add`/`search` mutam `docs` via `add`.
- **`List.set` não necessária em store** — apenas `add` e leitura; fakeEmbed usa `set` nos buckets.
- **`throw` em dim mismatch / k≤0 / zero-norm**.
- **Persistência JSONL**: uma linha por doc, `json.encode/decode<DocEntry>` (JVM-only, mesma limitação dos Labs 1.2/6.1).

## Gaps & Limitações

- Fake embeddings não são semânticos — para similarity real, substituir `fakeEmbed` por chamada a `LLMClient` (Lab 5.1) com modelo de embeddings.
- Sem `Sort` — `search` usa seleção topK O(n·k) idêntica ao Lab 5.3.
- Sem índice ANN (HNSW/IVF) — busca é linear O(n·dim), aceitável para n<10k; produção exigiria índice nativo (portar para Native com `kof.db` SQLite vetorial).
- `DocEntry.embedding` como `List<Double>` funciona em JSON (JVM), mas JS gap JSN002 para Double precisa ser verificado.
