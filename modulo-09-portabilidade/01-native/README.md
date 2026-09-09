# Lab 9.1 — Portabilidade Native/JS
## Objetivo
Demonstrar que `log` e `File` funcionam nos 3 targets, enquanto `spawn`/`kof.db` gateiam (`CONC001`/`DB001`).
## Comandos
```bash
kof run modulo-09-portabilidade/01-native/lab.kof
kof build --target native modulo-09-portabilidade/01-native/lab.kof  # deve falhar com CONC001 se usar spawn
kof build --target js modulo-09-portabilidade/01-native/lab.kof
```
