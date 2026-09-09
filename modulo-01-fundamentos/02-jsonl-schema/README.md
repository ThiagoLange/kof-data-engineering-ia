# Lab 1.2 — Serialização e Desserialização de Schemas JSON e JSONL

## Objetivo

Construir um pipeline que:
- lê um arquivo JSONL (`docs.jsonl`) linha a linha,
- desserializa cada linha em uma struct tipada de Kof (`record Doc`),
- valida campos obrigatórios em tempo de execução,
- escreve a versão saneada em outro arquivo JSONL.

## Conceito

JSONL (JSON Lines) é o formato padrão para logs semiestruturados, datasets
de NLP e ingestão streaming. Cada linha é um JSON independente — o parser
pode falhar em uma linha sem comprometer as demais.

Em Kof, `json.encode(record)` e `json.decode<Record>(string)` (ambos no JVM,
gaps em Native via `JSN002`) preservam tipos via generics. Para `List<T>`,
a inferência também é preservada.

Validação é feita pós-parse:
- Campos obrigatórios (ex.: `id`, `title`) não podem ser vazios.
- Tipos garantidos pelo decoder.
- Schema versionamento via campo `schema_version` (boa prática).

Erros de parsing em uma linha específica **não abortam** o pipeline — a
linha é pulada com mensagem de erro via `try/catch`. Isso segue o idiom de
`training/idioms/errors.md`: exceções carregam a falha sem parar o trabalho.

## Diagrama

```
File("datasets/docs.jsonl").readText()
        |
        v
  split("\n")  --->  para cada linha
        |                  |
        v                  v
  trim/length>0      json.decode<Doc>(line)
                            |
                       ┌────┴────┐
                       v         v
                   validate()  throws -> skip+log
                       |
                       v
                   List<Doc> filtrada
                            |
                            v
                   json.encode(d)  --->  File.writeText(out)
```

## Dataset

`datasets/docs.jsonl` — 5 documentos multilíngue (en/pt), campos `id`,
`title`, `body`, `lang`. Schema version implícito 1.

## Comandos

```bash
kof run modulo-01-fundamentos/02-jsonl-schema/lab.kof
kof test modulo-01-fundamentos/02-jsonl-schema/exercise.kof
```

## Padrões & Idiomática Kof

- **`record Doc(...)`** preserva tipos via `json.decode<Doc>`. Ver
  `training/idioms/records.md`.
- **`try/catch`** para tratar linhas malformadas sem abortar o pipeline.
- **Validação explícita pós-parse** — campos required precisam ser
  non-empty.
- **Output**: JSONL re-escrito via `File.writeText` com `"\n"` join.

## Gaps & Limitações

- `json.decode<T>` para records: JVM e JS. **Native reporta JSN002** —
  sem decoder de objetos no compilador atual.
- `List<Record>` via decoder não testado nesta versão; usamos decode por
  linha (mais robusto a falhas parciais).
- I/O ainda é full-file read; para >100MB prefira Lab 1.4.