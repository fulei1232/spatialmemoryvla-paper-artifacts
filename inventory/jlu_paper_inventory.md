# `/media/fulei/jlu` 论文材料盘点

生成时间（UTC）：2026-09-30T06:57:42.121375+00:00

## 结论

本目录包含两套完整的 A/B/C 消融实验：LIBERO-Spatial 和 LIBERO-10。每套均为 3 个模型 × 10 个任务 × 50 episodes，共 1,500 episodes；两套正式评估合计 3,000 episodes。训练侧有 6 个正式 10k-step run、2 个取消/中断 run、30 个 `.pt` 权重，以及逐 step JSONL 曲线。

本报告排除了 `.cache/huggingface` 和 `proxy.env`。数百万个由压缩包解出的 `.npy/.pkl/.png` 不逐文件列出；对应归档 ZIP、选择索引和统计文件均列入 TSV。

## 正式 rollout 总结果

| Suite | A | B | C | Episodes | Protocol |
|---|---:|---:|---:|---:|---|
| LIBERO-Spatial | 95.60% (478/500) | 96.20% (481/500) | **97.00% (485/500)** | 1,500 | 50 official initial states/task, seed 7, CFG 1.5, action chunk 8 |
| LIBERO-10 | 77.80% (389/500) | **79.40% (397/500)** | 77.60% (388/500) | 1,500 | matched seed/CFG/DDIM/action chunk/horizon/normalization |

精确逐任务 60 行结果见 `jlu_official_rollout_task_results.csv`。原始汇总分别在 `libero_abc_spatial_50_per_task_20260906/` 与 `libero10_abc_50_per_task_20260910/`。

## 模型 A/B/C 含义

| Label | Configuration |
|---|---|
| A | MemoryVLA baseline；`use_spatial_forcing=false`, `use_spatial_memory=false` |
| B | Spatial forcing；`use_spatial_forcing=true`, `use_spatial_memory=false` |
| C | Spatial forcing + spatial memory；两者均为 `true` |

共同训练设置：DiT-L action model，7-D action，future window 15，memory length/group size 16，retrieval layers 2，image augmentation，seed 42，FSDP full-shard，8 GPUs，global batch 256，per-device 32，LR 2e-5 constant，max 10,000 steps，checkpoint interval 2,000。

## 训练 run

| Run | Mix | Records / unique steps | Final loss | PT checkpoints |
|---|---|---:|---:|---:|
| `memoryvla_libero10_A--image_aug` | `libero_10_no_noops` | 10000 / 10000 | 0.019214 | 5 |
| `memoryvla_libero10_A--image_aug.cancelled-20260908_163922` | `libero_10_no_noops` | 0 / 0 | — | 0 |
| `memoryvla_libero10_A--image_aug.interrupted-20260908_163210` | `libero_10_no_noops` | 812 / 812 | 0.035190 | 0 |
| `memoryvla_libero_spatial_ab_A--image_aug` | `libero_spatial_no_noops` | 12000 / 10000 | 0.015686 | 5 |
| `memoryvla_spatial_forcing_libero_spatial_ab_B--image_aug` | `libero_spatial_no_noops` | 10000 / 10000 | 0.017051 | 5 |
| `spatial_forcing_libero10_B--image_aug` | `libero_10_no_noops` | 10000 / 10000 | 0.017191 | 5 |
| `spatial_memory_libero10_C--image_aug` | `libero_10_no_noops` | 10000 / 10000 | 0.023931 | 5 |
| `spatial_memory_libero_spatial_functional--image_aug` | `libero_spatial_no_noops` | 10000 / 10000 | 0.020954 | 5 |

注意：`memoryvla_libero_spatial_ab_A--image_aug` 有 12,000 条曲线记录但只有 10,000 个 unique steps，steps 1–2,000 重复；论文画曲线前应按 step 去重。取消 run 无曲线，中断 run 仅 812 steps。

完整数值（final action/spatial loss、最小记录 loss、平均 step time）见 `jlu_training_run_summary.tsv`。

## Rollout 原始材料

