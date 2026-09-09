# Lab 5.2 — Tokenizador e Estratégia de Chunking Semântico

## Objetivo

Implementar tokenização por scan de caracteres (lowercase, split de pontuação, vocab de frequências) e chunking com janela deslizante e overlap configurável — por palavras e por caracteres — sobre `datasets/docs.jsonl`.

## Conceito

RAG e training de LLMs exigem quebrar documentos em pedaços que caibam na janela de contexto:

1. **Tokenize** (`tokenize`): percorre chars; `isAlnum` decide palavra vs pontuação; palavras são `toLowerCase`, pontuação vira token isolado.
2. **Vocab**: `buildVocab` deduplica com contagem (ordem de inserção), similar a um Counter.
3. **Chunk por palavras** (`chunkByWords`): `wordSplit` por `" "` → janela `window` com passo `window-overlap`; último chunk pode ser menor.
4. **Chunk por caracteres** (`chunkByChars`): mesmo algoritmo mas sobre `substring` de chars (útil quando tokens ~ chars).

Janela 8 / overlap 3 → passo 5, exemplificando 4 chunks sobre doc concatenado.

## Diagrama

```
 docs.jsonl ─► parseDocs ─► [Doc(title,body)] ─► tokenize(doc) ─► [token]
                                                      │
                                                      ▼
                                                  buildVocab ─► [VocabEntry(token,freq)]

 concatenated corpus ─► chunkByWords(window=8,overlap=3) ─► [chunkStr] (“overlap” words reused)
 single body ─► chunkByChars(window=30,overlap=10) ─► [chunkStr] (char overlap)
```

## Dataset

- `datasets/docs.jsonl` — 6 docs (Kof, Data Eng, Vector Stores...) com `id,title,body,lang`; chunking é demonstrado sobre o corpo do primeiro doc e sobre o corpus concatenado.

## Comandos

```bash
kof run modulo-05-llms/02-tokenizer-chunking/lab.kof
kof test modulo-05-llms/02-tokenizer-chunking/exercise.kof
```

## Padrões & Idiomática Kof

- **Scan char a char com `charAt/length/substring`**: único jeito sem `split` regex em 0.1.3-beta.
- **`throw` em window/overlap inválidos** (0 ou overlap ≥ window).
- **`List.set` para bump de freq em vocab** — `vocab.set(j, VocabEntry(..., freq+1))`.
- **Sem alocação de Tokenizer object**: funções puras sobre `String`/`List<String>`.

## Gaps & Limitações

- ASCII-only `isAlnum`; para Unicode, usar `charAt` com ranges extras.
- Sem BPE/subword — tokenização é word+punct; BPE futuro requer `Map` de merges.
- `toLowerCase()` é método de `String` disponível em JVM; Native gap irrelevante (curso é JVM).
