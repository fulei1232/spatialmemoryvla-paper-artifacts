# SpatialMemoryVLA 论文补实验计划

日期：2026-09-28

## 1. 目标与范围

本轮不再修改网络结构，目标是在严格 matched 的条件下补齐论文核心证据：

1. 比较 A（MemoryVLA）、B（Spatial Forcing）和 C（SpatialMemoryVLA）的整体性能；
2. 重点验证 C 的长时记忆（memory 16）相对短时记忆（memory 1）在视觉遮挡下的收益；
3. 用不重新训练的 memory reset / wrong-history 消融确认收益确实来自有效历史；
4. 用 dynamic relocation 检验模型能否覆盖 stale memory，并分析 gate 随时间的响应。

Counterfactual 实验和 RoboMME 大规模扩展暂不进入本轮关键路径。

## 2. 统一训练协议

除明确写出的模型差异外，所有训练必须使用相同的初始化、训练数据、数据顺序规则和超参数。

| 项目 | 固定设置 |
| --- | --- |
| 初始化 | 同一 pretrained checkpoint |
| Precision | BF16 |
| Distributed strategy | FSDP full-shard |
| Per-GPU batch size | 8 |
| Gradient accumulation | 8 |
| GPU 数量 | 4 × A100 |
| Global batch size | 256 |
| Learning rate | 2e-5 |
| Optimizer steps | 5,000 |
| Action dimension | 8 |
| Action horizon | 16 |
| Training seeds | 42、43、44 |

必须将最终解析后的配置、初始化 checkpoint hash、数据 manifest/hash、代码 commit、每个 seed 的日志与 checkpoint 一并保存。若模型特有参数不同，只允许保留定义模型所必需的差异，并在结果表中显式列出。

## 3. 模型与 checkpoint 矩阵

| 标签 | 模型 | 关键设置 | Seeds | 训练步数 |
| --- | --- | --- | --- | ---: |
| A | MemoryVLA | baseline memory mechanism | 42/43/44 | 5k |
| B | Spatial Forcing | spatial forcing | 42/43/44 | 5k |
| C1 | SpatialMemoryVLA | memory length = 1 | 42/43/44 | 5k |
| C16 | SpatialMemoryVLA | memory length = 16 | 42/43/44 | 5k |

论文 A/B/C 主比较中的 C 固定指 C16。因此实际需要的唯一 checkpoint 为 A、B、C1、C16 各 3 个，共 12 个；不要为 C 和 C16 重复训练。

每次训练完成后检查：达到 5,000 optimizer steps、无 NaN/Inf、global batch 确为 256、checkpoint 可加载，并汇总 loss、gradient norm、吞吐和峰值显存。训练 loss 只用于健康检查，不作为策略性能结论。

## 4. 统一评测协议

- 数据集：LIBERO-Spatial。
- 任务数：至少 2 个，资源允许时固定为 5 个；正式运行前冻结 task ID 列表。
- 样本数：每个 task、每个 training seed 使用 50 个 initial states。
- 配对原则：所有模型、消融和遮挡长度必须复用完全相同的 task/state manifest；环境与推理随机性也应固定或显式记录。
- 场景：normal + temporal occlusion。
- 遮挡长度：4、8、12、16 个 policy calls。
- 除遮挡干预外，环境、最大 episode 长度、action chunking、成功判据和 observation preprocessing 全部一致。
- 每个 rollout 保存逐 episode 结果和元数据，包括 model、training seed、task、state ID、condition、occlusion length、成功与否、episode length 和异常信息。

建议将 task/state 清单保存为版本化 manifest，所有脚本只读取该 manifest，避免不同模型间样本漂移。已有两任务、单训练 seed、500-step 结果仅作为 pipeline 依据和预实验，不替代本计划的 5k、三 seed 正式结果。

## 5. 实验阶段与优先级

### P0：运行前审计

1. 冻结共同初始化、训练数据 manifest、3 个 seed、LIBERO task/state manifest；
2. 核对 4-GPU 配置对应 `8 × 8 × 4 = 256` 的 global batch；
3. 用短 smoke run 验证 FSDP full-shard、BF16、保存/恢复和 rollout 元数据；
4. 确认 C 主模型就是 C16，避免重复训练或结果命名混淆。

### P1：B / C1 / C16 三 seed occlusion（最高优先级）

训练 B、C1、C16 的 5k matched checkpoints，并对 42/43/44 三个 seed 执行 4/8/12/16 calls 遮挡评测。该阶段直接回答长历史是否在遮挡中优于短历史，并以 C16 vs C1 为主要对比、C16 vs B 为辅助对比。

若只选 2 个任务，该阶段为 `3 models × 3 seeds × 2 tasks × 50 states × 4 lengths = 3,600` 次 rollout；若选 5 个任务则为 9,000 次。

### P2：A / B / C 正常与遮挡主比较

补齐 A 的 3 个 5k checkpoints，将 A、B、C16 放入统一主表。评测 normal 以及 4/8/12/16 calls occlusion，沿用 P1 的同一批 initial states。B 和 C16 已完成且配置完全一致的 rollout 应直接复用，不重复计算。

