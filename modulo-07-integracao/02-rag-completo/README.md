# Lab 7.2 — RAG Completo (Chunking → Vector Store → Retrieval → Prompt)

## Objetivo

Encadear `05-02` (chunking 8/3), `05-04` (VectorStore fake embeddings), `05-03` (cosine) em pipeline RAG: cada doc de `docs.jsonl` é chunkado, cada chunk indexado, query recupera top-3, `buildPrompt` monta contexto e `FakeLLM` gera resposta.

## Conceito

RAG = `index(chunks → embeddings → store) → retrieve(query → top-k) → generate(prompt → answer)`. Aqui embeddings são `fakeEmbed` (char-hash 4-D) e geração é `FakeLLM` determinística, tornando o pipeline testável sem rede.

## Diagrama

```
docs.jsonl ─► chunkByWords(8,3) ─► per chunk fakeEmbed ─► VectorStore
                                                        │
query ─► fakeEmbed ─► cosineSim vs all ─► topK(3) ─► Retrieval
                                                        │
                                          buildPrompt ─► "Context:\n- [id] ...\nQuestion: ..."
                                                        │
                                          fakeGenerate ─► Answer
```

## Comandos

```bash
kof run modulo-07-integracao/02-rag-completo/lab.kof
kof test modulo-07-integracao/02-rag-completo/exercise.kof
```

## Padrões

- Compact format para 0.3.2 (evita LineNumberTable).
- `embeddingCsv` em `DocEntry` (compatível 0.3.2, ver `05-04`).
- `safeHead` para evitar `substring` OOB em chunks curtos.
