# Lab 4.2 — Grafo Computacional e Diferenciação Automática (Autograd)

## Objetivo

Implementar diferenciação automática reverse-mode sobre nós escalares `Value` (similar ao micrograd): cada operação (`add`/`mul`/`relu`/`sigmoid`) cria um nó com `prev` e `op`; `backward(loss, 1.0)` propaga gradientes pela regra da cadeia, verificado via gradiente numérico por diferença central.

## Conceito

Autograd decompõe uma expressão como DAG: `loss = (a·b + c)²`. Forward computa `data`; backward distribui `grad`:

- `add`: `∂L/∂a += ∂L/∂c`, `∂L/∂b += ∂L/∂c`.
- `mul`: `∂L/∂a += b·∂L/∂c`, `∂L/∂b += a·∂L/∂c`.
- `relu`: `∂L/∂a += (data>0 ? ∂L/∂c : 0)`.
- `sigmoid`: `σ'=σ·(1-σ)` → `∂L/∂a += σ·(1-σ)·∂L/∂c`.

Gradientes são `List<Double>` boxes porque fields de `class` são `final` no beta (mutação via `set`, igual ao `FakeLLM.calls` do Lab 6.2).

Correção checada contra `numericalGrad` `(f(x+ε)-f(x-ε))/2ε`.

## Diagrama

```
  a ─┐
     ├─► mul(ab) ─┐
  b ─┘            ├─► add(d) ──► mul(loss = d·d)
  c ──────────────┘
                    backward(loss,1.0)
                          │
        assign grads ─► mul distributes 2d
                          │
                 add distributes to ab,c
                          │
            mul distributes b·grad / a·grad
```

## Dataset

Nenhum dataset — demonstração é self-contained com valores `a=2,b=3,c=10`. Verificação numérica usa reconstrução do grafo com `±eps`.

## Comandos

```bash
kof run modulo-04-deep/02-autograd/lab.kof
kof test modulo-04-deep/02-autograd/exercise.kof
```

## Padrões & Idiomática Kof

- **`List<Double>` como box mutável** para `grad` (field `final` não reatribuível; `set(0,nxt)` é idiom).
- **`record`-less DAG**: `class Value` com `List<Value> prev` evita tipos recursivos (mesmo workaround do decision-tree).
- **`throw` em `op` desconhecida** — erro de programação.
- **Sem `visited` set**: `zeroGradTree` recursiva sem deduplicação (grafo é tree-like no demo; DAG loss com `d*d` duplica traversal mas acumula correto via `+=`).

## Gaps & Limitações

- Escalar apenas (sem Tensor); extensão vetorial requer broadcast + sum no backward.
- Sem topo-sort iterativo com `visited` por `==` em objetos (gaps de compilador com `Value == Value` em `if` dentro de loop) — mitigação por recursão direta.
- `exp` via Taylor (30 termos) — suficiente para `|x|<5` (sigmoid); fora do range, usar `math.kof`.
