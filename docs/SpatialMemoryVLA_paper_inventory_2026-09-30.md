# SpatialMemoryVLA 论文资产盘点

盘点日期：2026-09-30

只读扫描范围：

- `/media/fulei/jlu/SpatialMemoryVLA/`
- `/media/SpatialMemoryVLA-c16/`

## 1. 总览

| 根目录 | 总大小 | 主要内容 |
|---|---:|---|
| `/media/fulei/jlu/SpatialMemoryVLA` | 4.3 TB | 源码、数据集、预训练模型、LIBERO/RoboMME 训练、checkpoint、评测、C16 rollout bundle、HF 上传副本 |
| `/media/SpatialMemoryVLA-c16` | 527 GB | 独立 C16 seed42 4-GPU 训练目录、数据与预训练资产 |

第一处顶层占用：`runs` 3.0 TB、`datasets` 717 GB、`hf_upload_robomme_ab_fast` 551 GB、`pretrained` 79 GB、`rollout_c16_step5000` 17 GB、`source` 8.8 GB、`hf-cache` 4.5 GB、`evaluations` 62 MB。

第二处顶层占用：`runs` 468 GB、`pretrained` 49 GB、`hf-cache` 8.8 GB、`data` 1.8 GB、训练 nohup 日志 11 MB。

第一处目录包含大量依赖、缓存和数据文件（约 18.3 万 `metadata`、17.9 万 `pkl`、6.9 万 `py`、1,778 个 `npz`、420 个 `jsonl`、416 个 `json`、413 个 `mp4`、333 个 `log`）。论文核心证据主要集中在 `runs/`、`evaluations/`、`rollout_c16_step5000/evaluations/` 和 `source/SpatialMemoryVLA/docs/experiments/`。

## 2. 最重要的论文结论与风险

### 已有、可引用的 500-step LIBERO temporal-occlusion 预实验

任务为 LIBERO-Spatial task 0/8，每任务 50 个官方 initial states，inference seed 7；每个模型/条件 100 episodes，配对完成，无 runtime exception。

| Fully black policy calls | B | C1 | C16 | C16-C1 | Exact McNemar p |
|---:|---:|---:|---:|---:|---:|
| 4 | 27% | 29% | 35% | +6 pp | 0.3616 |
| 8 | 29% | 20% | 38% | +18 pp | 0.007916 |
| 12 | 19% | 13% | 27% | +14 pp | 0.02882 |
| 16 | 3% | 4% | 6% | +2 pp | 0.7266 |

8-call 的 C16 vs C1 在四长度 Bonferroni 校正后仍显著（adjusted p=0.03166）。4--16 calls 梯形平均成功率：B 21.0%、C1 16.5%、C16 28.5%。但这是两任务、单训练 seed、500-step 的预实验；不能替代计划中的 5k、3-seed 正式实验。

### 5k old-recipe、seed42 的现有 rollout

checkpoint：

- B：`runs/libero_spatial_memory_resume/libero_spatial_occ_B_resume500_to5000_seed42/checkpoints/step-005000-epoch-03-loss=0.0529.pt`
- C16：`runs/libero_spatial_memory_resume/libero_spatial_occ_C_mem16_resume500_to5000_seed42/checkpoints/step-005000-epoch-03-loss=0.0576.pt`

统一评测设置：task 0/8；每任务 50 states；inference seed 7；BF16；DDIM 10；CFG 1.5；action chunk 8。

| 模型 | normal | full8 | full12 |
|---|---:|---:|---:|
| B 5k old-recipe | 99/100 = 99% | 49/100 = 49% | 16/100 = 16% |
| C16 5k old-recipe | 95/100 = 95% | 35/100 = 35% | 4/100 = 4% |

任务明细：

- B normal：task0 50/50，task8 49/50。
- B full8：task0 11/50，task8 38/50。
- B full12：task0 13/50，task8 3/50。
- C16 normal：task0 49/50，task8 46/50。
- C16 full8：task0 21/50，task8 14/50。
- C16 full12：task0 3/50，task8 1/50。

这一组 5k 单 seed 结果不支持“C16 优于 B”；而且 task-level 异质性很强，必须保留 per-task 明细。

### C16 5k inference-only 消融

同一 C16 old-recipe step5000 checkpoint、full8、task 0/8、每任务 50 states：

