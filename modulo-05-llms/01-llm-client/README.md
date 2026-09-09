# Lab 5.1 — Cliente HTTP para Inferência de LLMs (com Retry e Injeção de Transporte)

## Objetivo

Construir um wrapper de cliente para APIs de chat estilo OpenAI/Anthropic que:
- isola a chamada HTTP real atrás de uma interface (`Transport`), permitindo
  testar 100% offline com um `FakeTransport` de respostas programadas;
- implementa retry com **backoff exponencial manual** (`time.sleep`) para erros
  transitórios (HTTP 5xx / 429), falhando rápido em erros de cliente (4xx);
- lê a API key de `secrets.get("LLM_API_KEY", "")` — sem segredo hardcoded, e
  com demo opcional que imprime `skipped` quando a chave não existe.

## Conceito

Clientes de LLM em produção raramente fazem uma única chamada HTTP: redes
falham, APIs limitam taxa (429) e instâncias caem (5xx). O padrão defensivo é:

1. **Injetar o transporte** (dependency injection manual): o cliente depende
   da abstração `Transport`, não de `http.post`. Em teste, injeta-se um fake
   que falha N vezes e depois devolve uma resposta programada — sem rede.
2. **Retry só do que é transitório**: 5xx e 429 voltam a tentar com espera
   crescente (`delay = base * 2^attempt`); 4xx (request malformado, chave
   inválida) nunca deve ser repetido.
3. **Backoff com sleep real**: `kof.time.sleep(ms)` pausa a thread atual (JVM,
   virtual threads). O atraso cresce exponencialmente para não atolar a API
   sob falha em cascata.

Em Kof 0.1.3-beta, `http.post(url, body[, headers])` retorna o corpo como
`String` e lança `String` em erro de rede/HTTP — exatamente a superfície que o
`Transport` espelha. Como exceções são `String`, a política de retry inspeciona
o prefixo da mensagem (`"HTTP 5"` / `"HTTP 429"`).

## Diagrama

```
        main()
          |
          v
   +--------------+     scripted failures      +------------------+
   | LLMClient    | -------------------------> | FakeTransport    | (testes)
   | complete()   |   retries c/ backoff       | failsLeft, resp  |
   +--------------+                            +------------------+
          |
          | Transport.send(url, body, headers)  <- interface
          |
    +-----+------+
    |            |
    v            v
+--------+  +---------+
| HttpTransport       | http.post real (JVM)     | ErrorTransport   |
| (demo opcional,     |--------------------------| sempre lança 4xx |
|  key via secrets)   |                          | (fails fast)     |
+--------+  +---------+
```

## Dataset

Nenhum arquivo de dados — a lição é 100% self-contained e offline. A demo ao
vivo (opcional) usa `secrets.get("LLM_API_KEY", "")`; sem chave, imprime
`skipped`.

## Comandos

```bash
# da raiz do repo
kof run modulo-05-llms/01-llm-client/lab.kof
kof test modulo-05-llms/01-llm-client/exercise.kof
```

## Padrões & Idiomática Kof

- **`interface` + `class ... implements`** para injeção de dependência manual
  (sem container — ver `philosophy.md`). Classes que implementam interface
  precisam de fields + `constructor` explícito; `class X(a, b) implements I`
  não é aceito pelo parser 0.1.3-beta.
- **`throw`/`catch (String e)`** como mecanismo de erro; erros transitórios são
  reconhecidos por prefixo na mensagem.
- **`time.sleep(ms)`** para backoff (JVM); mantido curto (base 50ms) para os
  testes não ficarem lentos.
- **`secrets.get(key, fallback)`** para credenciais — nunca hardcoded.
- **Retry loop com `try` dentro de `while`** — cada tentativa é isolada e o
  contador de chamadas do fake prova que a política funcionou.

## Gaps & Limitações

- **`json.decode<T>` não suporta records aninhados dentro de `List`**
  (`record R(List<Choice> choices)` → `ClassCastException: LinkedHashMap
  cannot be cast to Choice` no JVM). Por isso a resposta da API é analisada por
  `extractJsonString` (scanner de `"content":"..."` com unescape de `\n`/`\t`).
  Gap relacionado: JSN001 (Double em JSON no JS).
- **`Char.toString()` retorna o código numérico**, não o caractere — construir
  strings char a char exige `s.substring(k, k + 1)`.
- `http.post`/`time.sleep` são JVM-only (HTTP002/TIME001 em Native/JS) — todos
  os labs do treinamento usam target JVM.
- Sem `Option`/`Result`: falhas transitórias vs. permanentes são distinguidas
  por convenção de prefixo na mensagem de exceção.
