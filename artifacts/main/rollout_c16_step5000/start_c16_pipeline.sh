#!/usr/bin/env bash

set -Eeuo pipefail
bundle="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${bundle}"

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
state_dir="${bundle}/pipeline-${stamp}"
mkdir -p "${state_dir}"
printf '%s\n' "$$" >"${state_dir}/pid"

echo "[$(date --iso-8601=seconds)] preparing A100 environment" | tee "${state_dir}/progress.log"
./prepare_a100_env.sh 2>&1 | tee "${state_dir}/prepare.log"

echo "[$(date --iso-8601=seconds)] starting smoke" | tee -a "${state_dir}/progress.log"
OUTPUT_ROOT="${state_dir}/smoke" ./smoke_a100.sh 2>&1 | tee "${state_dir}/smoke.log"

echo "[$(date --iso-8601=seconds)] smoke passed; starting formal rollout" | tee -a "${state_dir}/progress.log"
OUTPUT_ROOT="${state_dir}/formal" ./run_c16_formal_3conditions.sh 2>&1 | tee "${state_dir}/formal.log"

echo "[$(date --iso-8601=seconds)] pipeline complete" | tee -a "${state_dir}/progress.log"
