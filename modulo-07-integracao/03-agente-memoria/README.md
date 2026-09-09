# Lab 7.3 — Agente com Memória (ReAct + Sandbox + Conversation)

## Objetivo

Integrar `06-02` (ReAct), `06-03` (dispatcher sandbox) e `06-04` (Conversation com sumarização) — agente que mantém histórico, chama tools com validação e resume quando o contexto estoura (`maxTokens`).

## Conceito

`Conversation` conta tokens (`wordSplit`), `needs()` detecta estouro, `summarize` mantém `system` + `keepLast=2`. O loop ReAct alimenta `Conversation` com `user → assistant (Thought/Action) → system (Observation)`, chamando `summarize` a cada iteração se necessário.

Demo com 2 cenários: (1) `12*8` em 1 tool call sem sumarização, (2) `2*3 → *4` em 2 calls com `maxTokens=25` forçando 1 sumarização.

## Diagrama

```
question ─► Conversation.add(user)
               │
           while not Final Answer:
               ├─ needs()? → summarize(keepLast=2)
               ├─ ctx → FakeLLM.next() → "Thought/Action"
               ├─ parseAction → dispatch → Result
               └─ Conversation.add(system, "Observation: ...")
               │
           Final Answer → AgentState(answer, steps, summarized)
```

## Comandos

```bash
kof run modulo-07-integracao/03-agente-memoria/lab.kof
kof test modulo-07-integracao/03-agente-memoria/exercise.kof
```

## Padrões

- `Conversation` como objeto mutável (`List<ChatMessage>`), `summarize` retorna novo objeto (contorna `final field`).
- Dispatcher com `Result(ok,output,error)` — nunca `throw` escapa para o loop.
- Compact format para 0.3.2.
