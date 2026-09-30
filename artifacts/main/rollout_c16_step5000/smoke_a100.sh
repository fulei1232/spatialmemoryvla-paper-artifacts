#!/usr/bin/env bash

set -Eeuo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
verify_bundle

gpu="${GPU_ID:-0}"
port="${PORT:-27820}"
trials="${NUM_TRIALS_PER_TASK:-2}"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_root="${OUTPUT_ROOT:-${BUNDLE_ROOT}/evaluations/smoke-${stamp}}"
mkdir -p "${output_root}"

deploy_pid=""
cleanup() {
  if [[ -n "${deploy_pid}" ]] && kill -0 "${deploy_pid}" 2>/dev/null; then
    kill -TERM "${deploy_pid}" 2>/dev/null || true
    wait "${deploy_pid}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "Starting C16 step-5000 on physical GPU ${gpu}"
start_deploy "${gpu}" "${port}" "${output_root}/deploy.log"
deploy_pid="${DEPLOY_PID}"

for condition in normal full8 full12; do
  extra_args=()
  hard_case=normal
  if [[ "${condition}" == full8 ]]; then
    hard_case=temporal_occlusion
    extra_args=(--occlusion_schedule_steps 17 --occlusion_partial_start_ratio 0.3125 --occlusion_full_start_ratio 0.5 --occlusion_recovery_start_ratio 1.0)
  elif [[ "${condition}" == full12 ]]; then
    hard_case=temporal_occlusion
    extra_args=(--occlusion_schedule_steps 21 --occlusion_partial_start_ratio 0.25 --occlusion_full_start_ratio 0.4 --occlusion_recovery_start_ratio 1.0)
  fi
  for task in 0 8; do
    echo "Smoke rollout: ${condition}, task ${task}, ${trials} official initial states"
    run_task "${gpu}" "${port}" "${task}" "${trials}" "${hard_case}" \
      "${output_root}/${condition}/task-${task}" "smoke-${condition}-task${task}" \
      "${extra_args[@]}"
  done
done

"${PYTHON}" "${BUNDLE_ROOT}/summarize_results.py" "${output_root}"
echo "Smoke passed without evaluator/server failure: ${output_root}"
echo "Review success rates and videos, then run: ${BUNDLE_ROOT}/run_c16_formal_3conditions.sh"
