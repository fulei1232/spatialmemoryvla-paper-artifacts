#!/usr/bin/env bash

set -Eeuo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
verify_bundle

gpu_count="$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)"
[[ "${gpu_count}" -ge 4 ]] || { echo "Need four visible GPUs, found ${gpu_count}" >&2; exit 1; }

trials="${NUM_TRIALS_PER_TASK:-50}"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_root="${OUTPUT_ROOT:-${BUNDLE_ROOT}/evaluations/C16-seed42-normal-full8-full12-${stamp}}"
if find "${output_root}" -name rollouts.jsonl -print -quit 2>/dev/null | grep -q .; then
  echo "Refusing to append duplicate rollout records under ${output_root}" >&2
  exit 2
fi
mkdir -p "${output_root}/servers"

declare -a deploy_pids=()
declare -a worker_pids=()
cleanup() {
  for pid in "${worker_pids[@]:-}"; do
    [[ -n "${pid}" ]] && kill -TERM "${pid}" 2>/dev/null || true
  done
  for pid in "${deploy_pids[@]:-}"; do
    [[ -n "${pid}" ]] && kill -TERM "${pid}" 2>/dev/null || true
  done
  wait 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# Four independent inference replicas. Loading is intentionally serialized to
# avoid four simultaneous reads of the 33.6 GB checkpoint from shared storage.
for gpu in 0 1 2 3; do
  port=$((27820 + gpu))
  echo "Loading C16 replica on physical GPU ${gpu}, port ${port}"
  start_deploy "${gpu}" "${port}" "${output_root}/servers/gpu-${gpu}.log"
  deploy_pids+=("${DEPLOY_PID}")
done

formal_job() {
  local gpu="$1" port="$2" condition="$3" task="$4"
  local hard_case=normal
  local extra_args=()
  case "${condition}" in
    normal)
      ;;
    full8)
      hard_case=temporal_occlusion
      # Exactly: 5 visible calls, 3 partially occluded calls, 8 black calls.
      extra_args=(--occlusion_schedule_steps 17 --occlusion_partial_start_ratio 0.3125 --occlusion_full_start_ratio 0.5 --occlusion_recovery_start_ratio 1.0)
      ;;
    full12)
      hard_case=temporal_occlusion
      # Exactly: 5 visible calls, 3 partially occluded calls, 12 black calls.
      extra_args=(--occlusion_schedule_steps 21 --occlusion_partial_start_ratio 0.25 --occlusion_full_start_ratio 0.4 --occlusion_recovery_start_ratio 1.0)
      ;;
    *) echo "Unknown condition: ${condition}" >&2; return 2 ;;
  esac
  echo "GPU ${gpu}: ${condition}, task ${task}, states 0..$((trials - 1))"
  run_task "${gpu}" "${port}" "${task}" "${trials}" "${hard_case}" \
    "${output_root}/${condition}/task-${task}" "C16-${condition}-task${task}" \
    --save_rollout_videos False "${extra_args[@]}"
}

# Existing formal sweep identifies tasks 0 and 8 as the first informative
# comparison. Six matched jobs are distributed over all four A100s.
worker0() { formal_job 0 27820 normal 0; formal_job 0 27820 full8 0; }
worker1() { formal_job 1 27821 normal 8; formal_job 1 27821 full8 8; }
worker2() { formal_job 2 27822 full12 0; }
worker3() { formal_job 3 27823 full12 8; }

worker0 >"${output_root}/worker-gpu0.log" 2>&1 & worker_pids+=("$!")
worker1 >"${output_root}/worker-gpu1.log" 2>&1 & worker_pids+=("$!")
worker2 >"${output_root}/worker-gpu2.log" 2>&1 & worker_pids+=("$!")
worker3 >"${output_root}/worker-gpu3.log" 2>&1 & worker_pids+=("$!")

failed=0
for pid in "${worker_pids[@]}"; do
  wait "${pid}" || failed=1
done
worker_pids=()
(( failed == 0 )) || { echo "At least one rollout worker failed; inspect ${output_root}" >&2; exit 1; }

"${PYTHON}" "${BUNDLE_ROOT}/summarize_results.py" "${output_root}" --require-conditions normal full8 full12
echo "Formal C16 three-condition rollout complete: ${output_root}"
