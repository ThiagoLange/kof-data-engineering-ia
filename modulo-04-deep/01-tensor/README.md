# Lab 4.1 — Classe Tensor N-Dimensional e Álgebra Linear

## Objetivo

Implementar `Tensor` 2D (row-major sobre `List<Double>`) com indexação `get/set`, `transpose`, `matmul`, `add`/`addScalar`/`scale` e `reshape`, carregando `datasets/iris.csv` como `(n × 4)` Tensor para workloads reais (Gram matrix `Xᵀ·X`).

## Conceito

Tensores são a estrutura base de deep learning: generalization de matrizes. Armazenamento row-major `data[i*cols+j]` maximiza localidade. Operações:

- `transpose`: `out[j*rows+i] = data[i*cols+j]`.
- `matmul`: triplo loop `acc += a[i,k]*b[k,j]` com verificação de shape.
- `add/scale`: elementwise com broadcasting escalar.
- Mutação só via `List.set` sobre buffer final (classe field é `final` no beta).

Gram matrix `G = XᵀX` (4×4) é usada como validação: simétrica e positiva.

## Diagrama

```
iris.csv ─► loadIrisFeatures ─► Tensor(n,4)
                                 ├─► transpose ─► (4,n)
                                 ├─► matmul(transpose) ─► G (4,4) Gram
                                 ├─► matmul(identity(4)) ─► X (invariante)
                                 └─► reshape/addScalar/scale demo
```

## Dataset

- `datasets/iris.csv` — 15 linhas, 4 colunas numéricas como `Tensor(15,4)`.

## Comandos

```bash
kof run modulo-04-deep/01-tensor/lab.kof
kof test modulo-04-deep/01-tensor/exercise.kof
```

## Padrões & Idiomática Kof

- **`class Tensor` com `List<Double>` mutável**: `set` via `data.set()` é a única mutação legal (field `final`).
- **Imutáveis retornam novo Tensor**: `transpose/matmul/add` alocam `listOf<Double>()`.
- **`throw` em shape mismatch / bounds**.
- Loops `while` triplos para `matmul` (sem `forEach`).

## Gaps & Limitações

- 2D apenas (n-Dimensional requer variadic dims ainda não estável).
- Sem broadcasting real entre shapes arbitrários — apenas `addScalar`.
- Sem GPU/Native SIMD; `matmul` é O(n³) puro CPU.
- `data` exposto via `toList()` para acesso raw; encapsulamento futuro via `private`.
