# Lab 6.5 — MCP-like Tool Server (kof.web)

location: modulo-06-agentes/05-mcp-server
state: done
instructions:
  - test

## Objetivo
Registrar tools (`calculator`, `get_customer`, `fetch_doc`) em `ToolServer` (simula `kof.web` `app.get("/tools")`) e chamar via `call(name, argsJson)` com `log.info`.
## Comandos
```bash
kof run modulo-06-agentes/05-mcp-server/lab.kof
kof test modulo-06-agentes/05-mcp-server/exercise.kof
```
