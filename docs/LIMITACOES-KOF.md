# Limitações da Linguagem Kof — Versão 0.8.1

> Documento de diagnóstico baseado em experimentação contra o compilador
> instalado localmente (`~/.kof/bin/kof`, **kof 0.8.1**, backend JVM).
> Última atualização: 2026-11-23 — gate completo re-executado na 0.8.1
> (53/53 suítes + `kof md check` OK, 53/53 labs com `kof run` OK).
> Cada item abaixo traz o código de diagnóstico real observado na 0.8.1 e a
> mitigação adotada no curso. Itens já corrigidos em versões anteriores estão
> em “Histórico de correções”, ao final.

---

## 1. Palavras reservadas `fn`/`fun`/`func` (PARSE085) — intencional

**Sintoma:** `record Confusion(Int tp, Int tn, Int fp, Int fn)` não compila:
```
PARSE085: 'fn' is a reserved word (Kof has no function keyword)
```

**Causa:** desde a 0.3.2 `fn`/`fun`/`func` são palavras reservadas (`SG-001`).
Comportamento intencional da linguagem, mantido na 0.8.1.

**Mitigação:** `fn` → `falseNeg` (ver `modulo-03-ml/04-metricas/lab.kof`).

---

## 2. Sem `Option<T>`/`Result<T>` (SEM011) — ativo na 0.8.1

**Sintoma:**
```
SEM011: Undefined variable or type: 'Option<Int>' ... (R6: undefined declared types must not compile)
```

**Causa:** a stdlib não oferece `Option<T>`/`Result<T>`; erros usam `throw`/`catch`
e ausência usa retorno anulável (`T?`).

**Mitigação:** `throw`/`catch (String e)` para erros de contrato; `T?` + narrowing
para ausência; sentinelas explícitos só quando documentados (ex.: `parseIntSafe`).

---

## 3. `kof.config` sem `get` estável (SEM025) — ativo na 0.8.1

**Sintoma:**
```
SEM025: Cannot resolve method 'get' on namespace 'config'
```
Verificado em 0.8.1 com `config.get("app.name", "default")`.

**Causa:** `kof.config` ainda não expõe `config.get("key")` estável.

**Mitigação:** `log.info` + `secrets.get(key, fallback)`; `config` documentado
como futuro (ver `01-05`).

---

## 4. `kof run <arquivo>` compila o diretório inteiro (PKG002/PKG005) — ativo na 0.8.1

**Sintoma:** `kof run modulo-X/lab.kof` falha quando há outro `.kof` com símbolos
conflitantes no mesmo diretório:
```
module has 2 main() functions; expected exactly one [PKG002]
duplicate type name 'Foo' in package '' [PKG005]
```
Verificado em 0.8.1 (`PKG002` sem `arquivo:linha`; `PKG005` com `arquivo:linha`).
`kof test <arquivo>` é isolado por arquivo — comportamento inconsistente.

**Causa:** desde a 0.3.22 `kof run` resolve o diretório como pacote
(`PKG006`/`PKG007`).

**Mitigação:** `exercise.kof` em subdir `exercise/` nos 53 labs (ver
`docs/TEMPLATE-LICAO.md`), mantendo um único `main()`/tipo por diretório.

---

## 5. Null-safety estrita (SEM014/SEM049) — ativo na 0.8.1

**Sintoma:** usar um receptor/argumento anulável sem narrowing falha:
```
receiver is nullable (T?); narrow first: if (x != null) { x.method() } [SEM049]
Argument N of 'f': expected 'String' but got 'String?' [SEM014]
```
Verificado em 0.8.1 (ex.: `readText()` seguido de `raw.split(...)`).

**Causa:** `File.readText()` retorna `String?`; o compilador exige narrowing em
compile-time. `assert(x != null)` **não** estreita — só `if`/`throw`.

**Mitigação (idiom do curso):** guard multilinha antes do uso:
```kof
var raw = File(path).readText()
if (raw == null) { throw "csv: cannot read file: " + path }
var lines = split(raw, "\n")
```

---

## 6. Mensagem de `assert` deve ser string literal (PARSE087) — novo em 0.8.x

**Sintoma:** asserts com mensagem concatenada deixam de compilar:
```
error: assert message must be a string literal (statements.md §9) [PARSE087]
```

**Causa:** desde a linha 0.8.x o segundo argumento de `assert` precisa ser um
literal de string; `"got " + x.toString()` (ou qualquer expressão) é recusado.
`assert(cond)` sem mensagem continua válido.

**Mitigação:** mensagem estática descritiva (e `throw` explícito quando o valor
importa):
```kof
assert(lines.size() >= 16, "iris.csv >=16 lines")
if (lines.size() < 16) { throw "iris.csv >=16 lines got " + lines.size().toString() }
```
A 0.6.3→0.8.1 exigiu corrigir 72 asserts em 21 `exercise.kof` (prefixo literal
preservado).

---

## 7. Sem bit-cast de `Double` (SEM074/SEM025) — ativo na 0.8.1

