# Lab 9.4 — Documentos Tipados com kofmd

location: modulo-09-portabilidade/04-kofmd
state: done
instructions:
  - test

location: modulo-09-portabilidade/04-kofmd
state: done
instructions:
  - test

## Objetivo

Ler, validar e canonizar documentos **kofmd** (Markdown tipado da 0.5.0):
inferir escalares (`Bool`/`Int`/`Float`/`String`, §7.1 da spec), emitir
blocos na forma canônica (§11) e usar `kof md check`/`kof md format` sobre o
corpus de `examples/` (inclui um `MD002` proposital).

## Conceito

kofmd = Markdown para humanos + tipos Kof para dados + intenção explícita.
Quatro construções (§6): campo tipado (`key: value`), lista, intenção de
bloco (`@decision`, 14 reservadas no Apêndice A) e schema (`record`, a
sintaxe real do Kof). Markdown puro continua válido com zero construções —
por isso `kof md check` passa em qualquer `.md` comum e só acusa `MDxxx`
quando o vocabulário reservado é violado.

Este lab implementa em Kof as duas operações que o CLI faz por fora:

1. **`inferScalar(raw): String`** — a tabela §7.1: `true`/`false` → `Bool`,
   `-?[0-9]+` em 32 bits → `Int` (estouro vira `String`), decimal/expoente
   → `Float`, `"…"` → `String` explícito, resto → `String` puro. Sem
   literal `null`: ausência é campo omitido.
2. **`canonBlock(keys, vals): String`** — a forma canônica §11:
   `last/doing/next/location/state` primeiro (nessa ordem), resto em ordem
   crescente de bytes, um espaço após `:`, sem duplicadas.

## Diagrama

```
 "retries: 3" ─► inferScalar ─► "Int"
 "ratio: 0.5" ─► inferScalar ─► "Float"
 bloco fora de ordem ─► canonBlock ─► last/doing/…/state + resto A→Z
 examples/*.md ─► kof md check (MD002 só no intent-bad, proposital)
               ─► kof md format (idempotente, reescreve canônico)
```

## Dataset

Nenhum dataset; o corpus é `examples/` (um arquivo por ideia, como o
§19 da spec manda): `basic`, `typed-data`, `agent-memory`,
`agent-handoff` e `intent-bad` (este último falha no `check` de propósito).

## Comandos

```bash
kof run modulo-09-portabilidade/04-kofmd/lab.kof
kof test modulo-09-portabilidade/04-kofmd/exercise/exercise.kof
kof md check modulo-09-portabilidade/04-kofmd/examples/basic.md
kof md check modulo-09-portabilidade/04-kofmd/examples/intent-bad.md  # MD002 proposital (exit 1)
cp modulo-09-portabilidade/04-kofmd/examples/agent-memory.md /tmp/mem.md && kof md format /tmp/mem.md
```

## Padrões & Idiomática Kof

- Comparação de `Char` por código numérico (`48`–`57`, `45` = `-`), mesmo
  idioma de `timeSeed` (snake-ai): sem literais de char na 0.5.0.

- `cmpStr` por códigos em vez de `<` em `String`: ordenação byte a byte
  explícita e auditável, como pede a forma canônica.

- Overflow de `Int` (32 bits) comparado como string contra `2147483647`:
  nada de parse-then-catch; dado inválido degrada para `String` (§7.1).

## Gaps & Limitações

- `record` declarado no `.md` **não** valida mismatch nesta build
  (testado com/sem aspas, mesmo bloco/separado): a spec §8 manda `MD002`,
  o CLI 0.5.0-beta não acusa. Documentado como gap; o `MD002` deste lab é
  demonstrado via `@intent` fora do vocabulário (funciona, com linha).

- `kof md convert` é não-meta (§21) e é recusado honestamente.
