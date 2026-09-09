# Limitações da Linguagem Kof — Versão 0.3.2-beta

> Documento de diagnóstico baseado em experimentação contra o compilador
> instalado localmente (`~/.kof/bin/kof`, kof 0.3.2-beta, JVM backend).
> Última atualização: 2026-09-09 — contém **apenas limitações verificadas com a versão nova** (0.3.2).
> Bugs de 0.1.3 corrigidos em 0.3.2 (#47, #31, #30) foram removidos.

---

## 1. Palavras reservadas `fn`/`fun`/`func` (PARSE085)

**Sintoma:** `record Confusion(Int tp, Int tn, Int fp, Int fn)` não compila:
```
PARSE085: 'fn' é palavra reservada (Kof não tem keyword de função)
```

**Causa:** Em 0.3.2 `fn`/`fun`/`func` viraram palavras reservadas para futura sintaxe de função (`fix: fun/fn/func viram palavras reservadas — SG-001`, release 0.3.2 `b5d3f2a`).

**Mitigação:** Renomear campo/variável `fn` → `falseNeg` (ver `modulo-03-ml/04-metricas/lab.kof:70`).

---

## 2. `List<Double>` em `record` para `json.encode/decode` (GenericSignatureFormatError)

**Sintoma:**
```
java.lang.reflect.GenericSignatureFormatError: Signature Parse error: Expected Field Type Signature
  Remaining input: D>;
  at dev.kof.runtime.KofRuntime.kof_json_decode_Checkpoint
```

Reproduzível mínimo:
```kof
record Checkpoint(List<Double> params, Int step)
main() { var cp = Checkpoint(listOf<Double>(), 5); json.decode<Checkpoint>(json.encode(cp)) } // falha em 0.3.2, passava em 0.1.3
```

**Causa:** `Double` (primitivo) é emitido como `D` no generic signature, mas `List<Double>` espera `Ljava/lang/Double;` (boxed). Em 0.3.2 a verificação de `RecordComponent.getGenericType` ficou mais estrita.

**Mitigação:** Armazenar como `String` CSV e converter manualmente (ver `modulo-04-deep/04-otimizadores/lab.kof:80` `record Checkpoint(String paramsCsv, Int step)` + `parseCsvToDoubles`, e `05-llms/04-vector-store` `DocEntry(String embeddingCsv)`).

---

## 3. `LineNumberTable` inválido em arquivos >~200 linhas (ClassFormatError)

**Sintoma:**
```
java.lang.ClassFormatError: Invalid pc in LineNumberTable in class file Default/Main
```

Reproduzível: `modulo-06-agentes/03-sandbox/lab.kof` com 280 linhas (muitos `if`/`try`/`catch`) compila (`kof check` OK) mas falha no `kof run` em 0.3.2. Versão compacta com 15 linhas passa.

**Causa:** Em 0.3.2 o `KofCompiler` gera `LineNumberTable` com `pc` fora do `code_length` quando o método `main` é muito grande (regressão não presente em 0.1.3).

**Mitigação:** Manter labs em formato compacto (<200 linhas, helpers em linha única) — ver `06-03` compact 15 linhas.

---

## 4. `Value == Value` em `if` dentro de `while` (VerifyError)

**Sintoma:**
```
VerifyError: Bad type on operand stack ... Type 'Value' not assignable to integer
```

Reproduzível: `if (visited.get(i) == v)` dentro de loop onde `visited` é `List<Value>` (ver `modulo-04-deep/02-autograd/lab.kof:162`).

**Causa:** Mesmo bug de `spawn f(var)` (`VerifyError: Lambda0 not assignable`) — o `ASM Frame` trata `Value` como `int` no `if_icmpeq`.

**Mitigação:** Comparar campos primitivos (`Int id`) ao invés de objetos; `backward` recursivo sem `visited` com `+=` acumula correto para diamantes pequenos.

---

## 5. `kof.config` ainda sem API estável (SEM025)

**Sintoma:**
```
SEM025: Cannot resolve method 'get' on namespace 'config'
```

**Causa:** `kof.config` em 0.3.2 ainda não expõe `config.get("key")` estável (planejado `kof.config` file>env>profile).

**Mitigação:** Usar `log.info` apenas; `config` documentado como futuro (ver `01-05`).

---

## Consequências no desenho (0.3.2)

1. **Cada lab é compacto** (<200 linhas) + comentário `// Source: shared/<file>.kof`.
2. **`falseNeg` ao invés de `fn`** em todos os records/metrics.
3. **`String csv` ao invés de `List<Double>`** em records que serão `json` serializados.
4. **`backward` sem `visited`** em `04-02` Autograd.
5. **`sandbox` em formato compacto** (15 linhas) para evitar `LineNumberTable`.
