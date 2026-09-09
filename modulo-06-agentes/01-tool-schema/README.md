# Lab 6.1 — Schema de Ferramentas e Serialização de Chamadas

## Objetivo

Definir ferramentas (tools) de forma tipada em Kof — `Tool(name, description,
List<Param>)` — e serializá-las para o formato **JSON Schema** usado pelo
*function calling* de LLMs (OpenAI/Anthropic), gerando o JSON por concatenação
de strings com controle total sobre a forma de saída.

## Conceito

Agentes de IA não executam código arbitrário: eles escolhem, a cada passo, uma
ferramenta de um catálogo fechado e produzem **argumentos estruturados**. Esse
contrato é o *tool schema*. Três propriedades são essenciais:

1. **Declarativo**: o schema descreve nome, descrição e parâmetros tipados de
   cada tool — é a única fonte de verdade sobre o que o agente pode chamar.
2. **Serializável**: o schema viaja dentro do payload da requisição ao LLM em
   JSON Schema (`type: object`, `properties`, `required`).
3. **Validável**: o mesmo schema serve para validar estritamente os argumentos
   que o LLM devolver (ver Lab 6.3).

Em Kof, modelamos isso com `record Param(...)` e `record Tool(...)`, e a
função `toJsonSchema(tool): String` faz o mapeamento de tipos
(`Int → integer`, `Double → number`, `String → string`, `Bool → boolean`)
montando o JSON literalmente. Não usamos `json.encode` aqui de propósito: a
forma do JSON Schema de function calling é fixa pela especificação, e gerá-la
por concatenação torna o exercício explicitamente auditável — cada campo, em
ordem, sob nosso controle.

## Diagrama

```
 Tool(name, description, List<Param>)
        |
        v
 toJsonSchema(tool)  -- concatenação de strings + jsonEscape
        |
        v
 {"name":"calculator",
  "description":"Binary arithmetic: a op b",
  "parameters":{"type":"object",
    "properties":{"a":{"type":"number",...}},
    "required":["a","b","op"]}}
        |
        v
  payload da requisição ao LLM (function calling)
```

## Dataset

Nenhum arquivo de `datasets/` é consumido neste lab — os schemas referenciam
os datasets que as tools usarão depois (`customers.jsonl` no `get_customer`,
`docs.jsonl` no `fetch_doc`), mas a serialização em si é pura. Os labs 6.2 e
6.3 consomem exatamente estas definições.

## Comandos

```bash
# da raiz do repo
kof run modulo-06-agentes/01-tool-schema/lab.kof
kof test modulo-06-agentes/01-tool-schema/exercise.kof
```

## Padrões & Idiomática Kof

- **`record` para dados declarativos** (Param/Tool): igualdade por conteúdo,
  imutabilidade, `toString` automático no JVM.
- **Geração de JSON por concatenação** em vez de `json.encode`: o shape é
  fixo pela spec de function calling; string building deixa a ordem dos
  campos explícita e testável por `contains`.
- **`jsonEscape` explícito** — descrições de tools são texto livre; sem
  escaping, uma aspa quebraria o payload inteiro.
- **`required` como `Int` 0/1**: nullable types e `Option<T>` não existem em
  0.1.3-beta; flags inteiras são o workaround canônico do treinamento.
- **`throw` em tipos desconhecidos** em `jsonType` — erro de programação
  (tipo não mapeado), não condição de runtime.

## Gaps & Limitações

- **`json.decode<T>` para records com campos não-String quebra o compilador**
  (registro novo, ver relatório do módulo): records com 2+ campos onde algum
  é `Int`/`Double` geram `ClassFormatError: Illegal class name ""`. Por isso o
  exercício valida o JSON gerado por *string scanning* (`contains`), não por
  `json.decode` para um record espelho — o espelho com campos aninhados
  (`properties`, `required`) não sobreviveria à reflexão mesmo.
- Sem `Map<String, T>` na stdlib: o JSON Schema é emitido como texto, e
  qualquer parse de volta (Lab 6.3) usa helpers de extração de campo por
  string scanning (`jsonField*`), não reflexão.
- Escaping cobre apenas o essencial (quote, backslash, \n, \r, \t); Unicode
  de controle fora desse conjunto não é escapado (datasets do curso são ASCII).