| 条件 | 总成功率 | task0 | task8 |
|---|---:|---:|---:|
| intact history | 35/100 = 35% | 42% | 28% |
| reset memory | 39/100 = 39% | 54% | 24% |
| wrong history（旧版） | 48/100 = 48% | 88% | 8% |
| wrong history（同 task 循环错配） | 52/100 = 52% | 76% | 28% |

这批结果目前不支持“有效历史导致收益”：reset 和 wrong-history 都没有低于 intact，wrong-history 反而更高；且 task0/task8 方向差异很大。论文中不能把它写成正向因果证据，应先审计 donor 构造、遮挡时序、memory 注入和 paired episode 对齐。

C16 reset-memory normal 已完成：96/100 = 96%（task0 49/50，task8 47/50）；与 intact normal 95% 基本相当，说明正常可见条件下该消融影响很小。

### C16 checkpoint screening

10 states/task 的初筛：step4000 和 step5000 均为 18/20=90%；step2000 80%；step1000 75%；step500 55%；step750 40%。随后 50 states/task 复核：step5000 95%（task0 98%、task8 92%），step4000 91%（task0 86%、task8 96%），最终选择 step5000。

### 当前最大论文缺口

论文计划要求 A/B/C1/C16 × seeds 42/43/44，共 12 个 matched 5k checkpoints。当前 LIBERO 资产中只有 seed42 的部分 5k 训练；没有发现 seed43/44 的 matched 5k 矩阵，也没有 A/C1 的对应 5k 正式主表。因此尚不满足三 seed 主结论要求。

`C16-seed42-normal-full8-full12-20260929T112619Z` 只有 4% 总成功率（normal 两任务均 12%，full8/full12 均 0），与后续 old-recipe 95% normal 结果严重冲突。这批结果应视为初始化/配方诊断资产，不能与 old-recipe 正式结果混表。

## 3. LIBERO 训练资产

表中 loss 为 JSONL 最后一条记录，不是平均值。`complete` 仅表示日志达到配置的 `max_steps`。

| Run（相对 `/media/fulei/jlu/SpatialMemoryVLA/runs`） | mode/mem | steps | 状态 | final total/action/spatial loss | checkpoint steps |
|---|---|---:|---|---|---|
| `libero_spatial_formal/libero_spatial_B_seed42_5k_formal--image_aug` | B spatial_forcing/16 | 979/5000 | partial | .007604/.004980/.005249 | 无 |
| `libero_spatial_formal/libero_spatial_B_seed42_5k_formal_restart1--image_aug` | B/16 | 0/5000 | no metrics | - | 无 |
| `libero_spatial_formal/libero_spatial_B_seed42_5k_formal_restart2--image_aug` | B/16 | 1262/5000 | partial | .013286/.010973/.004626 | 无 |
| `libero_spatial_formal/libero_spatial_B_seed42_5k_formal_smoke--image_aug` | B/16 | 8/8 | smoke complete | .252895/.017509/.470774 | 8 |
| `libero_spatial_memory/libero_spatial_occ_B_20step--image_aug` | B/1 | 0/20 | no metrics | - | 无 |
| `libero_spatial_memory/libero_spatial_occ_B_20step_buf1024--image_aug` | B/1 | 20/20 | complete | .602570/.265313/.674514 | 20 |
| `libero_spatial_memory/libero_spatial_occ_B_20step_det_noaug` | B/1 | 20/20 | complete | .347483/.038028/.618910 | 20 |
| `libero_spatial_memory/libero_spatial_occ_B_500step_det_noaug_rds1` | B/1 | 500/500 | complete | .080928/.069861/.022134 | 500 |
| `libero_spatial_memory/libero_spatial_occ_C_mem1_20step_buf1024--image_aug` | C1/1 | 20/20 | complete | .374162/.035609/.677106 | 20 |
| `libero_spatial_memory/libero_spatial_occ_C_mem1_20step_det_noaug` | C1/1 | 20/20 | complete | .373136/.040914/.664444 | 20 |
| `libero_spatial_memory/libero_spatial_occ_C_mem1_500step_det_noaug_rds1` | C1/1 | 500/500 | complete | .087584/.073562/.028043 | 500 |
| `libero_spatial_memory/libero_spatial_occ_C_mem16_20step_buf1024--image_aug` | C16/16 | 20/20 | complete | .377719/.043553/.668332 | 20 |
| `libero_spatial_memory/libero_spatial_occ_C_mem16_20step_det_noaug` | C16/16 | 20/20 | complete | .374153/.041928/.664450 | 20 |
| `libero_spatial_memory/libero_spatial_occ_C_mem16_500step_det_noaug_rds1` | C16/16 | 500/500 | complete | .086034/.071975/.028119 | 500 |
| `libero_spatial_memory_resume/libero_spatial_occ_B_resume500_to5000_seed42` | B/1 | 5000/5000 | complete | .052906/.047922/.009969 | 750,1000,2000,4000,5000 |
| `libero_spatial_memory_resume/libero_spatial_occ_C_mem16_resume500_to5000_seed42` | C16/16 | 5000/5000 | complete | .057575/.052111/.010928 | 750,1000,2000,4000,5000 |

