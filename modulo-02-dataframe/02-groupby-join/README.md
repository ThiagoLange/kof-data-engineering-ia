# Lab 2.2 — Agregações, GroupBy e Joins Relacionais

## Objetivo

Implementar em Kof operações relacionais sobre `datasets/transactions.jsonl` e `datasets/customers.jsonl`: hash-join (inner/left) entre as duas tabelas e GroupBy com agregações (média, mediana, desvio padrão, min/max, soma e contagem) por cidade.

## Conceito

Dados transacionais normalizados exigem duas operações fundamentais:

1. **Join**: `transactions.customer_id = customers.customer_id` — hash-join (fase build: indexar `customers`; fase probe: casar cada transação). A variante inner aborta em FK dangling (`throw`); a variante left preserva a linha com cidade/name vazios.
2. **GroupBy + agregações**: particionar o join por `city` e computar estatísticas por grupo. `mean`/`stddev` são acumuladores lineares O(n); `median` requer ordenação (bubble sort O(n²) aceitável para grupos pequenos, didático).

Em Kof 0.1.3-beta não há `Map` genérico otimizado nem `sort` na stdlib; o join é linear-scan (aceitável para n=5/7) e a mediana usa bubble sort explícito. Agregações reutilizam `shared/math.kof` com o workaround COMP002 (RHS puramente Double).

## Diagrama

```
 customers.jsonl ─┐
                  ├─► hashJoin (inner) ─► List<Joined(tx_id, customer_id, amount, name, city)>
 transactions.jsonl┘                     │
                                         ├─► leftJoin variant (preserva orfaos)
                                         │
                                         ▼
                                   distinctCities ─► [SP, RJ, MG]
                                         │
                                         ▼
                                   for each city:
                                      amountsForCity ─► List<Double>
                                         │
                                         ▼
                                   count/mean/median/stddev/min/max/sum
                                         │
                                         ▼
                                   List<Agg(city, count, sum, mean, ... )>
```

## Dataset

- `datasets/customers.jsonl` — 5 clientes (id, name, city)
- `datasets/transactions.jsonl` — 7 transações (tx_id, customer_id, amount)

FK `customer_id` é 100% íntegra no dataset, então inner e left retornam o mesmo n (7 rows) — o lab demonstra as duas variantes igualmente.

## Comandos

```bash
kof run modulo-02-dataframe/02-groupby-join/lab.kof
kof test modulo-02-dataframe/02-groupby-join/exercise.kof
```

## Padrões & Idiomática Kof

- **`record Joined/Agg`** para linhas tipadas; dados cruzam como records.
- **`throw` em FK dangling** (inner join) — erro de integridade, não sentinel.
- **Loops `while` + `List.set`** para ordenação/busca; sem `map`/`filter`/`sort`.
- **Mean/stddev com `1.0 * n`** nunca `toDouble()` isolado (COMP002).

## Gaps & Limitações

- Sem `Sort` nativo: bubble sort didático; para datasets grandes, ordenar antes reduz O(n²) → O(n log n).
- Sem `Map<K,V>` hash no beta estável — linear-scan atua como hash-table O(n) para os 5/7 registros; em produção use `mapOf` + `get` quando disponível.
- `Int.toDouble()` isolado gera `ClassFormatError` — mitigação `1.0 * n`.
