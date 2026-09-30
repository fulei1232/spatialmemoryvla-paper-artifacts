#!/usr/bin/env bash

set -Eeuo pipefail

storage_root="${SPATIALMEMORYVLA_STORAGE_ROOT:-/media/fulei/jlu/SpatialMemoryVLA}"
project_root="${storage_root}/source/SpatialMemoryVLA"
source_run="${storage_root}/runs/libero_spatial_memory/libero_spatial_occ_B_500step_det_noaug_rds1"
checkpoint="${source_run}/checkpoints/step-000500-epoch-00-loss=0.0809.pt"
optimizer="${source_run}/checkpoints/step-000500-epoch-00-loss=0.0809.optimizer"
data_root="${storage_root}/datasets/libero-rlds"
vggt="${storage_root}/pretrained/VGGT-1B/model.pt"
target_max_steps="${TARGET_MAX_STEPS:-5000}"
save_interval="${SAVE_INTERVAL:-5000}"
run_id="${RUN_ID:-libero_spatial_occ_B_resume500_to${target_max_steps}_seed42}"
run_root="${RUN_ROOT_DIR:-${storage_root}/runs/libero_spatial_memory_resume}"
run_dir="${run_root}/${run_id}"

[[ "${target_max_steps}" =~ ^[0-9]+$ && "${target_max_steps}" -gt 500 ]] || exit 2
[[ "$(git -C "${project_root}" rev-parse HEAD)" == "bb02b05d48f3eb1135a618f00489557b81faf4c6" ]] || exit 3
[[ -s "${checkpoint}" && "$(stat -c %s "${checkpoint}")" == 32096021702 ]] || exit 4
[[ -s "${optimizer}" && "$(stat -c %s "${optimizer}")" == 7356262530 ]] || exit 5
[[ ! -e "${run_dir}" ]] || { echo "Refusing to reuse existing run directory: ${run_dir}" >&2; exit 6; }
dataset_dir="${data_root}/libero_spatial_no_noops/1.0.0"
[[ "$(find "${dataset_dir}" -maxdepth 1 -type f -name '*.tfrecord-*' | wc -l)" -eq 16 ]] || exit 7
[[ -s "${vggt}" ]] || exit 8

cd "${project_root}"
export HF_HOME="${HF_HOME:-${storage_root}/hf-cache}"
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1
export SPATIALMEMORYVLA_SAVE_STEPS="${CHECKPOINT_STEPS:-750,1000,2000,4000,5000}"
export PRISMATIC_LLAMA2_7B_REPO="${LLAMA2_7B_REPO:-${storage_root}/pretrained/NousResearch-Llama-2-7b-hf}"
export LIBERO_CONFIG_PATH="${project_root}/.libero"

args=(
  --pretrained_checkpoint "${checkpoint}"
  --is_resume True --resume_step 500 --resume_epoch 0
  --experiment_mode spatial_forcing
  --vla.type prism-dinosiglip-224px+oxe+diffusion
  --vla.data_mix libero_spatial_no_noops
  --vla.expected_world_size 4
  --vla.per_device_batch_size 8 --vla.global_batch_size 32
  --vla.learning_rate 2e-5 --vla.weight_decay 0.0 --vla.max_grad_norm 1.0
  --vla.lr_scheduler_type constant --vla.warmup_ratio 0.0
  --vla.train_strategy fsdp-full-shard
  --vla.enable_mixed_precision_training True --vla.reduce_in_full_precision True
  --vla.max_steps "${target_max_steps}"
  --vla.freeze_llm_backbone True --vla.freeze_vision_backbone True
  --vla.unfreeze_last_llm_layer True --vla.enable_gradient_checkpointing False
  --vla.shuffle_buffer_size 1024
  --data_root_dir "${data_root}" --run_root_dir "${run_root}" --run_id "${run_id}"
  --save_interval "${save_interval}" --seed 42 --image_aug False
  --future_action_window_size 15 --action_dim 7 --action_model_type DiT-L
  --repeated_diffusion_steps 1 --dataloader_type stream --group_size 16 --mem_length 1
  --memory_curriculum_enabled True --memory_curriculum_type occlusion
  --occlusion_probability 0.5 --occlusion_start_ratio 0.3
  --occlusion_duration_ratio 0.2 --occlusion_recovery_ratio 0.75 --occlusion_strength full
  --gate_diagnostics_path "${run_dir}/diagnostics/gate.csv"
  --use_spatial_forcing True --use_spatial_memory False
  --spatial_align_layer 24 --spatial_align_coeff 0.5
  --spatial_teacher_path "${vggt}" --spatial_teacher_feature_layer -1
  --spatial_debug_asserts True --trackers jsonl
)

echo "B resume: step 500 -> ${target_max_steps}"
echo "model: ${checkpoint}"
echo "optimizer: ${optimizer}"
echo "run: ${run_dir}"
echo "checkpoint steps: ${SPATIALMEMORYVLA_SAVE_STEPS}"
printf 'torchrun arguments:'; printf ' %q' "${args[@]}"; printf '\n'
[[ "${DRY_RUN:-0}" == 1 ]] && exit 0

"${project_root}/.venv/bin/python" -c 'import torch; assert torch.cuda.is_available() and torch.cuda.device_count() == 4; print([torch.cuda.get_device_name(i) for i in range(4)])'
exec env CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0,1,2,3}" \
  "${project_root}/.venv/bin/torchrun" --nproc_per_node=4 train.py "${args[@]}"
