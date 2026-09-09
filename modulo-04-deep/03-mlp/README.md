# Lab 4.3 — Perceptron Multicamadas (MLP) para Classificação Não-Linear

## Objetivo

Implementar um MLP `4 → 8 (ReLU) → 3 (Softmax)` com pesos `List<Double>` row-major, `matVecMul`, `vecAdd`, ativações ReLU/Sigmoid e softmax; inferência via `predict` (argmax) e acurácia sobre `datasets/iris.csv`.

## Conceito

Duas camadas densas são suficientes para separar classes não-lineares:

```
h = ReLU(W1·x + b1)    W1: 8×4, b1: 8
logits = W2·h + b2     W2: 3×8, b2: 3
probs = softmax(logits)
pred = argmax(probs)
```

- **ReLU** introduz não-linearidade (`max(0,x)`), essencial para quebrar linearidade entre camadas.
- **Softmax** normaliza logits em probabilidades `exp(z_i - max)/Σ exp`.
- Pesos são determinísticos `((i*cols+j)*0.07 mod 1)-0.5` (pseudo-rand reprodutível).

Acurácia untrained ~0.33 (chance) é esperada — treino real requer backprop (Lab 4.2) + otimizador (Lab 4.4).

## Diagrama

```
 iris sample [4] ─► matVecMul(W1 8×4) ─► vecAdd(b1) ─► reluVec ─► hidden [8]
                                                                  │
                        logits [3] ◄─ vecAdd(b2) ◄─ matVecMul(W2 3×8)
                              │
                           softmax ─► probs [3] ─► argmax ─► label 0/1/2
```

## Dataset

- `datasets/iris.csv` — 15 amostras 4-D com 3 classes; `labelForSpecies` mapeia species→int.

## Comandos

```bash
kof run modulo-04-deep/03-mlp/lab.kof
kof test modulo-04-deep/03-mlp/exercise.kof
```

## Padrões & Idiomática Kof

- **`class MLP` com `List<Double>` matricial** — field final mutável via `List` (mesmo idiom do Tensor).
- **Funções puras `matVecMul/vecAdd/reluVec/softmaxVec`** — testáveis isoladamente.
- **`throw` em size mismatch** (matVec, argmax empty).
- **Softmax com max-subtraction** para estabilidade numérica (`exp(x-max)`).

## Gaps & Limitações

- Forward-only (treino requer autograd tensorial + backward — Lab 4.2 escalado para List<Double>).
- Inicialização determinística (sem `random` na stdlib; em produção use `kof.time` seed).
- Sem batching — um forward por amostra; vetorização futura via `Tensor.matmul`.
