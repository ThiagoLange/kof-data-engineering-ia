# Lab 3.3 — Árvore de Decisão (Gini Impurity, splits binários)

## Objetivo

Implementar um classificador de árvore de decisão estilo CART sobre
`datasets/iris.csv`: busca recursiva do melhor split binário
`(feature, threshold)` pela impureza de Gini, profundidade máxima
configurável, e previsão por travessia da árvore.

## Conceito

Uma árvore de decisão particiona o espaço de features com cortes do tipo
`x[f] <= t`. Para escolher cada corte, medimos a **impureza de Gini** de
um nó: `G = 1 - Σ p_c²`, onde `p_c` é a fração da classe `c`. Gini = 0
significa nó puro (uma classe só); Gini máximo é `1 - 1/k` (classes
equilibradas).

O melhor split é o que minimiza a **Gini ponderada dos filhos**:

```
G_split = (n_left/n) * G_left + (n_right/n) * G_right
```

O algoritmo para quando: atinge `maxDepth`, o nó já é puro, não existe
split possível (todas as features constantes no subconjunto), ou o
melhor split não melhora a impureza do pai (`G_split >= G_pai`) — nesse
caso o nó vira folha prevendo a **classe majoritária** (empates resolvem
para o menor índice de classe, determinístico).

Thresholds são pontos médios entre pares de valores distintos
(`(v_i + v_j) / 2`) — sem necessidade de ordenação.

### ⚠️ Overfitting (treino == teste)

Este laboratório é didático: avaliamos a acurácia **no próprio conjunto
de treino** (15 linhas). Uma árvore sem poda consegue memorizar o
treino — acurácia 1.0 aqui mede *fit*, não *generalização*. Em produção,
árvores são avaliadas com hold-out / k-fold cross-validation e podadas
(`min_samples_split`, `ccp_alpha`). O `maxDepth` configurável é a forma
mais simples de regularização: note que o stump de profundidade 1 já
atinge ~0.67 só isolando as setosas.

## Diagrama

```
subset (todos os índices), depth=0
        |
        v
  G_pai = gini(subset)
        |
        v
  para cada feature f, para cada par (i,j):
     thr = (x_i[f] + x_j[f]) / 2
     G = gini(<=thr) * n1/n + gini(>thr) * n2/n
        |
        v
  melhor (f*, thr*) com G < G_pai e depth < maxDepth?
     | sim                | não
     v                    v
  partitiona em        folha: classe
  left/right           majoritária
     |                    |
     v                    |
  buildNode(left,        |
   depth+1)              |
     |                   |
     v                   |
  buildNode(right,      |
   depth+1)  ───────────┘
     |
     v
  nó interno (f*, thr*, leftId, rightId)
  -- filhos são gravados ANTES do pai (ids conhecidos)
```

## Dataset

`datasets/iris.csv` — 15 flores (5 de cada espécie: setosa, versicolor,
virginica) com as 4 features numéricas. O subconjunto é pequeno e
linearmente separável por níveis, ideal para inspeção manual da árvore
(resultado típico: 5 nós, acurácia 1.0 no treino).

## Comandos

```bash
# da raiz do repo
kof run modulo-03-ml/03-decision-tree/lab.kof
kof test modulo-03-ml/03-decision-tree/exercise.kof
```

## Padrões & Idiomática Kof

- **Árvore em arrays paralelos** (`feat/thresh/left/right/pred`): evita
  tipos recursivos (`record Node` contendo `Node`), que não são
  suportados pelo parser 0.1.3-beta. Filhos são registrados **antes** do
  pai, então os ids já existem quando a linha do pai é escrita.
- **Subconjuntos como `List<Int>` de índices**: nunca copiamos linhas de
  `X`; partições carregam só índices (O(k) por nó).
- **`record Tree(...)`** agrupa os arrays + `classNames` — valor imutável
  com igualdade por conteúdo.
- **`throw` para dataset inválido** (vazio, desalinhado, `maxDepth < 0`).
- **Conversão Int→Double via `1.0 * n`** (COMP002 — ver Gaps).

## Gaps & Limitações

- **Sem tipos recursivos**: um nó não pode referenciar `Node left/right`
  diretamente; o padrão arrays-paralelos com ids resolve isso de forma
  idiomática para backend JVM.
- **COMP002 (variante nova)**: `Int.toDouble()` isolado (inicialização,
  reassignment ou `return` direto) gera `ClassFormatError` ou frame
  crash — **mitigação:** `1.0 * n`.
- Sem `sort` na stdlib: busca exaustiva de thresholds por pares (O(f·n²)
  candidatos) — aceitável para o dataset didático; em produção, ordenar
  primeiro reduz a O(f·n).
- Sem higher-order: contagens por classe são loops `while` com
  `counts.set(idx, counts.get(idx) + 1)` (List.set funciona no JVM).
- Avaliação no treino por design do lab; ver seção **Overfitting**.
