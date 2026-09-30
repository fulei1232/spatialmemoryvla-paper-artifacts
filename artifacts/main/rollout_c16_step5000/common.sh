#!/usr/bin/env bash

set -Eeuo pipefail

BUNDLE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${BUNDLE_ROOT}/source/SpatialMemoryVLA"
LIBERO_ROOT="${PROJECT_ROOT}/third_libs/LIBERO"
VENV="${BUNDLE_ROOT}/.venv-rollout"
PYTHON="${VENV}/bin/python"
CHECKPOINT="${BUNDLE_ROOT}/model/C16-step5000/checkpoints/step-005000-epoch-24-loss=0.0068.pt"

export HF_HOME="${BUNDLE_ROOT}/assets/hf-cache"
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1
export UV_CACHE_DIR="${BUNDLE_ROOT}/.uv-cache"
export PRISMATIC_LLAMA2_7B_REPO="${BUNDLE_ROOT}/assets/NousResearch-Llama-2-7b-hf"
export LIBERO_CONFIG_PATH="${BUNDLE_ROOT}/libero-config"
export MKL_INTERFACE_LAYER=GNU
export TOKENIZERS_PARALLELISM=false

EXPECTED_PROJECT_SHA="bb02b05d48f3eb1135a618f00489557b81faf4c6"
EXPECTED_LIBERO_SHA="8f1084e3132a39270c3a13ebe37270a43ece2a01"

verify_bundle() {
  [[ -x "${PYTHON}" ]] || {
    echo "Missing rollout environment: ${PYTHON}" >&2
    echo "Run: ${BUNDLE_ROOT}/prepare_a100_env.sh" >&2
    return 1
  }
  [[ -s "${CHECKPOINT}" ]] || { echo "Missing checkpoint: ${CHECKPOINT}" >&2; return 1; }
  [[ -s "${BUNDLE_ROOT}/model/C16-step5000/config.json" ]] || return 1
  [[ -s "${BUNDLE_ROOT}/model/C16-step5000/config.yaml" ]] || return 1
  [[ -s "${BUNDLE_ROOT}/model/C16-step5000/dataset_statistics.json" ]] || return 1
  [[ "$(git -C "${PROJECT_ROOT}" rev-parse HEAD)" == "${EXPECTED_PROJECT_SHA}" ]] || {
    echo "Unexpected SpatialMemoryVLA revision" >&2; return 1;
  }
  [[ "$(git -C "${LIBERO_ROOT}" rev-parse HEAD)" == "${EXPECTED_LIBERO_SHA}" ]] || {
    echo "Unexpected LIBERO revision" >&2; return 1;
  }
}

wait_for_server() {
  local pid="$1" port="$2" log="$3"
  for _ in $(seq 1 240); do
    if ! kill -0 "${pid}" 2>/dev/null; then
      echo "Deployment process ${pid} exited; tail of ${log}:" >&2
      tail -80 "${log}" >&2 || true
      return 1
    fi
    if curl --noproxy '*' -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 5
  done
  echo "Timed out waiting for deployment server on port ${port}" >&2
  tail -80 "${log}" >&2 || true
  return 1
}

start_deploy() {
  local gpu="$1" port="$2" log="$3"
  env CUDA_VISIBLE_DEVICES="${gpu}" \
    "${PYTHON}" "${PROJECT_ROOT}/deploy.py" \
      --saved_model_path "${CHECKPOINT}" \
      --unnorm_key libero_spatial_no_noops \
      --cfg_scale 1.5 \
      --num_ddim_steps 10 \
      --use_ddim \
      --use_bf16 \
      --inference_seed 7 \
      --port "${port}" \
      --action_chunking \
      --action_chunking_window 8 \
      >"${log}" 2>&1 &
  DEPLOY_PID=$!
  wait_for_server "${DEPLOY_PID}" "${port}" "${log}"
}

run_task() {
  local gpu="$1" port="$2" task="$3" trials="$4" condition="$5" output_dir="$6" note="$7"
  shift 7
  mkdir -p "${output_dir}"
  (
    cd "${PROJECT_ROOT}"
    env CUDA_VISIBLE_DEVICES="${gpu}" MUJOCO_GL=egl MUJOCO_EGL_DEVICE_ID="${gpu}" \
      "${PYTHON}" evaluation/libero/eval_libero.py \
        --model C16-step5000 \
        --task_suite_name libero_spatial \
        --num_trials_per_task "${trials}" \
        --spcial_task_id "${task}" \
        --seed 7 \
        --hard_case "${condition}" \
        --run_id_note "${note}" \
        --local_log_dir "${output_dir}" \
        --port "${port}" \
        "$@"
  ) >"${output_dir}/console.log" 2>&1
}
