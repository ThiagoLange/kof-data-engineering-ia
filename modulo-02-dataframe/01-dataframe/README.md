# Lab 2.1 — Implementação de Estrutura DataFrame em Kof

## Objetivo

Construir uma estrutura `DataFrame` tipada em Kof — colunas `Series` (label + `List<Double>`), índice de linhas `List<String>` e operações de seleção, filtro booleano vetorial, `head`/`tail` e `describe` — carregando dados reais de `datasets/iris.csv`.

## Conceito

Um DataFrame é uma tabela colunar tipada: cada coluna é uma `Series` homogênea e todas as colunas compartilham o mesmo índice de linhas. As operações fundamentais são:

1. **Seleção de coluna** por nome (`col("petal_length")`) — busca linear, erro explícito se ausente.
2. **Filtro booleano vetorial**: uma máscara `List<Int>` (0/1) é produzida por comparação vetorial (`maskGt`) e aplicada a todas as colunas e ao índice via `filterMask`/`selectRows`.
3. **`describe`**: `count/mean/min/max` por coluna — estatísticas calculadas sem alocação extra além da varredura.

Em Kof 0.1.3-beta não há `List<Bool>` nem `map`/`filter` (ver `docs/LIMITACOES-KOF-0.1.3.md`), então máscaras são `List<Int>` e construídas com loops `while` explícitos. O cálculo de média evita o bug COMP002 separando acumulação e divisão em funções distintas (`SumCount` record).

## Diagrama

```
  loadTable("iris.csv")  ->  DataFrame(index, cols=[Series])
                                    |
              col("petal_length") --+--> Series
                                    |       |
                                    |   maskGt(Series, 5.0) -> List<Int> mask
                                    |       |
                                    +--> filterMask(mask) -> DataFrame filtrado
                                    |
                          head(k) / tail(k) / whereIndex("setosa")
                                    |
                                    v
                              describe(col) -> "label count=N mean=.. min=.. max=.."
```

## Dataset

`datasets/iris.csv` — 15 linhas (5 por espécie), 4 colunas numéricas + coluna categórica `species` usada como índice de linhas. Permite demonstrar filtro por índice (`whereIndex`) e filtro vetorial por valor (`maskGt`).

## Comandos

```bash
# da raiz do repo
kof run modulo-02-dataframe/01-dataframe/lab.kof
kof test modulo-02-dataframe/01-dataframe/exercise.kof
```

## Padrões & Idiomática Kof

- **`record SumCount`** para retornar dois Double como um valor; contar em Double evita `Int.toDouble()` isolado (COMP002).
- **Métodos de `Series`/`DataFrame` só acumulam e retornam direto**; divisão (`mean`) fica em função livre fora da classe (ver COMP002 em `docs/LIMITACOES-KOF-0.1.3.md`).
- **`throw` para coluna inexistente ou mask com tamanho errado** — erro de programação, não sentinel.
- **Loops `while` explícitos** no lugar de `map`/`filter`.

## Gaps & Limitações

- Sem `List<Bool>`: máscaras são `List<Int>` com 0/1.
- Sem `map`/`filter`/`reduce` nativos em 0.1.3-beta — ver `docs/LIMITACOES-KOF-0.1.3.md`.
- `Int.toDouble()` isolado gera `ClassFormatError`; mitigação `1.0 * n` não necessária aqui pois contagens são em Double.
