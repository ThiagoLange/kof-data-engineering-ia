# Limitações da Linguagem Kof — Versão 0.5.0-beta

> Documento de diagnóstico baseado em experimentação contra o compilador
> instalado localmente (`~/.kof/bin/kof`, kof 0.5.0-beta, JVM backend).
> Última atualização: 2026-09-28 — contém **apenas limitações verificadas com a versão nova** (0.5.0).
> Bugs de 0.1.3 corrigidos em 0.3.2 (#47, #31, #30), de 0.3.2 corrigidos em 0.3.22
> (List<Double>, LineNumberTable, Value==Value), de 0.3.22 corrigidos em 0.4.4
> (retorno anulável) e de 0.4.x corrigidos em 0.5.0 (`File.mkdir`)
> foram movidos para “Corrigidos”. 0.5.0 quebrou 7 arquivos (null-safety
> estrita `SEM014`/`SEM049`, todos corrigidos com guards — ver §5).

---

## 1. Palavras reservadas `fn`/`fun`/`func` (PARSE085) — mantida em 0.5.0

**Sintoma:** `record Confusion(Int tp, Int tn, Int fp, Int fn)` não compila:
```
PARSE085: 'fn' é palavra reservada (Kof não tem keyword de função)
```

**Causa:** Em 0.3.2 `fn`/`fun`/`func` viraram palavras reservadas (`SG-001` `b5d3f2a`). Mantido em 0.5.0 (intencional, não bug).

**Mitigação:** `fn` → `falseNeg` (ver `modulo-03-ml/04-metricas/lab.kof:70`).

---

## 2. `kof.config` ainda sem API estável (SEM025) — mantido

**Sintoma:**
```
SEM025: Cannot resolve method 'get' on namespace 'config'
```
Verificado em 0.5.0 (`kof 0.5.0-beta`, `config.get("app.name", "default")`).

**Causa:** `kof.config` ainda não expõe `config.get("key")` estável (0.4.0 adicionou `ui-config`, mas `config.get` segue `SEM025`).

**Mitigação:** Usar `log.info` + `secrets.get(key, fallback)`; `config` documentado como futuro (ver `01-05`).

---

## 3. `kof run <arquivo>` compila o diretório inteiro (PKG005/PKG002) — mantido

**Sintoma:** `kof run modulo-X/lab.kof` falha com `duplicate type name 'foo' in package '' [PKG005]`
ou `module has 2 main() functions [PKG002]` quando há outro `.kof` com mesmos símbolos no mesmo diretório.
Verificado em 0.5.0 (`/tmp/opencode/w2_pkg/mod/a.kof` + `b.kof`, agora com `arquivo:linha` no diagnóstico). `kof test <arquivo>` é isolado por arquivo — comportamento inconsistente.

**Causa:** Desde 0.3.22 o `kof run` trata o diretório como pacote (module resolution `PKG006`/`PKG007`).

**Mitigação:** `exercise.kof` em `exercise/` subdir em todos os 51 labs (ver `docs/TEMPLATE-LICAO.md`).

---

## 4. `File.mkdir()` era no-op silencioso — CORRIGIDO em 0.5.0

**Antes (0.4.x):** `File("/tmp/x").mkdir()` compilava e rodava sem criar o diretório;
`mkdir().toString()` quebrava com `ClassFormatError: Illegal class name ""`.

**Em 0.5.0:** `mkdir()` cria de verdade (verificado: `drwxrwxr-x ... /tmp/opencode/v50_d`)
e `mkdir().toString()` imprime `true`. O lab `08-01` mantém `Directory.createDirectories()`
(sem motivo para trocar — funciona desde 0.4.4).

---

## 5. Null-safety estrita em 0.5.0 (`SEM014`/`SEM049`) + guard inline (`COMP002`) — novo

**Sintoma:** 7 arquivos que passavam em 0.4.10 falham em 0.5.0:
```
Argument 1 of 'split': expected 'String' but got 'String?' [SEM014]
receiver is nullable (T?); narrow first: if (x != null) { x.method() } [SEM049]
```
`File.readText()` sempre retornou `String?`, mas só a 0.5.0 passou a exigir
narrowing em compile-time. `assert(x != null)` NÃO estreita — só `if`/`throw`.

**Mitigação (idiom do curso):** guard multilinha antes do uso:
```kof
var raw = File(path).readText()
if (raw == null) { throw "csv: cannot read file: " + path }
var lines = split(raw, "\n")
```
Arquivos corrigidos: `01-03` lab+exercise, `08-04` lab, `08-06` lab,
`00` exercise, `01-01` exercise, `01-02` exercise.

**Armadilha:** guard inline de uma linha (`...; if(raw==null){throw "x"}; ...`)
dispara `Internal compiler error: null [COMP002]` na 0.5.0 — usar a forma
multilinha acima. Candidato a issue upstream (junto do `mkdir`).

---

## 0.4.5–0.5.0: verificado sem impacto no curso (além do §5)

| Mudança 0.4.5–0.5.0 | Status em 0.5.0 | Ação no curso |
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
| Memory-safety gates (MEM001/MEM002 ownership, escape L-04) | ✅ 51 labs passam, loaders retornam listas locais sem erro | Nenhuma |
| `kof test --tag` + fixtures (0.4.8 X8) | ✅ aditivo, curso não usa tags | Nenhuma |
| 0.4.10 = só bump de versão (`[skip ci]`, sem mudança no compilador) | ✅ nada mudou no sweep entre 0.4.9 e 0.4.10 (histórico) | Nenhuma |
| 0.5.0: memory-safety (MEM001/MEM002, escape L-04), `kof test --tag`, gates `SEM072/073/096` | ✅ sweep 51/51 passa; só o §5 exigiu correção | Ver §5 |

## Corrigidos em 0.5.0 (verificados nesta versão)

| Bug | 0.4.x | 0.5.0 | Ação no curso |
|-----|-------|-------|---------------|
| `File.mkdir()` no-op silencioso + `.toString()` no retorno (`ClassFormatError`) | ❌ | ✅ fix | `08-01` mantém `Directory.createDirectories()` (funciona desde 0.4.4) |

## Corrigidos em 0.4.4 (mantidos em 0.5.0)

| Bug | 0.3.22 | 0.4.4+ | Ação no curso |
|-----|-------|-------|---------------|
| Retorno anulável `Int?` (`VerifyError: foo()I areturn`) | ❌ | ✅ fix (reverificado em 0.5.0) | Nenhum workaround era usado; documentado como corrigido |
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

## Consequências no desenho (0.5.0)

1. **Cada lab é 1 arquivo `.kof` legível** (280 linhas OK) + comentário `// Source: shared/<file>.kof`.
2. **`falseNeg` ao invés de `fn`** mantido (breaking change intencional `SG-001`).
3. **`List<Double>` idiomático** em `records` para `json` (bugs corrigidos, sem workarounds).
4. **`exercise.kof` em `exercise/` subdir** para evitar `PKG005` duplicate em `kof run` (module resolution desde 0.3.22, mantido em 0.5.0).
5. **Partições hive-style reais** em `08-01` via `Directory.createDirectories()` (agora `File.mkdir()` também funciona, mas `Directory` fica).
6. **Guards de null multilinha** (`if (x == null) { throw ... }`) em todo `readText()` — `assert` não estreita e guard inline quebra (`COMP002`).
7. **`kof test` e `kof run` verificados** com `0.5.0` (`51` labs `0 failed`).
