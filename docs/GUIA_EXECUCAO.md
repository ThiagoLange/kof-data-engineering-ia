# Guia de Execução — Passo a Passo (51 labs, kof 0.3.2-beta)

> Siga exatamente nesta ordem. Todos os comandos assumem execução na **raiz do repositório** (`kof-data-engineering-ia/`).

## 0. Pré-requisitos

```bash
# 1. Ativar toolchain 0.3.2 (instalada em ~/.kof)
export PATH="$HOME/.kof/bin:$PATH"
kof version  # deve imprimir: kof 0.3.2-beta
kof info     # JVM 21, Targets: jvm, native, js

# 2. Conferir datasets (8 arquivos, novo iris_full.csv 150 linhas)
ls datasets/
# employees.csv  houses.tsv  iris.csv  iris_full.csv  customers.jsonl  transactions.jsonl  docs.jsonl  classification_eval.jsonl

# 3. Validar instalação (lab 00)
kof check modulo-00-setup/01-kof-toolchain/lab.kof
kof run   modulo-00-setup/01-kof-toolchain/lab.kof
# esperado: 8/8 datasets OK, setup OK
kof test  modulo-00-setup/01-kof-toolchain/exercise.kof  # 4 tests PASS
```

## 1. Rodar um lab (padrão para todos)

Cada pasta `modulo-XX/lab-YY/` tem 3 arquivos:

```bash
kof run  modulo-XX/lab-YY/lab.kof       # demonstração (gera artefatos, imprime no terminal)
kof test modulo-XX/lab-YY/exercise.kof  #  verifica (deve dar: 0 failed)
kof check modulo-XX/lab-YY/lab.kof      #  type-check rápido (sem executar)
```

Exemplo concreto:

```bash
kof run  modulo-01-fundamentos/01-parser-csv-streamed/lab.kof
# parsed rows: 6

kof test modulo-01-fundamentos/01-parser-csv-streamed/exercise.kof
# SUITE ... (11 tests) 0 failed
```

## 2. Ordem recomendada (00 → 10)

Copie e cole por módulo. Cada bloco é independente, mas a ordem abaixo é didática.

### Módulo 00 — Setup
```bash
kof run  modulo-00-setup/01-kof-toolchain/lab.kof
kof test modulo-00-setup/01-kof-toolchain/exercise.kof
```

### Módulo 01 — Fundamentos (6 labs)
```bash
kof run  modulo-01-fundamentos/01-parser-csv-streamed/lab.kof && kof test modulo-01-fundamentos/01-parser-csv-streamed/exercise.kof
kof run  modulo-01-fundamentos/02-jsonl-schema/lab.kof && kof test modulo-01-fundamentos/02-jsonl-schema/exercise.kof
kof run  modulo-01-fundamentos/03-pipeline-paralelo/lab.kof && kof test modulo-01-fundamentos/03-pipeline-paralelo/exercise.kof
kof run  modulo-01-fundamentos/04-io-binario/lab.kof && kof test modulo-01-fundamentos/04-io-binario/exercise.kof
kof run  modulo-01-fundamentos/05-observabilidade/lab.kof && kof test modulo-01-fundamentos/05-observabilidade/exercise.kof
kof run  modulo-01-fundamentos/06-pii/lab.kof && kof test modulo-01-fundamentos/06-pii/exercise.kof
```

### Módulo 02 — Dataframe & Visualização (5 labs)
```bash
kof run  modulo-02-dataframe/01-dataframe/lab.kof && kof test modulo-02-dataframe/01-dataframe/exercise.kof
kof run  modulo-02-dataframe/02-groupby-join/lab.kof && kof test modulo-02-dataframe/02-groupby-join/exercise.kof
kof run  modulo-02-dataframe/03-svg-charts/lab.kof && kof test modulo-02-dataframe/03-svg-charts/exercise.kof
# artefatos: modulo-02-dataframe/03-svg-charts/scatter.svg , bars.svg
kof run  modulo-02-dataframe/04-html-report/lab.kof && kof test modulo-02-dataframe/04-html-report/exercise.kof
# artefato: modulo-02-dataframe/04-html-report/report.html
kof run  modulo-02-dataframe/05-web-charts/lab.kof && kof test modulo-02-dataframe/05-web-charts/exercise.kof
# artefatos: modulo-02-dataframe/05-web-charts/dashboard.html (+ scatter.svg/bars.svg)
xdg-open modulo-02-dataframe/05-web-charts/dashboard.html
kof serve modulo-02-dataframe/05-web-charts --port 8080  # http://localhost:8080
kof build --target js modulo-02-dataframe/05-web-charts --output dist && kof serve dist --port 8080
```

