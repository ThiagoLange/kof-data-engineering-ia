# Rubrica de Avaliação — Treinamento Kof para IA & Dados

> Critérios para considerar um módulo concluído e para certificação final.

## Escala
| Conceito | Significado |
|----------|-------------|
| A — Excelência | `kof test` 100% + artefatos regenerados + `kof check` sem warnings |
| B — Aprovado | `kof test` ≥90% pass, 1 retry permitido |
| C — Em progresso | `kof test` <90% ou `kof run` falha |
| N/A | Lab ainda não iniciado |

## Por Módulo (checagem automática via `bash scripts/run-tests.sh`)

| Módulo | Labs | Critério A | Artefato verificado |
|--------|------|------------|---------------------|
| 00 Setup | 01 | `kof test` 4/4 + 8/8 datasets `OK` | `datasets/iris_full.csv` 151 linhas |
| 01 Fundamentos | 01-04 | 11+8+4+16 tests pass | `employees.kof1.bin` round-trip 6/6 rows |
| 02 Dataframe | 01-04 | 7+7+5+5 tests pass | `scatter.svg` contém `<circle`, `report.html` contém `<canvas` |
| 03 ML Clássico | 01-04 | 8+5+7+7 tests pass | `zscore mean~0`, `tree accuracy >=0.8`, `F1 0.833` |
| 04 Deep | 01-04 | 7+6+7+5 tests pass | `Gram 4x4`, `autograd 96/64/32`, `softmax sum 1.0`, `adam loss 34→<5` |
| 05 LLMs | 01-04 | 6+8+8+7 tests pass | `cosine ortho 0`, `vector-store top-1 exact` |
| 06 Agentes | 01-04 | 8+8+10+7 tests pass | `tool-schema required`, `ReAct 96`, `sandbox timeout`, `memoria 25 toks` |
| 07 Integração | 01-03 | Cada pipeline `kof run` sem `throw` + `kof test` 100% | `pipeline_report.html`, `rag.jsonl` |

## Certificação Final
- **Certificado Básico:** Módulos 00-02 com conceito A.
- **Certificado Intermediário:** 00-04 com conceito A + 05-06 com ≥B.
- **Certificado Avançado:** 00-07 com A em todos + `kof bench` sem regressão (>5% vs. baseline).

## Como avaliar (instrutor)
```bash
bash scripts/run-tests.sh 2>&1 | grep -E "PASS|FAIL|Summary"
kof run modulo-07-integracao/01-pipeline-batch/lab.kof
ls modulo-02-dataframe/03-svg-charts/scatter.svg
```

## Autoavaliação (aluno)
Antes de pedir revisão:
1. `kof check modulo-XX/.../lab.kof` sem erros.
2. `kof test modulo-XX/.../exercise.kof` 0 failed.
3. `kof run modulo-XX/.../lab.kof` regenera artefato esperado.
4. `docs/LIMITACOES-KOF-0.1.3.md` gaps citados corretamente no `README.md`.