独立 C16 目录 `/media/SpatialMemoryVLA-c16/runs/libero_spatial/`：

| Run | steps | 状态 | final total/action/spatial loss | checkpoint steps |
|---|---:|---|---|---|
| `spatial_memory_libero_spatial_C16_seed42_4gpu_5k--image_aug` | 183/5000 | partial | .044265/.037686/.013158 | 无 |
| `spatial_memory_libero_spatial_C16_seed42_4gpu_5k_restart1--image_aug` | 5000/5000 | complete | .006827/.005396/.002861 | 2000,4000,5000 |
| `...smoke8`、`...smoke8_r1`、`...smoke8_r2` | 0/8 | failed/no metrics | - | 无 |
| `...smoke8_r3` | 8/8 | smoke complete | .240004/.018829/.442350 | 8 |
| `...smoke_resume` | 9/9 | resume smoke complete | .220434/.019061/.402745 | 9 |

独立 C16 正式配置：seed 42、4 GPUs、global batch 256、per-device batch 8、LR 2e-5、FSDP full-shard、BF16、5k steps、mem length 16、group size 16、spatial forcing + spatial memory、image augmentation。step5000 `.pt` 约 33.56 GB，optimizer 约 66.90 GB。

## 4. RoboMME 训练资产

### 4-GPU fast A/B/C（已完整 5k）

| Run | steps | final total/action/spatial loss | checkpoints |
|---|---:|---|---|
| `robomme/memoryvla_robomme_A_4gpu_5k_fast--image_aug` | 5000 | .014218/.014218/0 | 1k,2k,3k,4k,5k |
| `robomme/spatial_forcing_robomme_B_4gpu_5k_fast--image_aug` | 5000 | .014952/.013616/.002671 | 1k,2k,3k,4k,5k |
| `robomme/spatial_memory_robomme_C_4gpu_5k_fast--image_aug` | 5000 | .016509/.014533/.003952 | 1k,2k,3k,4k,5k |

这些资产另有完整 HF 上传整理副本：`hf_upload_robomme_ab_fast/A|B|C/`，总计约 551 GB，包含 config、dataset statistics、训练 JSONL、checkpoint event 和全部 checkpoint/optimizer。

未完成的旧 RoboMME 训练：A 10k 只到 step207；A 5k 只到 step4；A gb64 只到 step469。

### corrected 8-GPU A/B/C（已完整 5k）

共同设置：seed42、8 GPUs、global/per-device batch 256/8、LR 2e-5、BF16、FSDP full-shard、action dim/horizon 8/16、memory/group length 16/16。

| Group | final action loss | spatial loss | weighted ratio | grad norm | total loss | last-100 mean total loss |
|---|---:|---:|---:|---:|---:|---:|
| A | .013010 | 0 | 0 | .406501 | .013010 | .012438 |
| B | .013743 | .001386 | .050441 | .364619 | .014436 | .014077 |
| C | .013346 | .001758 | .065874 | .460708 | .014225 | .016026 |

所有三个 JSONL 均恰好 5000 条。这些指标只证明训练完成和数值稳定，RoboMME matched downstream policy evaluation 仍未完成。另有 A historyfix 5k stream run，final total loss .006215；以及只跑 45/10000 steps 的 A 10k correct 失败/中断 run。

### RoboMME memory-curriculum 500-step

