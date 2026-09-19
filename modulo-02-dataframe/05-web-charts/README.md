# Lab 2.5 — Gráficos para a Web (SVG + Canvas KofJS)

## Objetivo
Gerar dashboard HTML com 2 SVGs server-side (`scatter`/`bars`) + `<canvas>` client-side (KofJS), servível via `kof serve` ou `kof.web` (`web.app()` em JVM). Demonstra `One frontend: Kof IR → JVM/Native/KofJS`.

## Conceito
- **Server-side:** `scatterSvg`/`barSvg` (mesma math de `02-03`) → `File.writeText` `dashboard.html` com SVGs inline + `jsData` para Canvas. Estático, funciona nos 3 targets.
- **Client-side (KofJS):** `<canvas id="chart">` + JS `getContext("2d")` `fillRect`/`fillText` (`UI009` Canvas fechado em 0.3.2, mantido em 0.4.7; `UI003` Table/Ul/Ol já OK). Em Kof, `kof.ui.Canvas` gera o mesmo JS via `KofJS` engine.
- **Servir:** `kof run` gera `dashboard.html` + `scatter.svg`/`bars.svg`; `kof serve modulo-02-dataframe/05-web-charts --port 8080` ou `kof build --target js --output dist && kof serve dist`.

## Diagrama

```
iris.csv ─► scatterSvg ─┐
                         ├─► dashboardHtml ─► dashboard.html (SVG inline + Canvas JS)
customers+tx ─► barSvg ─┘                │
                                          ├─► File.writeText
                                          └─► kof serve . (static) / kof.web app.get("/scatter.svg")
```

## Comandos

```bash
kof run modulo-02-dataframe/05-web-charts/lab.kof
xdg-open modulo-02-dataframe/05-web-charts/dashboard.html
kof serve modulo-02-dataframe/05-web-charts --port 8080
kof build --target js modulo-02-dataframe/05-web-charts --output dist && kof serve dist
kof test modulo-02-dataframe/05-web-charts/exercise/exercise.kof
```

## Padrões
- `File.writeText` para HTML/SVG (JVM) + `kof serve` para HTTP (F3 full-stack `APP001`).
- Canvas JS é string literal em `dashboardHtml` — em produção, `kof.ui.Canvas` gera o mesmo via `KofJS` (shim `getContext` fechado).
- Formato legível (compact era workaround 0.3.2 `LineNumberTable`, corrigido em 0.3.22+).

## Gaps
- `kof.web` server (`WEB002`) é JVM-only; `KofJS` `WEB002` → `kof serve` static é o workaround para JS.
- `kof.ui` Window ainda `UI003` gap no Native; `Canvas` fecha `UI009` (desde 0.3.2, mantido em 0.4.7).
