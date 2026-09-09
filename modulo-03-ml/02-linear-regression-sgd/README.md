# Lab 3.2 — Regressão Linear com Gradiente Descendente (SGD manual)

## Objetivo

Treinar do zero — sem biblioteca de otimização — uma regressão linear
`price = w * sqft + b` sobre `datasets/houses.tsv`, implementando MSE,
derivadas parciais, loop de épocas e learning rate à mão, com a perda
impressa a cada N épocas para observar a convergência.

## Conceito

Regressão linear assume que o alvo é uma combinação linear das features.
Com uma única feature, o modelo é uma reta; treinar é encontrar `w`
(inclinação) e `b` (intercepto) que minimizam o **erro quadrático médio
(MSE)**:

```
MSE(w, b) = (1/n) * Σ (ŷ_i - y_i)²        ŷ_i = w * x_i + b
dMSE/dw   = (2/n) * Σ (ŷ_i - y_i) * x_i
dMSE/db   = (2/n) * Σ (ŷ_i - y_i)
```

O **gradiente descendente** atualiza os parâmetros na direção oposta ao
gradiente: `θ ← θ - lr * ∂MSE/∂θ`. O **learning rate** `lr` controla o
passo: grande demais diverge, pequeno demais demora. Aqui usamos
*full-batch* (o gradiente soma todos os exemplos por época) — com 10
linhas, batch == dataset; o loop por exemplo (SGD puro) é o mesmo
código com o acumulador zerado a cada iteração.

Feature scaling (Lab 3.1) é o que torna `lr = 0.1` estável: como `sqft`
foi z-score normalizado, todas as features têm variância ~1 e o Hessiano
fica bem condicionado.

Note a perda residual (~2.4e8): `price` não é função só de `sqft`
(`beds`, `baths`, `age` também importam), então a reta tem erro
irredutível — ótimo gancho para falar de *underfitting* e de regressão
multivariada.

## Diagrama

```
houses.tsv: sqft | price
    |                |
    v                v
 zscore(sqft)      ys (brutos)
    |                |
    +-------+--------+
            v
    epoch = 0..500
            |
            v
    gradW = (2/n) Σ err*x        err = (w*x + b) - y
    gradB = (2/n) Σ err
            |
            v
    w -= lr*gradW ;  b -= lr*gradB
            |
            v
    a cada 100 épocas: println(MSE)
            |
            v
    LinReg(w, b) -> predict(1500 sqft) ~= 238k
```

## Dataset

`datasets/houses.tsv` — 10 casas (TSV): `sqft beds baths age price`.
Usamos `sqft` (feature, normalizada) e `price` (alvo, em dólares). Os
valores seguem quase uma reta, mas com ruído estrutural das demais
features.

## Comandos

```bash
# da raiz do repo
kof run modulo-03-ml/02-linear-regression-sgd/lab.kof
kof test modulo-03-ml/02-linear-regression-sgd/exercise.kof
```

## Padrões & Idiomática Kof

- **Acumuladores `Double` locais** (`gradW`, `gradB`) com RHS puramente
  Double dentro de `while` — padrão obrigatório para evitar COMP002 no
  backend JVM (ver `docs/LIMITACOES-KOF-0.1.3.md`).
- **Conversão Int→Double com `1.0 * n`**, nunca `n.toDouble()` isolado
  (emite `ClassFormatError`/COMP002 — ver Gaps abaixo e Lab 3.1).
- **`record LinReg(w, b)`** como "pesos do modelo" — valor imutável,
  igualdade por conteúdo no JVM.
- **Teste sem ruído**: `exercise.kof` usa `trainQuiet` (mesma matemática
  do lab, sem logs) para manter a saída do `kof test` legível.

## Gaps & Limitações

- **COMP002 (variante nova)**: `Int.toDouble()` como expressão isolada
  (`var m = n.toDouble()`, `m = n.toDouble()`, `return n.toDouble()`)
  gera `ClassFormatError: Illegal class name ""` ou frame crash
  (`Index -1 out of bounds`). **Mitigação:** `1.0 * n` — sempre válido.
- **COMP002 (conhecido)**: atribuição de Double com RHS misto Int/Double
  dentro de `if` em loop — **Mitigação:** RHS puramente Double
  (`acc + err * x`, nunca `acc + (i).toDouble()`).
- Sem higher-order (`map`/`reduce`): o gradiente é um `while` explícito.
- Sem `math.sqrt`/`abs` na stdlib: Newton inline (`shared/math.kof`).
- O lab é full-batch; SGD por-minibatch fica como exercício avançado
  (mesma estrutura, zerando o acumulador a cada exemplo).
