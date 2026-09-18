# Lab 0.1 — Kof Toolchain (Setup)

## Objetivo

Verificar que `kof 0.4.4-beta` está instalado e que todos os datasets estão acessíveis a partir da raiz do repo. Este lab deve ser o primeiro a passar; falhas aqui bloqueiam os demais.

## Conceito

O treinamento assume `kof` no `PATH` com JDK 25 embedded (virtual threads) e execução a partir da raiz (`datasets/` relativo). Ferramentas verificadas:

- `kof version` — deve reportar `0.4.4-beta`.
- `kof info` — plataforma, JVM 25 embedded, stdlib 0.4.4.
- `kof check <file|dir>` — type-check sem emitir bytecode.
- `kof inspect <file>` — estatísticas de IR antes/depois de otimização.
- `kof lsp` — Language Server (stdio).

## Diagrama

```
  kof version → kof info → kof check modulo-00-setup/01-kof-toolchain/lab.kof
       │              │                     │
       └──────────────┴─────────────────────┘
                              │
                         File.readText(datasets/*.csv|*.jsonl) → 8/8 OK
                              │
                          setup OK
```

## Dataset

Todos em `datasets/`: `employees.csv`, `iris.csv`, `iris_full.csv` (novo, 150 linhas), `houses.tsv`, `customers.jsonl`, `transactions.jsonl`, `docs.jsonl`, `classification_eval.jsonl`.

## Comandos

```bash
kof version
kof info
kof check modulo-00-setup/01-kof-toolchain/lab.kof
kof run modulo-00-setup/01-kof-toolchain/lab.kof
kof inspect modulo-00-setup/01-kof-toolchain/lab.kof
bash scripts/run-tests.sh
```

## Padrões & Idiomática Kof

- Rodar sempre da raiz para que `File("datasets/...")` resolva.
- `kof check` antes de `kof run` para diagnóstico rápido (`PARSE007` etc.).
- `kof inspect` para observar redução de ops após otimização.

## Gaps & Limitações

- `kof fmt` reescreve espaços (idempotente); não afeta semântica.
- `kof debug` (DAP) e `kof profile` são JVM-only (verificados em 0.4.4).
