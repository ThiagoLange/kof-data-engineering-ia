# Limitações da Linguagem Kof — Versão 0.3.22-beta

> Documento de diagnóstico baseado em experimentação contra o compilador
> instalado localmente (`~/.kof/bin/kof`, kof 0.3.22-beta, JVM backend).
> Última atualização: 2026-09-11 — contém **apenas limitações verificadas com a versão nova** (0.3.22).
> Bugs de 0.1.3 corrigidos em 0.3.2 (#47, #31, #30) e de 0.3.2 corrigidos em 0.3.22 (List<Double>, LineNumberTable, Value==Value) foram movidos para “Corrigidos”.

---

## 1. Palavras reservadas `fn`/`fun`/`func` (PARSE085) — mantida em 0.3.22

**Sintoma:** `record Confusion(Int tp, Int tn, Int fp, Int fn)` não compila:
```
PARSE085: 'fn' é palavra reservada (Kof não tem keyword de função)
```

**Causa:** Em 0.3.2 `fn`/`fun`/`func` viraram palavras reservadas (`SG-001` `b5d3f2a`). Mantido em 0.3.22 (intencional, não bug).

**Mitigação:** `fn` → `falseNeg` (ver `modulo-03-ml/04-metricas/lab.kof:70`).

---

## 2. `kof.config` ainda sem API estável (SEM025) — mantido

**Sintoma:**
```
SEM025: Cannot resolve method 'get' on namespace 'config'
```

**Causa:** `kof.config` ainda não expõe `config.get("key")` estável.

**Mitigação:** Usar `log.info` apenas; `config` documentado como futuro (ver `01-05`).

---

## Corrigidos em 0.3.22 (workarounds removidos do curso)

| Bug | 0.3.2 | 0.3.22 | Ação no curso |
|-----|-------|--------|---------------|
| `List<Double>` em `record` para `json` (`GenericSignatureFormatError`) | ❌ | ✅ fix | `04-otimizadores` e `05-04` revertidos para `List<Double>` idiomático |
| `LineNumberTable` >200 linhas (`ClassFormatError`) | ❌ | ✅ fix | `06-03` revertido para 280 linhas legível (compact não mais necessário) |
| `Value == Value` em `while` (`VerifyError`) | ❌ | ✅ fix | `04-02` pode usar `visited` com `==` (mantido `backward` sem `visited` por simplicidade) |
| `spawn f(var)` e `await` com `Handle` | ❌ em 0.1.3 | ✅ fix #31 em 0.3.22 | `01-03` usa `val h = spawn f()` + `await h` |
| `array.get` `ClassFormatError` | ❌ | ✅ fix #30 | `04-01`/`05-04` sem workaround |

---

## Consequências no desenho (0.3.22)

1. **Cada lab é 1 arquivo `.kof` legível** (280 linhas OK) + comentário `// Source: shared/<file>.kof`.
2. **`falseNeg` ao invés de `fn`** mantido (breaking change intencional `SG-001`).
3. **`List<Double>` idiomático** em `records` para `json` (bug corrigido, workarounds removidos).
4. **`exercise.kof` em `exercise/` subdir** para evitar `PKG005` duplicate em `kof run` (0.3.22 `module resolution`).
5. **`kof test` e `kof run` verificados** com `0.3.22` (`51` labs `0 failed`).
