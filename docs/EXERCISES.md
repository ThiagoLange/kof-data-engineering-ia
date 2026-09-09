# Exercícios — Como usar `exercise.kof` vs. `lab.kof`

> Diferença entre demonstração (`lab.kof`) e desafio (`exercise.kof`).

## Estrutura

```
modulo-XX/lab-YY/
├── lab.kof       # solução completa, comentada, `kof run` demonstra
├── exercise.kof  # cópia de lab.kof + blocos `test "nome" { assert(...) }`
└── README.md
```

- `lab.kof` é a **solução oficial** — estude, rode, modifique à vontade.
- `exercise.kof` é o **verificador automático** — `kof test exercise.kof` deve dar `0 failed`.

## Estratégia TODO (recomendada para instrutores)

Para transformar um lab em desafio real com `TODO`s sem quebrar `kof test`, use o padrão:

```kof
// TODO 1: implemente mean(xs) — média aritmética
// Dica: use 1.0 * n para Int→Double (COMP002)
mean(List<Double> xs): Double {
    // TODO: descomente e complete
    // var s = 0.0; var i = 0; while(i < xs.size()) { s = s + xs.get(i); i = i + 1 }
    // return s / (1.0 * xs.size())
    return 0.0 // <- apagará este stub quando implementar
}

test "mean of [1,2,3] is 2.0" {
    var xs = listOf<Double>(); xs.add(1.0); xs.add(2.0); xs.add(3.0)
    var m = mean(xs)
    var d = m - 2.0; if(d < 0.0){d = -d}
    assert(d < 0.0001, "mean 2.0 got "+m.toString())
}
```

1. Mantenha o teste intacto; o aluno só edita a função com `TODO`.
2. Quando `mean` retornar `0.0`, o teste falha — feedback imediato.
3. Para criar um `starter.kof`, copie `exercise.kof` e substitua corpos por `throw "TODO"` ou stubs.

Exemplo de `starter` já pronto: `modulo-01-fundamentos/01-parser-csv-streamed/starter.kof` (gerado via script, não commitado por padrão para não duplicar 24 arquivos).

## Gerando starters automaticamente (opcional)

```bash
python3 scripts/make_starters.py  # futuro: gera modulo-*/starter.kof com TODOs
```

Por enquanto, instrutores podem criar `starter.kof` manualmente copiando `exercise.kof` e apagando implementações, mantendo apenas `test` blocks.

## Verificação

```bash
kof test modulo-02-dataframe/01-dataframe/exercise.kof  # deve passar 100% na solução
# se starter ainda com TODOs:
kof test modulo-02-dataframe/01-dataframe/starter.kof   # deve falhar, mostrando o que falta
```
