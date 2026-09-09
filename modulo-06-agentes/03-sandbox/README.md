# Lab 6.3 — Execução Segura e Sandboxing de Ferramentas

## Objetivo

Implementar um dispatcher sandbox que valida argumentos tipados, impõe timeout cooperativo e executa ferramentas locais (`calculator`, `get_customer`, `fetch_doc`, `slow_tool`) retornando `Result(ok, output, error)` — sem `throw` escapar para o agente.

## Conceito

O agente nunca chama tools diretamente; todo `Call(tool, argsJson)` passa por `dispatch(call, timeoutMs)` que:

1. **Valida tool**: desconhecida → `Result(0,"", "unknown tool")`.
2. **Valida timeout**: `slow_tool` com `timeoutMs<200` → `Result(0,"","timeout after ...")` (cooperativo — Kof não tem interrupção de thread real em 0.1.3).
3. **Executa em `try/catch`**: cada tool parseia JSON via `extractJsonNumber/jsonFieldString` (robusto a espaços), valida tipos e lança `String` em erro; `dispatch` captura e retorna `Result` falho.
4. **Ferramentas**:
   - `calculator`: `a op b` com `op ∈ +,-,*,/` e divisão por zero validada.
   - `get_customer`: filtra `customers.jsonl` por `city`.
   - `fetch_doc`: busca `docs.jsonl` por `id`.
   - `slow_tool`: `time.sleep(200)` para testar timeout.

## Diagrama

```
 Agent Call(tool, argsJson) ─► dispatch(call, timeoutMs)
                                  ├─ unknown tool? ─► Result(ERR unknown)
                                  ├─ slow_tool && timeout<200? ─► Result(ERR timeout)
                                  └─ try {
                                       calculator / get_customer / fetch_doc
                                     } catch(String e) → Result(ERR e)
                                     else → Result(OK output)
```

## Dataset

- `datasets/customers.jsonl` (5 linhas) e `datasets/docs.jsonl` (5 linhas) — consultados diretamente por `get_customer`/`fetch_doc`.

## Comandos

```bash
kof run modulo-06-agentes/03-sandbox/lab.kof
kof test modulo-06-agentes/03-sandbox/exercise.kof
```

## Padrões & Idiomática Kof

- **`record Call/Result` + `dispatch` puro**: Resultado explícito, sem `Option/Result<T>` na linguagem.
- **`throw` dentro da tool, `catch` no dispatcher** — barreira de segurança que converte exceção em dado.
- **`jsonFieldString/extractJsonNumber` com `indexOf` + skip de espaços/colons** — tolerante a `{"a": 12.0}` vs `{"a":12.0}`.
- **`time.sleep` para simular trabalho lento** — cooperativo, não preemptivo.

## Gaps & Limitações

- Sem `spawn` com timeout real (cancel via `selectAny` é 0.2.0+; ainda não testado com exceções). Timeout cooperativo é o idiom atual.
- Sem `Map<String, Tool>` registry — `dispatch` usa `if` encadeado; para N tools, vetor de handlers + linear scan é equivalente.
- `json.decode` dentro das tools decodifica `Customer`/`DocEntry` linha a linha (flat records) — aninhados ainda requerem scan manual (gap JSN00x).
