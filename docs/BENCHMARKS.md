# Benchmarks — Kof `kof bench` & `kof profile`

> Como medir performance dos labs com a toolchain 0.3.2.

## Comandos base (JVM, padrão do treinamento)

```bash
# Inspeção de IR (otimizações)
kof inspect modulo-04-deep/01-tensor/lab.kof
kof inspect modulo-01-fundamentos/04-io-binario/lab.kof | grep -E "ops before|ops after"

# Profile (CPU, RSS, GC) — JVM
kof profile modulo-04-deep/01-tensor/lab.kof 2>&1 | head -n 20

# Bench oficial (usa suite em /opt/kof/benchmarks ou local)
kof bench --help
kof bench modulo-04-deep/01-tensor/lab.kof --iterations 5 --warmup 2 --json 2>&1 | head -n 30
```

## Benchmarks do treinamento (propostos)

### 1. I/O binário (`modulo-01-fundamentos/04-io-binario`)
- Métrica: tempo de `encodeFrame` + `rleEncode` sobre `employees.csv` (6 linhas) vs. `iris_full.csv` (150 linhas).
- Expectativa: `rleEncode` expande ~126% em dados high-entropy (IEEE-754) e comprime para ~2% em dados repetidos (page de 200 zeros). Isso demonstra por que codecs reais combinam RLE + entropy coding.

```bash
# Simula bench manual com time
time kof run modulo-01-fundamentos/04-io-binario/lab.kof 2>&1 | grep -E "raw frame|rle"
```

### 2. Tensor `matmul` (`modulo-04-deep/01-tensor`)
- Métrica: `G = Xᵀ·X` sobre `iris.csv` (15×4) vs. `iris_full.csv` (150×4) — O(n·d²).
- Baseline: `kof bench` com 150 linhas deve escalar ~10× vs. 15 linhas.

```bash
# Troca dataset para iris_full em cópia temporária
sed 's/iris.csv/iris_full.csv/g' modulo-04-deep/01-tensor/lab.kof > /tmp/tensor_full.kof
time kof run /tmp/tensor_full.kof 2>&1 | grep -E "X shape|G ="
```

### 3. Vector store `search` (`modulo-05-llms/04-vector-store`)
- Métrica: `search` linear O(n·dim) vs. n=5 vs. n=150 (iris_full indexado com fake embeddings).
- Baseline: sem índice ANN, latência cresce linearmente — motiva HNSW/IVF para produção.

## Interpretando `kof bench` baseline

O bench oficial compara contra `baselines/*.json` em `/opt/kof/benchmarks/baselines`. Para criar baseline do treinamento:

```bash
kof bench modulo-01-fundamentos/04-io-binario/lab.kof --iterations 10 --baseline /tmp/baseline_io.json
kof bench modulo-01-fundamentos/04-io-binario/lab.kof --iterations 10 --baseline /tmp/baseline_io.json --fail-on-regression --threshold 0.05
```

Threshold 5% falha se regressão >5% — use em CI (`scripts/run-tests.sh` futuro).

## Gaps

- `kof bench` nativo/JS ainda em alpha (mesmo `CONC001`/`JSN002`); benchmarks acima são JVM.
- Native `time.sleep`/`scheduler` só fechados em 0.3.1 (`SCHED001`, `TIME001`); `kof bench --target native` só após `CONC001` fechado.
