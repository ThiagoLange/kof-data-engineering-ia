# Limitações da Linguagem Kof — Versão 0.4.4-beta

> Documento de diagnóstico baseado em experimentação contra o compilador
> instalado localmente (`~/.kof/bin/kof`, kof 0.4.4-beta, JVM backend).
> Última atualização: 2026-09-18 — contém **apenas limitações verificadas com a versão nova** (0.4.4).
> Bugs de 0.1.3 corrigidos em 0.3.2 (#47, #31, #30), de 0.3.2 corrigidos em 0.3.22
> (List<Double>, LineNumberTable, Value==Value) e de 0.3.22 corrigidos em 0.4.4
> (retorno anulável) foram movidos para “Corrigidos”.

---

## 1. Palavras reservadas `fn`/`fun`/`func` (PARSE085) — mantida em 0.4.4

**Sintoma:** `record Confusion(Int tp, Int tn, Int fp, Int fn)` não compila:
```
PARSE085: 'fn' é palavra reservada (Kof não tem keyword de função)
```

**Causa:** Em 0.3.2 `fn`/`fun`/`func` viraram palavras reservadas (`SG-001` `b5d3f2a`). Mantido em 0.4.4 (intencional, não bug).

**Mitigação:** `fn` → `falseNeg` (ver `modulo-03-ml/04-metricas/lab.kof:70`).

---

## 2. `kof.config` ainda sem API estável (SEM025) — mantido

**Sintoma:**
```
SEM025: Cannot resolve method 'get' on namespace 'config'
```
Verificado em 0.4.4 (`kof 0.4.4-beta`, `config.get("app.name", "default")`).

**Causa:** `kof.config` ainda não expõe `config.get("key")` estável (0.4.0 adicionou `ui-config`, mas `config.get` segue `SEM025`).

**Mitigação:** Usar `log.info` + `secrets.get(key, fallback)`; `config` documentado como futuro (ver `01-05`).

---

## 3. `kof run <arquivo>` compila o diretório inteiro (PKG005/PKG002) — mantido

**Sintoma:** `kof run modulo-X/lab.kof` falha com `duplicate type name 'foo' in package '' [PKG005]`
ou `module has 2 main() functions [PKG002]` quando há outro `.kof` com mesmos símbolos no mesmo diretório.
Verificado em 0.4.4 (`/tmp/q_pkg/mod/a.kof` + `b.kof`). `kof test <arquivo>` é isolado por arquivo — comportamento inconsistente.

**Causa:** Desde 0.3.22 o `kof run` trata o diretório como pacote (module resolution `PKG006`/`PKG007`).

**Mitigação:** `exercise.kof` em `exercise/` subdir em todos os 51 labs (ver `docs/TEMPLATE-LICAO.md`).

---

## 4. `File.mkdir()` é no-op silencioso; `.toString()` no retorno quebra o backend — novo em 0.4.4

**Sintoma 4a:** `File("/tmp/x").mkdir()` compila e roda (`stmt ok`), mas o diretório **não** é criado e nenhum erro é emitido.

**Sintoma 4b:** `var r = File("/tmp/x").mkdir()` + `r.toString()` (ou `mkdir().toString()` direto) quebra com:
```
java.lang.ClassFormatError: Illegal class name "" in class file Default/Main
```
Enquanto `var e = File(...).exists()` + `e.toString()` funciona (`true`). Ou seja, o tipo de retorno de `mkdir()` difere de `exists()` no backend.

**Mitigação:** Usar `Directory("path").createDirectories()` (verificado em 0.4.4, cria de verdade — ver `modulo-08-data/01-lakehouse/lab.kof:13` com partições `lake/city=<city>/part-v<ver>.jsonl`). Candidato a issue upstream.

---

## Corrigidos em 0.4.4 (verificados nesta versão)

| Bug | 0.3.22 | 0.4.4 | Ação no curso |
|-----|-------|-------|---------------|
| Retorno anulável `Int?` (`VerifyError: foo()I areturn`) | ❌ | ✅ fix | Nenhum workaround era usado; documentado como corrigido |
| `math.parseInt/parseDouble/parseIntOrDefault` nativos | ❌ | ✅ novo (0.4.0 S13a/b) | Curso mantém parsers manuais didáticos (`shared/numberparse.kof`); nativos citados como alternativa |
| `Char.toString()` retornava code point (`"65"`) | ❌ #153 | ✅ fix | Curso já usava `substring`, sem mudança necessária |
| `String.split` / `List.map/filter/reduce` nativos | ❌ gap | ✅ funcionam | Curso mantém helpers manuais didáticos; nativos citados |
| `spawn f(var)` com variável | ❌ em 0.1.3 | ✅ (mantido desde 0.3.22) | `01-03` sem mudança |
| `json` com `List<Inner>` aninhado | ❌ gap | ✅ funciona | `05-04` segue com `List<Double>` idiomático |

## Corrigidos em 0.3.22 (mantidos)

| Bug | 0.3.2 | 0.3.22+ | Ação no curso |
|-----|-------|---------|---------------|
| `List<Double>` em `record` para `json` (`GenericSignatureFormatError`) | ❌ | ✅ fix | `04-otimizadores` e `05-04` com `List<Double>` idiomático |
| `LineNumberTable` >200 linhas (`ClassFormatError`) | ❌ | ✅ fix | `06-03` com 280 linhas legível |
| `Value == Value` em `while` (`VerifyError`) | ❌ | ✅ fix | `04-02` com `backward` recursivo |
| `spawn f(var)` e `await` com `Handle` | ❌ em 0.1.3 | ✅ fix #31 | `01-03` usa `val h = spawn f()` + `await h` |
| `array.get` `ClassFormatError` | ❌ | ✅ fix #30 | `04-01`/`05-04` sem workaround |

---

## Consequências no desenho (0.4.4)

1. **Cada lab é 1 arquivo `.kof` legível** (280 linhas OK) + comentário `// Source: shared/<file>.kof`.
2. **`falseNeg` ao invés de `fn`** mantido (breaking change intencional `SG-001`).
3. **`List<Double>` idiomático** em `records` para `json` (bugs corrigidos, sem workarounds).
4. **`exercise.kof` em `exercise/` subdir** para evitar `PKG005` duplicate em `kof run` (module resolution desde 0.3.22, mantido em 0.4.4).
5. **Partições hive-style reais** em `08-01` via `Directory.createDirectories()` (novo em 0.4.4; `File.mkdir()` é no-op).
6. **`kof test` e `kof run` verificados** com `0.4.4` (`51` labs `0 failed`).
