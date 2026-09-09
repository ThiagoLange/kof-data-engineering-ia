# Lab 4.4 — Otimizadores e Checkpoint de Modelos

## Objetivo

Implementar Adam (Kingma & Ba 2014) manualmente sobre `List<Double>` de parâmetros e persistir/restore via checkpoint JSON — fechando o ciclo treino→salvar→recuperar.

## Conceito

Adam mantém dois momentos por parâmetro:

```
m_t = β1·m_{t-1} + (1-β1)·g_t          (momento 1º — média dos gradientes)
v_t = β2·v_{t-1} + (1-β2)·g_t²         (momento 2º — média quadrática)
mHat = m_t / (1-β1^t)                  (correção de bias)
vHat = v_t / (1-β2^t)
θ_t = θ_{t-1} - lr·mHat / (√vHat + ε)
```

- `β1=0.9, β2=0.999, ε=1e-8` (defaults do paper).
- `stepBox: List<Int>` guarda `t` mutável (field `final` workaround).
- Checkpoint: `record Checkpoint(List<Double> params, Int step)` via `json.encode/decode` + `File.writeText/readText` + `delete` no cleanup.

Loss demo: `f(x,y)=(x-5)²+(y+3)²`, grad `2·(θ-target)`, lr=0.2 por 20 steps (cai de 34→1.79).

## Diagrama

```
 List<Double> params ─┬─► gradLoss (2*(θ-target)) ─► grads
                      │                                  │
                      ▼                                  ▼
                   Adam.step(grads) ◄────────────────────┘
                      │  m = β1·m + (1-β1)g
                      │  v = β2·v + (1-β2)g²
                      │  θ -= lr·mHat/(√vHat+ε)
                      ▼
                   lossValue(θ) ─► print per step
                      │
                 saveCheckpoint(json.encode) ─► .ckpt.json ─► loadCheckpoint(json.decode) ─► verify error 0.0
```

## Dataset

Nenhum dataset — otimização sobre função sintética quadrática. Checkpoint usa filesystem local.

## Comandos

```bash
kof run modulo-04-deep/04-otimizadores/lab.kof
kof test modulo-04-deep/04-otimizadores/exercise.kof
```

## Padrões & Idiomática Kof

- **`List<Double>` para params/m/v** — vetores mutáveis via `set`; `stepBox: List<Int>` para `t` mutável.
- **`powApprox` para β^t** — sem `Math.pow` nativo; loop `t ≤20` é suficiente para demo.
- **`throw` em size mismatch** (grad vs params).
- **Checkpoint JSON tipado**: `Checkpoint` record com `List<Double>` — `json.encode/decode<Checkpoint>` é JVM-only mas funcional.

## Gaps & Limitações

- Adam escalar por parâmetro; extensão para `Tensor` requer broadcast per-element.
- `powApprox` O(t) — para t grande, acumular `β^t` iterativamente é mais eficiente.
- Sem `File.exists` check antes de `delete`; retorno booleano ignorado no demo.
- Native gap JSN002: `json.encode` de objetos não disponível — checkpoint seria binário (`writeBytes`) no Native.
