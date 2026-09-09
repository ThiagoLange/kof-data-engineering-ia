# Lab 3.5 — Hold-out e K-Fold Cross-Validation (Generalização)

## Objetivo

Demonstrar que avaliar no treino engana: implementar `holdout(ratio=0.7)` e `kFoldSplits(k=3)` sobre `iris.csv`/`iris_full.csv`, comparar `accuracy` no teste vs. treino e baseline de maioria, usando métricas de `03-04`.

## Conceito

- **Hold-out**: primeiros 70% para treino, 30% para teste (determinístico, sem shuffle para simplicidade).
- **K-Fold**: particiona em `k` folds round-robin, cada fold é teste uma vez; `mean accuracy` estima generalização real.
- **Handcrafted tree**: `pl<2.5 → setosa, <5.0 → versicolor, else virginica` — proxy do tree aprendido em `03-03`; `accuracyTree` mede no hold-out.

No `iris.csv` pequeno (15), hold-out `11/4` ainda dá `1.0` (dataset separável), mas em `iris_full.csv` (150) a média `0.978` mostra a realidade.

## Diagrama

```
iris.csv (15) ─► holdout(0.7) ─► train 11 / test 4 ─► majority → 0.0 / tree → 1.0
     │
     └─► kFoldSplits(3) ─► 3× (train 10, test 5) ─► acc 1.0,1.0,1.0 → mean 1.0
iris_full.csv (150) ─► holdout(0.7) ─► train 105 / test 45 ─► tree 0.978
```

## Comandos

```bash
kof run modulo-03-ml/05-validacao/lab.kof
kof test modulo-03-ml/05-validacao/exercise.kof
```

## Padrões

- Funções puras de split (`Split` record), sem `shuffle` (reprodutível).
- Reusa `03-04` métricas via `accuracy` manual (evita `Confusion` genérico).
- Compact format para 0.3.2.
