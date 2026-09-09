# Template de Lição

> Estrutura canônica para cada lab do treinamento Kof para IA & Dados.
> Aplicada em todos os 51 labs (11 módulos 00–10) em `kof 0.3.2-beta`.
> Cada lab tem variante compacta (<200 linhas) para evitar `LineNumberTable` bug em 0.3.2.

## Arquivos por lab

```
<modulo>/<lab-id>-<slug>/
├── README.md         # Conceito + diagrama + comandos + checklist
├── lab.kof           # Implementação completa comentada (demonstração)
└── exercise.kof      # Versão com TODOs + assertions (kof test)
```

## Estrutura do `README.md`

```markdown
# Lab X.Y — <título>

## Objetivo
<1 parágrafo do que se aprende>

## Conceito
<2-3 parágrafos com teoria mínima + referência à stdlib Kof>

## Diagrama
<ASCII art ou mermaid descrevendo o fluxo>

## Dataset
<Arquivo em datasets/ usado + justificativa>

## Comandos
kof run modulo-X/lab-Y/lab.kof
kof test modulo-X/lab-Y/exercise.kof

## Padrões & Idiomática Kof
<Quando usar throw vs sentinel, loops vs lambdas, etc.>

## Gaps & Limitações
<Gaps de target aplicáveis (CONC001, ORM001, etc.)>
```

## Estrutura do `lab.kof`

- Cabeçalho: `// modulo-X/lab-Y — <título>`
- Funções auxiliares (helpers inlined com referência a `shared/<file>.kof`)
- `main()` que demonstra uso real, lendo de `datasets/`

## Estrutura do `exercise.kof`

- Versão idêntica ao `lab.kof` mas com chamadas wrapped em `assert(...)`.
- Cada afirmação tem `assert(cond, "msg descritiva")`.
- Rodar com `kof test` deve passar 100%.

## Padrões obrigatórios

1. **Sem dependências ocultas**: tudo vem de `datasets/` ou é gerado.
2. **Segredos via env**: `secrets.get(key, fallback)` ou `requireEnv(key)`.
3. **Funções puras** (sem I/O global) sempre que possível — `main` é o entry point.
4. **Throws para erros**, nunca `abort`/`panic`.
5. **Comentários em inglês técnico**, README conceitual em PT-BR.
6. **Sem segredos hardcoded** — grep `LLM_API_KEY|sk-|password` deve ser zero.