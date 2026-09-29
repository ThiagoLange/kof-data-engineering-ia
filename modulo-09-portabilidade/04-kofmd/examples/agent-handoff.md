# Agent-handoff — decisão com memória (Apêndice C)

@decision
Particionar o lakehouse por cidade com watermark incremental.

last: streaming
doing: particionamento
next: quality
location: modulo-08-data/01-lakehouse
state: active
constraint: no-breaking-change
instructions:
  - implement
  - add-tests
reason: smaller-diff

Partição por cidade mantém cada arquivo pequeno e o watermark evita
reprocessar o lago inteiro a cada carga.