**Sintoma:**
```
'double' is a primitive — it has no method 'toBits()' [SEM074]
Cannot resolve method 'doubleToLongBits' on namespace 'math' [SEM025]
```

**Causa:** a stdlib não expõe a representação binária de `Double` como inteiro.

**Mitigação:** empacotar IEEE-754 à mão (decomposição estilo `frexp`) — ver
`modulo-01-fundamentos/04-io-binario/lab.kof`.

---

## 8. Sem streams de arquivo (`Reader.readLine()`) (SEM015) — ativo na 0.8.1

**Sintoma:**
```
Undefined function: 'Reader' [SEM015]
```

**Causa:** não há API de leitura incremental linha a linha na stdlib.

**Mitigação:** `File.readText()`/`readBytes()` + iteração por linhas; para
arquivos grandes, I/O binário (Lab 1.4).

---

## 9. `String.split` usa separador literal e retorna `array` — ativo na 0.8.1

**Sintoma:** `s.split(" ")` retorna `array` (use `.length`, não `.size()`); não há
split por regex — `s.split(" +")` procura a substring literal `" +"`.

**Causa:** desde a 0.8.0 o separador de `String.split` é literal
(`D-SPLIT-LITERAL`); não há overload de regex.

**Mitigação:** separador literal + loops; quando se precisa de `List<String>`,
o curso usa `splitManual` (`shared/strutils.kof`) por didática.

---

## 10. `Int` → `String` concatena o valor decimal, não o caractere — ativo na 0.8.1

**Sintoma:** `"A" + 66` imprime `A66`; não há conversão `Int` → caractere por
code point.

**Causa:** a conversão de primitivos para `String` usa a representação decimal
(`n.toString()`); `Char.toString()` devolve o caractere, mas não há
`Int.toChar()`.

**Mitigação:** lookup table de ASCII imprimível para reconstruir o caractere
(ver `modulo-01-fundamentos/04-io-binario/lab.kof`).

---

## 11. Ferramentas: alcance por target — 0.8.1

- `kof debug` (DAP) cobre **JVM e Native** (`--target jvm|native`); no JS não há
  inspector/DAP (`DAP` ausente no target JS).
- `kof profile` aceita `--target jvm|native|js`.
- `kof build --target js` é alpha (ver aviso da CLI).

Não são bloqueios do curso (os labs rodam no backend JVM), mas limitam
depuração/profiling por target.

---

## Histórico de correções (não são mais limitações)

Itens que já foram gaps em versões anteriores e **não se reproduzem na 0.8.1**:

| Item | Estado anterior | Estado atual |
|------|-----------------|--------------|
| `spawn f(var)` com variável | `VerifyError` em 0.1.3 | corrigido em 0.3.22 |
| `List<Double>` em `record` para `json` | `GenericSignatureFormatError` | corrigido em 0.3.22 |
| `LineNumberTable` > 200 linhas | `ClassFormatError` | corrigido em 0.3.22 |
| `Value == Value` em `while` | `VerifyError` | corrigido em 0.3.22 |
| Retorno anulável `Int?` | `VerifyError` | corrigido em 0.4.4 |
| `File.mkdir()` no-op silencioso | não criava diretório | corrigido em 0.5.0 |
| Guard inline de null (`...; if(x==null){throw};...`) | `COMP002` | não reproduzido na 0.8.1 |
| `n.toDouble()` isolado | `ClassFormatError`/`COMP002` | não reproduzido na 0.8.1 |
| `intVar * 1.0` dentro de `while` | `COMP002` | não reproduzido na 0.8.1 |
| Reatribuição de campo de construtor | falhava em runtime | funciona na 0.8.1 |
| `json.decode` com campos não-String em `record` | `ClassFormatError` | corrigido em 0.3.22 |
| Tipos recursivos (`record Node(... Node ...)`) | não suportados no parser | aceitos pelo parser na 0.8.1 |

> Observação: a 0.8.1 é o target oficial do curso. Recursos que já existem hoje
> (`List<Bool>`, `map`/`filter`, `Map<K,V>`, `List.sort()`, `math.sqrt`) são
> citados nos labs como alternativas; os labs mantêm implementações manuais por
> didática, não por limitação da linguagem.

---

## Consequências no desenho do curso (0.8.1)

1. **Cada lab é 1 arquivo `.kof` legível** (280 linhas OK) + comentário `// Source: shared/<file>.kof`.
2. **`falseNeg` ao invés de `fn`** (breaking change intencional `SG-001`).
3. **`List<Double>` idiomático** em `records` para `json` (bugs corrigidos, sem workarounds).
4. **`exercise.kof` em `exercise/` subdir** para evitar `PKG002`/`PKG005` no `kof run`.
5. **Partições hive-style reais** em `08-01` via `Directory.createDirectories()`.
6. **Guards de null multilinha** (`if (x == null) { throw ... }`) em todo `readText()`.
7. **`kof test` e `kof run` verificados** com `0.8.1` (`53` labs `0 failed`).