- `libero_abc_spatial_50_per_task_20260906`：总文件 1591；.mp4=1500，.log=55，.txt=30，.tsv=2，.pid=1，.csv=1，.md=1，.lock=1
- `libero10_abc_50_per_task_20260910`：总文件 1685；.mp4=1500，.jsonl=61，.log=55，.csv=33，.txt=30，.md=2，.tsv=2，.pid=1，.lock=1
- `libero_staged_20260906`：总文件 11；.log=4，.tsv=2，.pid=1，.lock=1，.txt=1，.jsonl=1，.mp4=1
- `libero_staged_20260906_v3`：总文件 431；.mp4=391，.log=18，.jsonl=8，.txt=8，.tsv=2，.pid=1，.csv=1，.md=1，.lock=1

LIBERO-10 正式结果每个 task 均有 `rollouts.csv`、`rollouts.jsonl`、`failure_trace.jsonl`、console log、文本日志和 50 个 MP4。LIBERO-Spatial 正式结果保留文本日志、console/deploy logs 和 1,500 个 MP4。

`libero_staged_20260906*` 是早期/不完整试验，不应与正式结果混用：v3 的 SUMMARY 写 0/10，但 task_results 实际含 A 的 task 0–1 且均为 0/50，状态文件也只记录两项。

## 额外 C 模型 step-10000 小评估

目录 `spatial_memory_libero_spatial_functional--image_aug/eval_step10000_C`：

- `between_the_plate_and_the_ramekin_valid`：10/10，100%。
- `next_to_the_plate_valid`：9/10，90%。
- `next_to_the_plate`：异常试跑，前三次均 JSON 解析异常并失败，第 4 episode 处中断；另有 3 个仅含 suite header 的空试跑日志。

## RoboMME

- 训练日志：2 个（原始 + restart）。
- 数据统计：`execution_samples=476857`, `total_samples=768897`。
- 数据选择索引：1,600 个 `features/**/kept_indices.json`。
- 子目标标注：memer/qwenvl 各有 grounded/simple JSONL，共 4 个。
- checkpoint：steps 2000/4000/6000/8000，单个约 11.88 GB；每个含 Orbax/OCDBT 参数、metadata 与 `norm_stats.json`。
- history config：`perceptual-framesamp-modul.yaml`。

## 云端备份覆盖核对

清单中的 15392 个相关文件里，5590 个在最终上传暂存区，9802 个未逐文件上传。

- 两套正式 rollout 的清单内材料全部在上传暂存区。
- 未逐文件上传的 9,800 个 RoboMME 文件由 8,200 个解压视频和 1,600 个 `kept_indices.json` 组成；它们是归档解压产物。已逐一检查 1,600 个 `episode_*.zip`：全部 ZIP 可读取，且每个都包含对应的 `kept_indices.json`。
- 另外未上传的是用户明确放弃的同一 optimizer 的 `part000` 与 `part001`；不影响 `.pt` 模型权重和 rollout 结果。

## 逐文件清单统计

共列出 15392 个论文/复现实验相关文件。

| Category | Files |
|---|---:|
| rollout_video | 11615 |
| source_archive | 1612 |
| data_selection_index | 1600 |
| log | 138 |
| robomme_checkpoint | 91 |
| documentation_or_text_result | 71 |
| rollout_episode_results | 60 |
| optimizer_part | 60 |
| rollout_failure_trace | 39 |
| model_weight | 30 |
| config_or_dataset_stats | 28 |
| status_or_manifest | 9 |
| result_summary | 8 |
| structured_data | 8 |
| training_hparams | 8 |
| training_curve | 6 |
| evaluation_artifact | 6 |
| checkpoint_metrics | 3 |

## 文件说明

- `jlu_paper_file_inventory.tsv`：逐文件路径、类别、字节数、mtime、是否仍在上传暂存区。
- `jlu_training_run_summary.tsv`：训练 run 的统一数值摘要。
- `jlu_official_rollout_task_results.csv`：两套正式评估的 60 条逐任务结果。

原始内容中的 `proxy.env` 可能含凭据，因此只确认其存在，不读取、不列入论文材料，也不上传。