主表至少报告每个模型在 normal 和各遮挡长度下的成功率、跨 seed 均值/方差（或 95% CI），以及相对 normal 的性能下降。另绘制 success rate–occlusion length 曲线。

### P3：C16 不训练的记忆因果消融

对每个 C16 5k checkpoint 做以下 inference-only 条件：

1. **Intact history**：标准 C16，作为对照；
2. **Reset memory**：每次 policy call 前清空 memory；
3. **Wrong history**：用不属于当前 episode/state 的历史替换正确历史。

三种条件必须复用相同 C16 checkpoint、initial states、遮挡 schedule 和推理设置，不得重新训练。Wrong history 必须使用确定性映射（例如同 task 内按 state ID 循环错配），排除抽样噪声，并确保不会意外取到当前 episode 的历史。主要比较 intact vs reset、intact vs wrong history。

### P4：Dynamic relocation

#### P4a：small-overfit 验证

- 数据：已有 50 个成功 episodes / 6,120 transitions；
- 模型：C16；
- 物体位移：固定 0.10 m；
- 目的：先确认训练和干预链路有效，且模型在物体移动后能够覆盖 stale memory；
- 验收：训练集/固定验证 rollout 明显学会 relocation，而不只是 intervention 前行为正常；同时确认位姿安全检查、observation refresh 和 relocation flag 均正确。

small-overfit 未通过时，只排查数据、干预时序、memory 更新和训练链路，不直接扩大正式训练。

#### P4b：正式 fine-tune 与评测

在 P4a 通过后执行正式 C16 fine-tune。评测至少覆盖 50 states/task/seed，并保持模型间相同 initial states。报告 relocation 成功率、移动前后成功/失败分解，以及移动发生后的恢复时间。

同时逐 policy call 记录 gate，至少保存：timestep、是否处于 relocation 前/后、gate 原始值及聚合值、task/state/seed、最终成功与否。结果中绘制以 relocation 时刻对齐的 gate–timestep 曲线，并分别展示成功与失败轨迹，以检验 gate 是否在环境变化后降低旧记忆权重并随后恢复。

## 6. 统计与结果呈现

- 最小报告单位是 task × training seed × condition，不只报告合并后的单一百分比。
- 对相同 initial state 的模型比较使用 paired 分析；成功率差异可使用 exact McNemar test，并报告绝对百分点差。
- 汇总结果报告三 seed 均值与不确定性；同时保留 per-task、per-seed 明细，防止某一任务或 seed 主导结论。
- 多个遮挡长度上的显著性检验应做多重比较校正，并明确主要检验是 C16 vs C1。
- 除 success rate 外，记录 runtime exception、有效 episode 数和缺失 rollout；失败/缺失不得静默丢弃。

论文建议输出：

1. A/B/C normal + occlusion 主结果表；
2. B/C1/C16 的遮挡长度曲线；
3. C16 intact/reset/wrong-history 消融表；
4. relocation 主结果表与 gate–timestep 曲线；
5. appendix 中的 per-task/per-seed 明细和训练健康指标。

## 7. 执行顺序与停止规则

严格按以下顺序占用算力：

1. **B/C1/C16 三 seed occlusion**；
2. **A/B/C normal + occlusion rollout**；
3. **C16 reset memory / wrong-history**；
4. **relocation small-overfit，再做正式 fine-tune 与评测**。

若算力不足，优先保证更少任务上的完整三 seed、50 states 和全遮挡长度，不用单 seed 或更少 states 换取更多任务。任何阶段如发现配置不 matched、state manifest 不一致或 checkpoint 不完整，应停止下游评测并先修复审计问题。

## 8. 完成标准

- 12 个 matched 5k checkpoints 均通过训练健康检查；
- 核心 B/C1/C16 遮挡实验覆盖 3 seeds、全部 4 个遮挡长度及冻结的 50 states/task；
- A/B/C 主比较同时包含 normal 和 occlusion；
- reset/wrong-history 使用同一 C16 checkpoint 完成，无额外训练；
- relocation small-overfit 先通过，再完成正式 fine-tune 和至少 50 states/task/seed 的评测；
- gate timestep 日志、统计表、曲线、原始 rollout metadata 和复现实验配置齐全；
- 论文结论只基于正式 matched 实验，预实验和 smoke 结果清楚标注。

## 9. 现有资产

- Temporal occlusion 预实验：`docs/experiments/libero_temporal_occlusion_20260917.md`
- Relocation pipeline、smoke 和 50 episodes / 6,120 transitions 数据说明：`docs/experiments/libero_dynamic_relocation_20260918.md`
- 现有训练入口：`script/train/libero/train_libero_spatial_occlusion_b_c1_c16.sh`
- 现有遮挡评测入口：
  - `script/eval/libero/run_b_c1_c16_500step_formal.sh`
  - `script/eval/libero/run_b_c1_c16_occlusion_sweep_8_12.sh`
  - `script/eval/libero/run_b_c1_c16_500step_long_occlusion.sh`
- Relocation small-overfit 入口：`script/train/libero/train_libero_relocation_c16_overfit.sh`

这些脚本可作为实现起点，但正式运行前必须按本计划重新审计 5k steps、4-GPU global batch、三 seed、统一 manifest 和输出命名，不能仅凭文件名假定配置正确。