- C1：final total/action/spatial `.029301/.026710/.005181`，checkpoint 250/500。
- C16：final total/action/spatial `.029548/.026946/.005204`，checkpoint 250/500。
- 离线评测各 3,200 samples：
  - C1 normal action loss .042879，occlusion .042891，proxy success 98.25%，paired delta `1.276e-5`。
  - C16 normal action loss .042861，occlusion .042876，proxy success 98.50%，paired delta `1.554e-5`。

注意：`offline_success_proxy` 是 action-loss threshold，不是 simulator success，不能写成真实任务成功率。

## 5. 全部评测目录状态

### `/media/fulei/jlu/SpatialMemoryVLA/evaluations`

| 目录 | summary | rollout rows | 用途/状态 |
|---|---:|---:|---|
| `libero_memory_occlusion_smoke` | 无 | 8 | smoke |
| `libero_memory_occlusion_smoke_deterministic` | 有 | 12 | smoke；memory normal 4/4、memory occlusion 1/4、reset occlusion 2/4 |
| `libero_memory_occlusion_smoke_strong` | 无 | 12 | smoke |
| `libero_spatial_occ_b_c1_c16_500step_formal` | 有 | 600 | 4-call formal，B/C1/C16 × normal/occlusion |
| `libero_spatial_occ_b_c1_c16_500step_long16` | 有 | 300 | 16-call formal |
| `libero_spatial_occ_b_c1_c16_500step_pilot` | 无 | 4 | pilot |
| `libero_spatial_occ_b_c1_c16_500step_pilot_v2` | 有 | 12 | 2 episodes/model/condition pilot |
| `libero_spatial_occ_b_c1_c16_length_curve` | 无 | 0 | 聚合/占位目录 |
| `libero_spatial_occ_b_c1_c16_sweep_8_12` | 2 个 | 600 | 8/12-call formal |
| `libero_spatial_relocation_b_c1_c16_smoke` | 无 | 30 | relocation smoke v1 |
| `...smoke_v2` | 无 | 30 | relocation smoke v2 |
| `...smoke_v3` | 无 | 30 | relocation smoke v3；文档汇总 B 30%、C1 20%、C16 40% |
| `robomme_memory_500step` | 有 | 0 simulator rollout | 3,200-sample offline loss proxy |
| `robomme_memory_smoke` | 有 | 0 simulator rollout | 16-sample smoke |

Relocation 数据：从 52 个有效候选中选出 50 个成功 C16 episodes，共 6,120 transitions、约 973 MB compressed NPZ；seed 7/17/27/37；每 episode 验证恰有一次 relocation flag。当前只有 smoke，文档明确说样本不足以做模型比较。

### `/media/fulei/jlu/SpatialMemoryVLA/rollout_c16_step5000/evaluations`

| 目录 | summary | rollout rows | 状态 |
|---|---:|---:|---|
| `B-oldrecipe-step5000-full8-full12-20260930T052829Z` | 有 | 200 | 正式完成 |
| `B-oldrecipe-step5000-normal-20260930T042753Z` | 无 | 10 | 中断/试跑 |
| `B-oldrecipe-step5000-normal-20260930T043435Z` | 有 | 100 | 正式完成 |
| `C16-oldrecipe-4k-vs-5k-normal50-20260930T021230Z` | 有 | 200 | checkpoint 复核 |
| `C16-oldrecipe-checkpoint-screen-20260930T015536Z` | 有 | 120 | checkpoint 初筛 |
| `C16-oldrecipe-step5000-full8-ablations-50states-20260930T033304Z` | 有 | 202 | 正式消融；另含 donor rollout |
| `...ablations-smoke`、`...v2`、`...v3` | 各有 | 各 6 | smoke |
| `C16-oldrecipe-step5000-full8-wrong-history-shuffle-50states-20260930T043825Z` | 有 | 200 | 正式错配历史；含 donor rollout |
| `...wrong-history-shuffle-smoke` | 有 | 8 | smoke |
| `C16-oldrecipe-step5000-normal-full8-full12-20260930T023434Z` | 有 | 300 | 正式完成 |
| `C16-oldrecipe-step5000-reset-memory-normal-20260930T061157Z` | 有 | 100 | 正式完成，96% |
| `C16-seed42-normal-full8-full12-20260929T101756Z` | 无 | 5 | 中断/诊断 |
| `C16-seed42-normal-full8-full12-20260929T112619Z` | 有 | 300 | 完成但表现异常，仅 4% 总成功率 |
| `diagnostic-c16-initialization` | 无 | 10 | 初始化诊断 |
| `diagnostic-c16-step2k-step4k` | 无 | 20 | checkpoint 诊断 |
| `smoke-20260929T100014Z` | 有 | 12 | 0% smoke |
| `smoke-gpu1-egl-fix` | 有 | 6 | 0% smoke |

