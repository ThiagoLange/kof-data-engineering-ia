# Lab 8.3 — Streaming com kof.mq (Tumbling Window)
## Objetivo
Publicar `transactions.jsonl` em `SimpleMQ` (queue) e consumir em janelas tumbling de 3, agregando `sum(amount)` por janela com `log.info`.
## Comandos
```bash
kof run modulo-08-data/03-streaming/lab.kof
kof test modulo-08-data/03-streaming/exercise.kof
```
## Padrões
- `SimpleMQ` usa `List<String>` como queue (workaround para `kof.mq` ainda `MQ001` cross).
- `kof build --target native` só após `MQ001` fechado; por enquanto JVM.
