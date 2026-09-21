# Limitações da Linguagem Kof — Versão 0.4.9-beta

> Documento de diagnóstico baseado em experimentação contra o compilador
> instalado localmente (`~/.kof/bin/kof`, kof 0.4.9-beta, JVM backend).
> Última atualização: 2026-09-21 — contém **apenas limitações verificadas com a versão nova** (0.4.9).
> Bugs de 0.1.3 corrigidos em 0.3.2 (#47, #31, #30), de 0.3.2 corrigidos em 0.3.22
> (List<Double>, LineNumberTable, Value==Value) e de 0.3.22 corrigidos em 0.4.4
> (retorno anulável) foram movidos para “Corrigidos”. 0.4.5–0.4.9 não quebraram
> nenhum dos 51 labs (verificados `0 failed` em 0.4.9).

---

## 1. Palavras reservadas `fn`/`fun`/`func` (PARSE085) — mantida em 0.4.9

**Sintoma:** `record Confusion(Int tp, Int tn, Int fp, Int fn)` não compila:
```
PARSE085: 'fn' é palavra reservada (Kof não tem keyword de função)
```

**Causa:** Em 0.3.2 `fn`/`fun`/`func` viraram palavras reservadas (`SG-001` `b5d3f2a`). Mantido em 0.4.9 (verificado hoje, intencional, não bug).

**Mitigação:** `fn` → `falseNeg` (ver `modulo-03-ml/04-metricas/lab.kof:70`).

---

## 2. `kof.config` ainda sem API estável (SEM025) — mantido

**Sintoma:**
```
SEM025: Cannot resolve method 'get' on namespace 'config'
```
Verificado em 0.4.9 (`kof 0.4.9-beta`, `config.get("app.name", "default")`).

**Causa:** `kof.config` ainda não expõe `config.get("key")` estável (0.4.0 adicionou `ui-config`, mas `config.get` segue `SEM025`).

**Mitigação:** Usar `log.info` + `secrets.get(key, fallback)`; `config` documentado como futuro (ver `01-05`).

---

## 3. `kof run <arquivo>` compila o diretório inteiro (PKG005/PKG002) — mantido

**Sintoma:** `kof run modulo-X/lab.kof` falha com `duplicate type name 'foo' in package '' [PKG005]`
ou `module has 2 main() functions [PKG002]` quando há outro `.kof` com mesmos símbolos no mesmo diretório.
Verificado em 0.4.9 (`/tmp/opencode/v_pkg/mod/a.kof` + `b.kof`). `kof test <arquivo>` é isolado por arquivo — comportamento inconsistente.

**Causa:** Desde 0.3.22 o `kof run` trata o diretório como pacote (module resolution `PKG006`/`PKG007`).

**Mitigação:** `exercise.kof` em `exercise/` subdir em todos os 51 labs (ver `docs/TEMPLATE-LICAO.md`).

---

## 4. `File.mkdir()` é no-op silencioso; `.toString()` no retorno quebra o backend — mantido

**Sintoma 4a (verificado em 0.4.9):** `File("/tmp/x").mkdir()` compila e roda (`stmt ok`), mas o diretório **não** é criado e nenhum erro é emitido.

**Sintoma 4b (verificado em 0.4.9):** `var r = File("/tmp/x").mkdir()` + `r.toString()` (ou `mkdir().toString()` direto) quebra com:
```
java.lang.ClassFormatError: Illegal class name "" in class file Default/Main
```
Enquanto `var e = File(...).exists()` + `e.toString()` funciona (`true`). Ou seja, o tipo de retorno de `mkdir()` difere de `exists()` no backend.

**Mitigação:** Usar `Directory("path").createDirectories()` (verificado em 0.4.9, cria de verdade — ver `modulo-08-data/01-lakehouse/lab.kof:13` com partições `lake/city=<city>/part-v<ver>.jsonl`). Candidato a issue upstream.

---

## 0.4.5–0.4.9: verificado sem impacto no curso

| Mudança 0.4.5–0.4.9 | Status em 0.4.9 | Ação no curso |
|---|---|---|
| `SEM076` field rule (um field por NAME) | ✅ sweep passa, nenhum `record`/`class` do curso tem fields duplicados | Nenhuma |
| `kof fmt` re-escapa literais (§305/#447) | ✅ `kof fmt` em probe com `\"`/`\\` não corrompe; `run` imprime `a"b\c` | Nenhuma |
| `getOrDefault` / `sort` / `indexOf` em coleções (0.4.8 #386) | ✅ verificados (`sort`→`1`, `indexOf`→`1`, `getOrDefault`→`-1`) | Nenhuma |
| `kof.shell` MVP / `kof.workflow` MVP (0.4.5/0.4.6) | ✅ novos namespaces, R1 boundary gate não afeta curso | Citados como futuro em `09-03` |
| `kof deploy` multi-target (0.4.6) | ✅ não usado nos labs | Nenhuma |
| Comparação anulável `Int? v > 0` (§295) | ✅ `if (v != null && v > 0)` imprime `pos` | Nenhuma |
| `Char.toString()` = caractere (0.4.0 #153) | ✅ `s.charAt(0).toString()` = `A` | Curso já usava `substring` |
| `println()` sem args → `SEM096` (0.4.8 #495) | ✅ nenhum lab chama `println()` sem args (sweep passa) | Nenhuma |
| `List.add(i,v)` → `SEM072`, `reduce` sem seed → `SEM073` (0.4.8) | ✅ curso usa `add(v)` e `reduce` com seed | Nenhuma |

## Corrigidos em 0.4.4 (mantidos em 0.4.9)

| Bug | 0.3.22 | 0.4.4+ | Ação no curso |
|-----|-------|-------|---------------|
| Retorno anulável `Int?` (`VerifyError: foo()I areturn`) | ❌ | ✅ fix (reverificado em 0.4.9) | Nenhum workaround era usado; documentado como corrigido |
| `math.parseInt/parseDouble/parseIntOrDefault` nativos | ❌ | ✅ novo (0.4.0 S13a/b, reverificado em 0.4.9) | Curso mantém parsers manuais didáticos (`shared/numberparse.kof`); nativos citados como alternativa |
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

## Consequências no desenho (0.4.9)

1. **Cada lab é 1 arquivo `.kof` legível** (280 linhas OK) + comentário `// Source: shared/<file>.kof`.
2. **`falseNeg` ao invés de `fn`** mantido (breaking change intencional `SG-001`).
3. **`List<Double>` idiomático** em `records` para `json` (bugs corrigidos, sem workarounds).
4. **`exercise.kof` em `exercise/` subdir** para evitar `PKG005` duplicate em `kof run` (module resolution desde 0.3.22, mantido em 0.4.9).
5. **Partições hive-style reais** em `08-01` via `Directory.createDirectories()` (verificado em 0.4.9; `File.mkdir()` é no-op).
6. **`kof test` e `kof run` verificados** com `0.4.9` (`51` labs `0 failed`).