每个正式 task 目录通常包含：`rollouts.jsonl`（逐 episode 元数据）、`rollouts.csv`、LIBERO 文本日志、`failure_trace.jsonl`、worker log；父目录含 server log、`checkpoint.txt`、`protocol.txt` 和 `summary.json`。

## 6. 复现与版本信息

源码：`/media/fulei/jlu/SpatialMemoryVLA/source/SpatialMemoryVLA`

- Git commit：`bb02b05d48f3eb1135a618f00489557b81faf4c6`
- rollout bundle 固定的 LIBERO commit：`8f1084e3132a39270c3a13ebe37270a43ece2a01`
- 工作树并非 clean：修改了 `deploy.py`、`evaluation/libero/eval_libero.py`、`resized_image.png`、`training/strategies/base_strategy.py`；新增 `docs/experiments/paper_experiment_plan_20260928.md`、`script/train/libero/train_libero_spatial_formal_b_seed42.sh`。
- C16 bundle checkpoint：33,562,696,646 bytes；seed42；step5000。
- bundle manifest 还固定了 Llama-2、DINOv2、SigLIP 和 LIBERO 资产 revision。

关键复现目录/文件：

- `reproduction/B_resume500/`：README、launch script、step5000 dry-run resolved command。
- `reproduction/C16_resume500/`：README、launch script、step1000/5000 dry-run。
- `reproduction/B_seed42/`：config、launch command、resolved config。
- `rollout_c16_step5000/README.md`、`manifest.json`、`common.sh`、`summarize_results.py`、正式/消融启动脚本。
- `source/SpatialMemoryVLA/docs/experiments/libero_temporal_occlusion_20260917.md`。
- `source/SpatialMemoryVLA/docs/experiments/libero_dynamic_relocation_20260918.md`。
- `source/SpatialMemoryVLA/docs/experiments/robomme_abc_8gpu_20260918.md`。
- `source/SpatialMemoryVLA/docs/experiments/paper_experiment_plan_20260928.md`。

## 7. 日志和异常 run

顶层训练日志：

- `c16-resume500-to5000.nohup.log`：约 1.5 MB；训练达到 5000，尾部为 NCCL communicator 正常 abort/关闭信息。
- `b-correct-resume500-to5000.nohup.log`：约 1.5 MB；达到 5000，尾部同样为 NCCL 关闭信息。
- `/media/SpatialMemoryVLA-c16/relaunch-c16-restart1.nohup.log`：约 11 MB；对应完整 C16 5k restart1。
- `b-seed42-5k-restart1.nohup.log`：约 96 KB；exit code 1，失败。
- `b-seed42-5k-restart2.nohup.log`：约 2.6 MB；收到 signal 15，在 step1262 中断。
- `b-step5000-normal.nohup.log`：空文件。

PID 文件和 `*-latest.txt` 只是启动/定位辅助信息，不能当实验完成证据；应以 JSONL 步数、checkpoint 存在、rollout 行数及 summary protocol complete 为准。

## 8. 论文使用建议

1. 可直接作为现有预实验写入：500-step 两任务 temporal-occlusion length curve，但必须标注单 seed/两任务/预实验。
2. 可作为负结果或诊断写入 appendix：5k old-recipe 单 seed 的 B/C16 比较、reset/wrong-history 消融；当前结果不支持预期记忆因果结论。
3. RoboMME 8-GPU A/B/C 的训练健康表可用，但不能替代 downstream policy performance。
4. 正式主结论仍需补：LIBERO A/B/C1/C16 的 seed43/44（以及缺失的 seed42 A/C1）matched 5k checkpoint 和同一 manifest 下的 rollout。
5. 所有论文表格必须区分：500-step vs 5k、old-recipe vs 独立 C16 group-training、simulator success vs offline loss proxy、smoke/pilot vs formal。
6. 在提交前保存 clean commit 或 patch、共同 checkpoint/data manifest hash、每 seed config 和 task/state manifest；当前仅文件名不足以证明完全 matched。
