# Glossário Kof × Python/Spark

> Tradução rápida para quem vem de PyData.

| Conceito Python/Spark | Kof equivalente | Lab |
|-----------------------|-----------------|-----|
| `pandas.DataFrame` | `class DataFrame` + `Series` | `02-01` |
| `df[df.col > 5]` | `maskGt(col, 5.0)` + `filterMask` | `02-01` |
| `df.groupby("city").agg(mean)` | `groupByCity` + `mean` | `02-02` |
| `plt.scatter` | `scatterSvg` (gera `<circle>`) | `02-03` |
| `df.to_html()` | `buildHtml` + `<canvas>` | `02-04` |
| `StandardScaler` | `zscore`/`minmax` | `03-01` |
| `sklearn.linear_model.SGDRegressor` | `mse` + `grad` loop | `03-02` |
| `sklearn.tree.DecisionTreeClassifier` | `buildTree` + `gini` | `03-03` |
| `sklearn.metrics.f1_score` | `confusionMatrix` + `f1Score` | `03-04` |
| `torch.Tensor` | `class Tensor` | `04-01` |
| `torch.autograd` | `class Value` + `backward` | `04-02` |
| `torch.nn.Sequential` | `class MLP` | `04-03` |
| `torch.optim.Adam` | `class Adam` | `04-04` |
| `openai.ChatCompletion` | `LLMClient` + `FakeTransport` | `05-01` |
| `tiktoken` | `tokenize` + `chunkByWords` | `05-02` |
| `cosine_similarity` | `cosineSimilarity` | `05-03` |
| `FAISS/Chroma` | `VectorStore` | `05-04` |
| `airflow DAG` | `Scheduler` + `DagRun` | `08-05` |
| `delta lake` | `lake_<city>_v<ver>.jsonl` + `watermark.csv` | `08-01` |

## Cheatsheet CLI

```bash
kof run <lab.kof>              # JVM (default)
kof test <exercise.kof>        # testes
kof check <file|dir>           # type-check
kof inspect <file>             # IR stats
kof profile <file>             # CPU/RSS
kof build --target native <f> # Native (riscv64/aarch64)
kof build --target js <f>      # KofJS
bash scripts/run-tests.sh      # todas suítes
```
