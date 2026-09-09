# Lab 1.3 — Pipeline de Transformação Concorrente / Paralela

## Objetivo

Demonstrar como paralelizar uma transformação CPU-bound em Kof usando o
modelo `spawn`/`await`. O pipeline:
- divide um dataset em N partições,
- processa cada partição numa task leve,
- agrega resultados.

## Conceito

Kof expõe concorrência via duas formas:

1. **`spawn <expr>` (stmt)** — fire-and-forget, a task roda em background e
   o programa segue. O runtime faz join implícito antes de sair.
2. **`val r = spawn <expr>` + `await r`** — handle tipado `Handle<T>`;
   `await` bloqueia até o valor chegar. Suporta múltiplos awaits no mesmo
   handle (memoizado).

Ambas rodam em **virtual threads (JDK 21+)** no JVM. No Native a construção
falha em compile-time com `CONC001`; no JS reporta `CONC003`
(execução sequencial). Isso é explícito, nunca silencioso.

A regra prática é: **`spawn` quando o resultado é descartável** (logging,
notificações); **`val r = spawn` + `await`** quando o resultado importa.

## Diagrama

```
   data: List<T>  ─┐
                   │ partition(N)
                   ▼
   ┌── chunk[0] ──► spawn task(0) ──► Handle<R0>
   ├── chunk[1] ──► spawn task(1) ──► Handle<R1>
   ├── chunk[2] ──► spawn task(2) ──► Handle<R2>
   └── chunk[3] ──► spawn task(3) ──► Handle<R3>
                   │
                   ▼ (await each handle)
               aggregate(R0, R1, R2, R3)
                   │
                   ▼
                final result
```

## Dataset

`datasets/iris.csv` — 15 linhas (5 por classe). Pequeno o suficiente para
execução rápida mas com volume para mostrar particionamento.

## Comandos

```bash
kof run modulo-01-fundamentos/03-pipeline-paralelo/lab.kof
kof test modulo-01-fundamentos/03-pipeline-paralelo/exercise.kof
```

## Padrões & Idiomática Kof

- **`val r = spawn f()`** + **`await r`** é o idiom para paralelismo
  CPU-bound que precisa agregar resultados. Ver
  `learn/18-concurrency.md`.
- **Função `task` deve ser pura** (sem side-effects globais) — facilita
  testar e mantém correção sob paralelismo.
- **Aggregate simples**: soma/concat dos resultados parciais.
- **Join implícito**: o runtime espera todas as tasks antes do `main`
  retornar, mesmo em `spawn stmt`.

## Gaps & Limitações

- **Native: CONC001** — `spawn`/`await` não compilam; apenas target JVM.
- **JS: CONC003** — `spawn` compila mas é sequencial (single-thread).
- **Kof 0.1.3-beta `spawn f(var)`** — `VerifyError` se o argumento for variável; por isso o lab usa `sumIrisA/B/C/D()` zero-arg wrappers com path literal interno (`docs/LIMITACOES-KOF-0.1.3.md#2.5`).
- **`await` memoizado** — duas chamadas no mesmo handle devolvem o mesmo valor; exceções na task chegam no `await` com a mensagem original (`learn/18-concurrency.md`).
- **Dataset ampliado:** `datasets/iris_full.csv` (150 linhas, 50/classe, ruído gaussiano) permite demonstrar speed-up real do paralelismo vs. `iris.csv` (15 linhas).