### Módulo 03 — ML Clássico (6 labs)
```bash
kof run  modulo-03-ml/01-features-normalization/lab.kof && kof test modulo-03-ml/01-features-normalization/exercise.kof
kof run  modulo-03-ml/02-linear-regression-sgd/lab.kof && kof test modulo-03-ml/02-linear-regression-sgd/exercise.kof
kof run  modulo-03-ml/03-decision-tree/lab.kof && kof test modulo-03-ml/03-decision-tree/exercise.kof
kof run  modulo-03-ml/04-metricas/lab.kof && kof test modulo-03-ml/04-metricas/exercise.kof
kof run  modulo-03-ml/05-validacao/lab.kof && kof test modulo-03-ml/05-validacao/exercise.kof
kof run  modulo-03-ml/06-drift/lab.kof && kof test modulo-03-ml/06-drift/exercise.kof
```

### Módulo 04 — Deep Learning (5 labs)
```bash
kof run  modulo-04-deep/01-tensor/lab.kof && kof test modulo-04-deep/01-tensor/exercise.kof
kof run  modulo-04-deep/02-autograd/lab.kof && kof test modulo-04-deep/02-autograd/exercise.kof
kof run  modulo-04-deep/03-mlp/lab.kof && kof test modulo-04-deep/03-mlp/exercise.kof
kof run  modulo-04-deep/04-otimizadores/lab.kof && kof test modulo-04-deep/04-otimizadores/exercise.kof
kof run  modulo-04-deep/05-registry/lab.kof && kof test modulo-04-deep/05-registry/exercise.kof
```

### Módulo 05 — LLMs (7 labs)
```bash
kof run  modulo-05-llms/01-llm-client/lab.kof && kof test modulo-05-llms/01-llm-client/exercise.kof
kof run  modulo-05-llms/02-tokenizer-chunking/lab.kof && kof test modulo-05-llms/02-tokenizer-chunking/exercise.kof
kof run  modulo-05-llms/03-cosine-similarity/lab.kof && kof test modulo-05-llms/03-cosine-similarity/exercise.kof
kof run  modulo-05-llms/04-vector-store/lab.kof && kof test modulo-05-llms/04-vector-store/exercise.kof
kof run  modulo-05-llms/05-chunking-semantico/lab.kof && kof test modulo-05-llms/05-chunking-semantico/exercise.kof
kof run  modulo-05-llms/06-rag-eval/lab.kof && kof test modulo-05-llms/06-rag-eval/exercise.kof
kof run  modulo-05-llms/07-avaliacao-llm/lab.kof && kof test modulo-05-llms/07-avaliacao-llm/exercise.kof
```

### Módulo 06 — Agentes (6 labs)
```bash
kof run  modulo-06-agentes/01-tool-schema/lab.kof && kof test modulo-06-agentes/01-tool-schema/exercise.kof
kof run  modulo-06-agentes/02-react-loop/lab.kof && kof test modulo-06-agentes/02-react-loop/exercise.kof
kof run  modulo-06-agentes/03-sandbox/lab.kof && kof test modulo-06-agentes/03-sandbox/exercise.kof
kof run  modulo-06-agentes/04-memoria/lab.kof && kof test modulo-06-agentes/04-memoria/exercise.kof
kof run  modulo-06-agentes/05-mcp-server/lab.kof && kof test modulo-06-agentes/05-mcp-server/exercise.kof
kof run  modulo-06-agentes/06-avaliacao/lab.kof && kof test modulo-06-agentes/06-avaliacao/exercise.kof
```

### Módulo 07 — Integração (3 labs)
```bash
kof run  modulo-07-integracao/01-pipeline-batch/lab.kof && kof test modulo-07-integracao/01-pipeline-batch/exercise.kof
kof run  modulo-07-integracao/02-rag-completo/lab.kof && kof test modulo-07-integracao/02-rag-completo/exercise.kof
kof run  modulo-07-integracao/03-agente-memoria/lab.kof && kof test modulo-07-integracao/03-agente-memoria/exercise.kof
```

