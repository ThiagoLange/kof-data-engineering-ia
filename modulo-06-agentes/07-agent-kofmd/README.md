# Lab 6.7 — Agente com Memória Operacional em kofmd

location: modulo-06-agentes/07-agent-kofmd
state: done
instructions:
  - test

location: modulo-06-agentes/07-agent-kofmd
state: done
instructions:
  - test

## Objetivo

Dar ao agente **memória operacional persistente em kofmd**: a cada passo
ele grava `last/doing/next/location/state/result` em `memory.md` (forma
canônica §11), e o próximo passo lê de volta. O planejador aqui é
determinístico (roteiro fixo de 3 tarefas) de propósito — o objeto de
estudo é a memória, não o LLM (ver Lab 6.2 para ReAct com LLM real).

## Conceito

Memória conversacional (Lab 6.4) guarda *o que foi dito*; memória
operacional kofmd guarda *onde o trabalho está*: último contexto (`last`),
intenção atual (`doing`), próxima intenção (`next`), onde se aplica
(`location`), situação (`state`) e desfecho (`result`). É o núcleo de
memória de agente da spec (§9): tokens curtos, zero narrativa, ordem
canônica — legível por humano, parseável por máquina e validável por
`kof md check`.

O loop: `memRender(...)` → `File(memory.md).writeText` → próximo passo
lê com `memGet(mem, key)` (scan de linhas `key: ` na coluna 0). Ausência
é campo omitido (§7.1): sem `next` no último passo, sem `result` antes
do fim. `memory.md` é gerado (gitignored); `examples/memory.md` é a
amostra commitada de uma memória de fim de run.

## Diagrama

```
 passo 1: doing=read_schema    ─► memory.md (state: active)
 passo 2: doing=compute_mean   ─► memory.md (last: read_schema)
 passo 3: doing=write_report   ─► memory.md (state: done, result: pass)
 próximo run: memGet(memory.md, "last") continua de onde parou
```

## Dataset

Nenhum dataset externo; as 3 tarefas e observações são roteirizadas no
`lab.kof` para determinismo total (mesmo `memory.md` final toda vez).

## Comandos

```bash
kof run modulo-06-agentes/07-agent-kofmd/lab.kof
kof test modulo-06-agentes/07-agent-kofmd/exercise/exercise.kof
kof md check modulo-06-agentes/07-agent-kofmd/examples/memory.md
cp modulo-06-agentes/07-agent-kofmd/examples/memory.md /tmp/agmem.md && kof md format /tmp/agmem.md
```

## Padrões & Idiomática Kof

- `record` não é usado para a memória: o portador é o próprio `.md`
  (texto), e o Kof só renderiza/parseia — dado é dado, prosa é prosa.

- `memGet` por scan de prefixo `key:` na coluna 0, igual ao varredor da
  spec (§4: só a coluna 0 carrega construção).

- Paths repo-root-relativos (`modulo-06-agentes/07-agent-kofmd/...`),
  mesmo padrão do lakehouse (Lab 8.1): rode sempre da raiz.

## Gaps & Limitações

- `record` declarado no `.md` não valida mismatch nesta build (ver Lab
  9.4): a memória aqui é validada pelo vocabulário (`MD002` em `@intent`
  e chaves seguem `snake_case`), não por schema.
