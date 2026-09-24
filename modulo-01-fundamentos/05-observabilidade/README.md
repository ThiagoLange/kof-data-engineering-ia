# Lab 1.5 — Observabilidade e Validação (kof.log)

## Objetivo

Demonstrar `kof.log` (estruturado, níveis `info`/`error`, `requestId`/`correlationId`) e validação manual que em versões futuras será `kof.validation` (13 predicados, `VAL001`).

## Conceito

- **Log estruturado**: `log.info`/`log.error` emitem JSON no JVM (`2026-... INFO msg`) e funcionam nos 3 targets (`LOG001` fechado). `requestId` é automático.
- **Validação**: hoje manual (`required`, `isEmail` via `indexOf("@")`); futuro `validation.required`/`isEmail` gerarão `VAL001` em compile-time.
- **Portabilidade**: `kof build --target native|js` — `log` funciona em ambos, mas `spawn`/`kof.db` ainda gateiam `CONC001`/`DB001`.

## Comandos

```bash
kof run modulo-01-fundamentos/05-observabilidade/lab.kof
kof test modulo-01-fundamentos/05-observabilidade/exercise/exercise.kof
kof build --target native modulo-01-fundamentos/05-observabilidade/lab.kof  # deve compilar (log não gateia)
kof build --target js modulo-01-fundamentos/05-observabilidade/lab.kof
```

## Padrões

- `log.info`/`log.error` em vez de `println` para eventos com nível.
- Validação retorna `String` vazia = ok, senão mensagem — evita `throw` para erros esperados de input (diferente de `throw` para bugs).
- Formato legível (compact era workaround 0.3.2 `LineNumberTable`, corrigido em 0.3.22+).

## Gaps

- `kof.config` (file>env>profile) ainda sem API estável em 0.4.10 (`config.get` → `SEM025`, verificado); por isso não usado neste lab.
- `kof.validation` predicates estarão disponíveis como anotações `valid` em 0.4+; por enquanto manual.
