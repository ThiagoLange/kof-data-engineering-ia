# Lab 1.1 — Parser e Leitura Streamed de CSV/TSV

location: modulo-01-fundamentos/01-parser-csv-streamed
state: done
instructions:
  - test

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
  `Option<T>` ser implementado. Ver `docs/LIMITACOES-KOF.md`.
- **Loops explícitos** no lugar de `map`/`filter` — escolha didática; a 0.8.1 já tem `map`/`filter` nativos (desde 0.2.0), e os loops mantêm o parsing visível.
- **`record Record(...)`** para linhas tipadas; records têm igualdade por
  conteúdo no JVM (ver `training/language/types.md`).

## Gaps & Limitações

- Streams reais (`Reader.readLine()`) não existem na stdlib da 0.8.1 —
  lemos o arquivo inteiro e iteramos por linhas. Para >100 MB, prefira
  Lab 1.4 (I/O binário).
- `String.split` existe na 0.8.1, mas retorna `array` e usa separador literal; o lab mantém `splitManual` retornando `List<String>` por didática (helpers inline; canônico em `shared/strutils.kof`).
- Retorno anulável é suportado desde 0.4.4 (`readText(): String?`); estreite sempre com `if (x == null)` antes de usar — ver `docs/LIMITACOES-KOF.md`.