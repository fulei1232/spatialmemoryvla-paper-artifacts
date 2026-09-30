#!/usr/bin/env bash

set -Eeuo pipefail
bundle="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="${1:-}"
if [[ -z "${root}" ]]; then
  root="$(find "${bundle}/evaluations" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d" " -f2-)"
fi
[[ -n "${root}" && -d "${root}" ]] || { echo "No rollout output directory found" >&2; exit 1; }

echo "Output: ${root}"
echo "Running processes:"
pgrep -af "deploy.py|eval_libero.py" || true
echo "Completed rollout records:"
find "${root}" -name rollouts.jsonl -type f -print0 | while IFS= read -r -d '' path; do
  printf "%6d  %s\n" "$(wc -l <"${path}")" "${path}"
done
echo "Recent worker output:"
for path in "${root}"/worker-gpu*.log; do
  [[ -f "${path}" ]] || continue
  echo "== ${path} =="
  tail -5 "${path}"
done
nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader
