#!/usr/bin/env bash
# scripts/run-tests.sh — CI helper for the Kof training.
# Runs kof fmt (check) and kof test per exercise, reports aggregate.
# Usage: bash scripts/run-tests.sh [--fmt-write]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FMT_WRITE=0
if [[ "${1:-}" == "--fmt-write" ]]; then FMT_WRITE=1; fi

echo "== Kof version =="
kof version || { echo "kof not found in PATH"; exit 1; }
echo ""

if [[ $FMT_WRITE -eq 1 ]]; then
  echo "== kof fmt -w (all labs) =="
  # fmt is idempotent; -w rewrites in place
  find "$ROOT" -name "*.kof" -print -exec kof fmt -w {} \; 2>&1 | head -n 20 || true
else
  echo "== kof fmt (check, no write) =="
  FAIL=0
  while IFS= read -r f; do
    if ! kof fmt "$f" >/dev/null 2>&1; then
      echo "fmt FAIL: $f"
      FAIL=1
    fi
  done < <(find "$ROOT" -name "*.kof" | sort)
  if [[ $FAIL -eq 0 ]]; then echo "fmt OK (no syntax errors)"; else echo "fmt had failures (see above)"; fi
fi
echo ""

echo "== kof test (all exercises) =="
TOTAL=0
PASSED=0
FAILED=0
# Collect exercises that have test blocks; all exercise.kof under modulo-*
while IFS= read -r f; do
  echo "--- $f"
  out="$(kof test "$f" 2>&1 || true)"
  echo "$out" | tail -n 8
  if echo "$out" | grep -q "0 failed"; then
    PASSED=$((PASSED+1))
  else
    FAILED=$((FAILED+1))
    echo ">>> FAILED: $f"
  fi
  TOTAL=$((TOTAL+1))
done < <(find "$ROOT" -path "*/exercise.kof" | sort)

echo ""
echo "== Summary =="
echo "Total suites: $TOTAL | Passed: $PASSED | Failed: $FAILED"
if [[ $FAILED -ne 0 ]]; then exit 1; fi
echo "All suites passed."