### Módulo 08 — Data Moderna (8 labs)
```bash
kof run  modulo-08-data/01-lakehouse/lab.kof && kof test modulo-08-data/01-lakehouse/exercise.kof
kof run  modulo-08-data/02-quality/lab.kof && kof test modulo-08-data/02-quality/exercise.kof
kof run  modulo-08-data/03-streaming/lab.kof && kof test modulo-08-data/03-streaming/exercise.kof
kof run  modulo-08-data/04-feature-store/lab.kof && kof test modulo-08-data/04-feature-store/exercise.kof
kof run  modulo-08-data/05-dag/lab.kof && kof test modulo-08-data/05-dag/exercise.kof
kof run  modulo-08-data/06-contratos/lab.kof && kof test modulo-08-data/06-contratos/exercise.kof
kof run  modulo-08-data/07-cdc/lab.kof && kof test modulo-08-data/07-cdc/exercise.kof
kof run  modulo-08-data/08-cache/lab.kof && kof test modulo-08-data/08-cache/exercise.kof
```

### Módulo 09 — Portabilidade (3 labs)
```bash
kof run  modulo-09-portabilidade/01-native/lab.kof && kof test modulo-09-portabilidade/01-native/exercise.kof
kof run  modulo-09-portabilidade/02-perf/lab.kof && kof test modulo-09-portabilidade/02-perf/exercise.kof
kof check modulo-09-portabilidade/03-contributing/lab.kof && kof run modulo-09-portabilidade/03-contributing/lab.kof
```

### Módulo 10 — Capstone (1 lab)
```bash
kof run  modulo-10-capstone/01-pipeline-completo/lab.kof && kof test modulo-10-capstone/01-pipeline-completo/exercise.kof
```

## 3. Verificação completa

```bash
# Todos os labs de uma vez (50 suítes, ~90s em 0.3.2)
bash scripts/run-tests.sh

# Apenas testes, sem fmt (mais rápido)
for f in $(find modulo-* -name "exercise.kof" | sort); do kof test "$f"; done

# Inspecionar IR / profile de um lab
kof inspect modulo-04-deep/01-tensor/lab.kof | head -n 20
kof profile modulo-04-deep/01-tensor/lab.kof 2>&1 | head -n 20

# Build para outros targets (gates documentados)
kof build --target native modulo-01-fundamentos/05-observabilidade/lab.kof  # OK (LOG001)
kof build --target js     modulo-09-portabilidade/01-native/lab.kof        # OK
kof build --target native modulo-01-fundamentos/03-pipeline-paralelo/lab.kof  # falha com CONC001 (esperado)
```

## 4. Artefatos gerados

| Lab | Artefato | Abrir |
|-----|----------|-------|
| `02-03` | `scatter.svg` / `bars.svg` | `xdg-open modulo-02-dataframe/03-svg-charts/scatter.svg` |
| `02-04` | `report.html` | `xdg-open modulo-02-dataframe/04-html-report/report.html` |
| `02-05` | `dashboard.html` | `xdg-open modulo-02-dataframe/05-web-charts/dashboard.html` |
| `08-01` | `lake_*.jsonl` + `watermark.csv` | `cat modulo-08-data/01-lakehouse/watermark.csv` |

Todos são re-criados com `kof run` e removidos com `File(...).delete()` ao final do lab (exceto `02-03`/`02-04`/`02-05` que permanecem para `kof serve`).

## 5. Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `PARSE085 'fn' é palavra reservada` | Código antigo com `fn` | Renomeado para `falseNeg` em `03-04` (0.3.2) |
| `GenericSignatureFormatError` `List<Double>` | `record` com `List<Double>` para `json` | Usa `String csv` em `04-04`/`05-04` |
| `Invalid pc in LineNumberTable` | Arquivo >200 linhas | `06-03` em formato compacto 15 linhas |
| `kof: command not found` | `PATH` sem `~/.kof/bin` | `export PATH="$HOME/.kof/bin:$PATH"` |
| `datasets/... cannot read` | Rodou fora da raiz | Sempre rodar na raiz `kof-data-engineering-ia/` |
