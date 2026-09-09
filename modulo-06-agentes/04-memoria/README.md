# Lab 6.4 — Gerenciamento de Memória Conversacional e Estado de Agente

## Objetivo

Implementar buffer de memória conversacional que conta tokens (wordSplit), detecta estouro de janela (`totalTokens > maxTokens`) e sumariza o meio do histórico, mantendo `system` + `keepLast` mensagens recentes — padrão para manter agentes dentro do context window do LLM.

## Conceito

LLMs têm janela fixa (ex.: 4k tokens); histórico longo estoura. Estratégia:

1. **`Conversation(msgs, maxTokens)`**: `add(role,content)`, `totalTokens()` (sum de `countTokens` per message), `needsSummarization()` (bool 0/1).
2. **Summarize**: quando `tokens>max`, `mid = msgs[1 .. n-keepLast)` vira uma única mensagem `system: "Summary of M earlier messages"`; mantém `msgs[0]` (system prompt) + `last keepLast` mensagens.
3. **External `summarizeConversation`**: contorna `field final` do beta (não permite reatribuir `msgs` dentro do método; função externa cria `new Conversation` com lista compactada).
4. **Context**: `getContext()` concatena `role: content\n` para o prompt final.

Demo simula 8 turnos com `maxTokens=30` (propositalmente pequeno para disparar 5 summarizations, terminando com 4 msgs / 25 tokens).

## Diagrama

```
 systemPrompt ─► Conversation([system], max=30)
       │
   add("What is Kof?" ...) ─► totalTokens=11 ─► keep
   add("Kof is statically ...") ─► 21 ─► keep
   add("How does type ...") ─► 27 ─► keep
   add("Kof checks types ...") ─► 37 >30 ─► summarize(keepLast=2)
       │  compact middle 2 msgs → [system, summary, last2]
       ▼
   add next ─► 34 >30 ─► summarize again ... (repetido 4×)
       ▼
   final 4 msgs, 25 tokens ─► getContext() ─► prompt para LLM
```

## Dataset

Nenhum dataset — histórico sintético de 8 mensagens sobre Kof (perguntas sobre type system, concurrency, JSON).

## Comandos

```bash
kof run modulo-06-agentes/04-memoria/lab.kof
kof test modulo-06-agentes/04-memoria/exercise.kof
```

## Padrões & Idiomática Kof

- **`class Conversation` com `List<ChatMessage>` mutável** — `add` via `msgs.add`; `totalTokens` via loop.
- **`field final` workaround**: `summarize` dentro da classe quebra (não pode `msgs = newMsgs`); função externa `summarizeConversation` cria novo `Conversation` (mesmo idiom do `FakeLLM.calls` com `List<Int>` box, mas para coleção inteira).
- **`wordSplit` para contagem de tokens** — proxy simples; em produção substituir por `tokenize` do Lab 5.2.
- **`throw` não necessário** — estados vazios retornam lista vazia; `keepLast` maior que size é clamp.

## Gaps & Limitações

- Sem LLM real para sumarizar (resumo é `Summary of M earlier messages`, não LLM-generated). Em produção, chamar `LLMClient.complete([summaryPrompt])` (Lab 5.1) para gerar resumo semântico.
- Tokenização é word-count, não BPE — sub-estima tokens de código/pontuação.
- Sem persistência de memória (poderia usar `File.writeText(json.encode(msgs))` como no Lab 5.4).
- `summarize` interno da classe está stubbed (retorna `midCount` apenas) — demonstra o gap de field mutável; uso correto é via função externa.
