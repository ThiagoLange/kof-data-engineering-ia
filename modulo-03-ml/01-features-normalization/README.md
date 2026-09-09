# Lab 3.1 — Normalização e Engenharia de Features

## Objetivo

Implementar em Kof, como funções puras sobre `List<Double>`, as duas
técnicas de escala mais usadas em ML (Z-score standardization e MinMax
scaling) mais One-Hot Encoding manual de uma coluna categórica — o
pré-processamento mínimo exigido antes de treinar qualquer modelo nos
labs 3.2 e 3.3.

## Conceito

Modelos baseados em gradiente (regressão, redes neurais) são sensíveis à
escala das features: se `sqft` varia em milhares e `beds` em unidades, o
gradiente dominado pela primeira torna o aprendizado instável. Duas
correções clássicas:

1. **Z-score (standardization)**: `z = (x - mu) / sigma`. Produz coluna com
   média 0 e desvio padrão 1. Preserva outliers e é a escolha padrão para
   gradiente descendente.
2. **MinMax (rescaling)**: `m = (x - min) / (max - min)`. Produz coluna em
   `[0, 1]`. Útil quando a faixa importa (ex.: ativações sigmoid) ou quando
   distâncias euclidianas são usadas (k-NN, k-means).

Colunas categóricas (strings) não têm ordem numérica; atribuir inteiros
0,1,2 às espécies do iris imporia uma ordenação falsa. **One-Hot
Encoding** cria uma coluna binária por categoria, com exatamente um `1.0`
por linha.

Em Kof 0.1.3-beta não há `List.map` nem biblioteca de estatística, então
tudo é loop `while` explícito sobre `List<Double>` — o que, didaticamente,
deixa a matemática visível.

## Diagrama

```
houses.tsv (TSV)                    iris.csv (CSV)
sqft beds baths age price           sepal_... species
   |      |                            |
   v      v                            v
col(j)  col(j)                    loadStringColumn(4)
   |      |                            |
   v      v                            v
mean/stddev (helpers)            uniqueCategories()
   |      |                            |
   v      v                            v
zscore()  minmax()                 oneHot()
   |      |                            |
   v      v                            v
mean~0    min=0                   matriz 15 x 3
std~1     max=1                   (1 ativo por linha)
```

## Dataset

- `datasets/houses.tsv` — 10 casas; as 4 features numéricas (`sqft`,
  `beds`, `baths`, `age`) são escaladas, e `price` (regressão, lab 3.2)
  aparece aqui só para demonstrar MinMax.
- `datasets/iris.csv` — 15 flores; a coluna `species` (setosa /
  versicolor / virginica) alimenta o One-Hot.

## Comandos

```bash
# da raiz do repo
kof run modulo-03-ml/01-features-normalization/lab.kof
kof test modulo-03-ml/01-features-normalization/exercise.kof
```

## Padrões & Idiomática Kof

- **Funções puras sobre `List<Double>`**: `zscore`/`minmax`/`oneHot` não
  fazem I/O; apenas `loadColumn`/`loadStringColumn` tocam `File`. O
  `main` é o único ponto de efeito.
- **`throw` para colunas inválidas** (vazia, variância zero) — erro de
  dados é exceção, não sentinel (`training/idioms/errors.md`).
- **Loops `while` explícitos** no lugar de `map`/`filter` (gap 0.1.3-beta).
- **Conversão Int→Double via `1.0 * n`**: `n.toDouble()` como statement
  isolado gera bytecode inválido no backend JVM (ver Gaps).

## Gaps & Limitações

- `sqrt` usa método de Newton (stdlib 0.1.3-beta não tem `math.sqrt`).
  O canônico `shared/math.kof` usa 10 iterações com `g0 = x`, o que deixa
  ~1.6% de erro para variâncias ~1e5 — aqui usamos 40 iterações para
  precisão de double (semântica idêntica, precisão corrigida).
- Sem `List.map`/higher-order: `oneHot` aninha dois `while` em vez de
  `labels.map { ... }`.
- `String.split` ausente: parser manual inline (`// Source:
  shared/strutils.kof`).
- **COMP002 (variante nova)**: `var m = n.toDouble()` — `.toDouble()` de
  `Int` como expressão isolada (inicialização, reassignment ou `return`
  direto) — emite classe com nome ilegal (`ClassFormatError`) ou frame
  crash. **Mitigação:** converter com `1.0 * n`.
