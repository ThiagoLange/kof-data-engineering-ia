# Lab 2.3 — Motor de Geração de Gráficos em SVG Puro

## Objetivo

Gerar programaticamente dois gráficos vetoriais SVG — scatter plot (sepal_length vs petal_length, cor por espécie) e barras (contagem de transações por cidade) — mapeando coordenadas de dados para pixels e persistindo `.svg` via `File.writeText`.

## Conceito

SVG é XML vetorial: cada ponto/barra vira um elemento `<circle>`/`<rect>` com coordenadas calculadas por mapeamento linear `mapX/mapY` (domínio de dados → faixa de pixels, com inversão do eixo Y). O lab não usa biblioteca gráfica — todo `path` é concatenação de strings, o que torna a geração portável e testável (validar `contains("<circle")`).

Dois gráficos:

1. **Scatter**: `x=sepal_length`, `y=petal_length`, `color=species` (lookup manual). Área de plotagem com padding e eixos desenhados como `<line>`.
2. **Barras**: `countByCity` (mesma agregação do Lab 2.2) → `barSvg` com slot/bars/gap proporcionais e rótulos `value` sobre cada barra.

## Diagrama

```
 iris.csv ─► loadIris ─► [IrisRow] ─► scatterSvg ─► File.writeText(scatter.svg)
                                                    
 customers+transactions ─► countByCity ─► [Bar(city, count)] ─► barSvg ─► File.writeText(bars.svg)

 scatterSvg: minD/maxD → mapX/mapY → <circle> per row + legend
 barSvg: maxD → slot/barW → <rect> + <text> per bar
```

## Dataset

- `datasets/iris.csv` — 15 flores para o scatter (2 eixos contínuos).
- `datasets/customers.jsonl` + `datasets/transactions.jsonl` — contagem por cidade para barras.

## Comandos

```bash
kof run modulo-02-dataframe/03-svg-charts/lab.kof
kof test modulo-02-dataframe/03-svg-charts/exercise.kof
```

## Padrões & Idiomática Kof

- **Funções puras `mapX/mapY`** mantêm `Double` arithmetic fora dos loops de concatenação (COMP002).
- **Record `Bar`/`IrisRow`** para dados tipados; SVG como `String` construída por `sb = sb + ...`.
- **`colorForSpecies` via `if`** — sem Map, 3 valores fixos.
- **`File.writeText` + verificação por `contains`** nos testes.

## Gaps & Limitações

- Sem biblioteca SVG nativa — geração é string concatenation pura.
- `Int.toDouble()` via `1.0 * n` não necessária aqui (Double já domina).
- File I/O é JVM (mas funciona em JS via polyfill; Native requer `writeBytes`).
