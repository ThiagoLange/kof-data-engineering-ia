# Lab 1.1 — Parser e Leitura Streamed de CSV/TSV

## Objetivo

Construir um parser CSV/TSV que:
- lê um arquivo linha a linha sem carregar todo o conteúdo na memória,
- faz parsing estrito de tipos (`Int`, `Double`) com tratamento explícito de
  células vazias,
- suporta tanto vírgula (CSV) quanto tab (TSV) como delimitador.

## Conceito

Em pipelines de Engenharia de Dados, datasets tabulares costumam chegar em
formato CSV (comma-separated) ou TSV (tab-separated). Os requisitos
fundamentais são:

1. **Streaming**: arquivos de 10 GB não cabem na memória; o parser precisa
   processar linha a linha.
2. **Conversão de tipos**: a coluna chega como texto; valores viram `Int` ou
   `Double` em uma representação interna tipada.
3. **Ausência ≠ zero**: célula vazia é informação, não é `0`. O parser deve
   sinalizar (via `parseIntSafe`/`parseFloatSafe` com fallback explícito) ou
   falhar (`parseIntStrict` com `throw`).

Em Kof, a stdlib `kof.io` provê `File.readText()`/`writeText()`, mas não
streams. Por isso implementamos streaming em chunks de tamanho fixo lendo o
arquivo inteiro e iterando por `\n` — equivalente em uso a um line-iterator,
e ainda O(n) com pegada de memória O(chunk). Para datasets verdadeiramente
gigantes, ver Lab 4 sobre I/O binário.

O parser é estrito: linha malformada (número errado de colunas, tipo
inválido) **lança `throw`**. Isso segue o idiom de `training/idioms/errors.md`:
exceções carregam o erro no mecanismo da linguagem, não em sentinelas.

## Diagrama

```
   File.readText(path)
         |
         v
   split("\n") ----------+
         |               |
         v               |
   for each line         |
         |               |
         v               |
   split(delim)  ---> header (first line)
         |
         v
   for each row:
      cells[i] -> parseIntSafe / parseFloatSafe
         |
         v
   Record(id, age, salary, ...)
```

## Dataset

`datasets/employees.csv` — 6 linhas com valores faltantes propositais
(`age`, `name`, `salary`) para validar o caminho de ausência.

## Comandos

```bash
# da raiz do repo
kof run modulo-01-fundamentos/01-parser-csv-streamed/lab.kof
kof test modulo-01-fundamentos/01-parser-csv-streamed/exercise.kof
```

## Padrões & Idiomática Kof

- **`throw` em vez de sentinelas** para erros de programação (CSV malformado).
  Ver `training/idioms/errors.md`.
- **`parseIntSafe`/`parseFloatSafe` com fallback explícito** para campos
  opcionais — workaround marcado, não idiomatic, mas necessário até
  `Option<T>` ser implementado. Ver `docs/LIMITACOES-KOF-0.1.3.md`.
- **Loops explícitos** no lugar de `map`/`filter` (gaps em 0.1.3-beta).
- **`record Record(...)`** para linhas tipadas; records têm igualdade por
  conteúdo no JVM (ver `training/language/types.md`).

## Gaps & Limitações

- Streams reais (`Reader.readLine()`) não existem na stdlib 0.1.3-beta —
  lemos o arquivo inteiro e iteramos por linhas. Para >100 MB, prefira
  Lab 1.4 (I/O binário).
- `String.split` não existe; implementado manualmente em `splitManual`
  (helpers inline; canônico em `shared/strutils.kof`).
- Nullable types em retorno de função não suportados — ver
  `docs/LIMITACOES-KOF-0.1.3.md`.