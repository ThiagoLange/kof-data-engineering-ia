# Lab 6.2 — Loop de Raciocínio ReAct (Reasoning + Acting)

## Objetivo

Implementar o ciclo **ReAct** — `Thought → Action → Action Input →
Observation → … → Final Answer` — com um orquestrador em Kof que: (1) pede
o próximo passo a um LLM, (2) **faz parse do texto** devolvido (extrair
`Action` e `Action Input` por *string scanning*), (3) executa a tool local e
(4) realimenta a observação no prompt, com **máximo de iterações** como
salvaguarda contra laços infinitos.

## Conceito

ReAct (Yao et al., 2022) intercala raciocínio em linguagem natural com ações
em ferramentas. Em vez de responder direto, o LLM emite um raciocínio
(`Thought`), escolhe uma tool (`Action`) e produz os argumentos
(`Action Input`, tipicamente JSON). O orquestrador executa a tool, anexa a
`Observation` ao contexto e reenvia tudo ao LLM, até que ele emita
`Final Answer`.

Três decisões de engenharia são demonstradas aqui:

1. **Contrato textual estrito**: o parser reconhece linhas `Action:`,
   `Action Input:` e `Final Answer:` (cuidado: `Action Input:` começa com
   `Action:`, então o match é ordenado). Saída fora do contrato é erro
   observável, não comportamento indefinido.
2. **Salvaguardas de orquestração**: loop com `maxIter` — sem isso, um LLM
   que nunca emite `Final Answer` executa para sempre. Erros de tool viram
   `Observation: error: ...`, dando ao LLM a chance de se recuperar.
3. **FakeLLM programado**: como não há rede garantida, o "LLM" é uma classe
   com um **roteiro fixo** (`List<String>` de respostas, devolvidas em
   sequência). Isso torna o loop determinístico e testável — o mesmo padrão
   usado para testar agentes em produção (mock de modelo).

## Diagrama

```
 main(question)
     |
     v
 +--------------------+
 |  FakeLLM.complete  |  (roteiro: turn 0, turn 1, ...)
 +--------------------+
     |  Thought / Action / Action Input
     v
 +--------------------+
 |  ReAct text parser |  split("\n") + startsWith("Action:") ...
 +--------------------+
     |  action, inputJson
     v
 +--------------------+
 |   executeTool      |  calculator / get_customer / fetch_doc
 +--------------------+
     |  result  (ou "error: ..." capturado)
     v
 Observation anexada ao prompt
     |
     +---> proxima iteracao (ate Final Answer ou maxIter)
```

## Dataset

- `datasets/customers.jsonl` — consultado pela tool `get_customer` (filtro por
  cidade: SP → Alice, Carla, Eve).
- `datasets/docs.jsonl` — consultado pela tool `fetch_doc` (corpo do documento
  por id).

## Comandos

```bash
# da raiz do repo
kof run modulo-06-agentes/02-react-loop/lab.kof
kof test modulo-06-agentes/02-react-loop/exercise.kof
```

## Padrões & Idiomática Kof

- **Classe com estado mutável via `List`**: campos de construtor são `final`
  em 0.1.3-beta (reatribuir compila mas falha em runtime com
  `IllegalAccessError`). O contador de turnos do FakeLLM é um
  `List<Int>` de 1 elemento — mutação por `set(0, n)`, imitação de campo
  mutável. Ver "Gaps & Limitações".
- **`record` para resultados de parser** não é necessário: valores ausentes
  são `""` e o contrato textual garante presença; erros de contrato usam
  `throw` (idiomático).
- **Extração de campos JSON por string scanning** (`jsonField*`): flat JSON
  objects, sem escapes — `json.decode` com campos não-String quebra o
  compilador (bug novo, ver abaixo e o relatório do módulo).
- **Loops `while` explícitos** no lugar de `map`/`filter` (indisponíveis).
- **`try/catch (String e)`** para converter falha de tool em observação —
  exceções são Strings em Kof.

## Gaps & Limitações

- **Bug novo (COMP-class)**: `json.decode<T>` com records de 2+ campos onde
  algum campo é `Int`/`Double` gera `ClassFormatError: Illegal class name ""`;
  valor numérico JSON em campo `String` gera `NoClassDefFoundError`. Por isso
  os Action Inputs são parseados com `jsonField*` manuais. Mitigação
  registrada no relatório do módulo.
- **Bug novo**: reatribuição de campo de classe em método compila, mas em
  runtime `IllegalAccessError: Update to non-static final field`. Mitigação:
  tratar campos de classe como imutáveis; estado mutável só via campos
  `List` (mutáveis por referência).
- Sem chamadas a LLM reais (requisito do curso: 100% offline). Um cliente
  HTTP real seria o Lab 5.1 (`http.post` + `secrets.get("LLM_API_KEY",
  "")`); aqui o FakeLLM ocupa o mesmo encaixe de interface.
- O parser assume um bloco ReAct por linha e Action Input JSON flat, sem
  escapes dentro de strings — suficiente para o roteiro do lab; um parser
  tolerante a quebras de linha em strings exigiria máquina de estados.
