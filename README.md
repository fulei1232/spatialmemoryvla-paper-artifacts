# SpatialMemoryVLA paper artifacts

Private research-artifact repository assembled on 2026-09-30 from:

- `/media/fulei/jlu/SpatialMemoryVLA/`
- `/media/SpatialMemoryVLA-c16/`

The repository contains paper-relevant, text-based evidence only:

- resolved training configurations and dataset statistics;
- training JSONL metrics, checkpoint-event records, diagnostics CSVs, and launcher/nohup logs;
- evaluation summaries and per-episode rollout CSV/JSONL records;
- failure traces, worker/server logs, protocols, and checkpoint path records;
- reproduction scripts, rollout aggregation scripts, and experiment notes;
- a paper-focused inventory at `docs/SpatialMemoryVLA_paper_inventory_2026-09-30.md`.

Intentionally excluded because of size or irrelevance to paper statistics:

- model checkpoints and optimizer states;
- pretrained weights, datasets, Hugging Face caches, and virtual environments;
- generated videos and image assets;
- vendored source trees and compiled dependencies.

## Important interpretation notes

- The 500-step LIBERO temporal-occlusion results are two-task, one-training-seed preliminary experiments.
- Existing 5k old-recipe LIBERO results are also one-seed results and do not satisfy the planned three-seed matched protocol.
- RoboMME `offline_success_proxy` is an action-loss threshold, not simulator task success.
- Smoke, pilot, interrupted, diagnostic, 500-step, and 5k experiments must not be pooled.
- The source checkout used by the rollout bundle was based on SpatialMemoryVLA commit `bb02b05d48f3eb1135a618f00489557b81faf4c6`, with LIBERO commit `8f1084e3132a39270c3a13ebe37270a43ece2a01`; the working tree also contained uncommitted experiment changes recorded in the inventory.

## Layout

- `docs/`: inventory and experiment write-ups.
- `artifacts/main/runs/`: training configurations, metrics, diagnostics, and logs from the main tree.
- `artifacts/main/evaluations/`: 500-step LIBERO and RoboMME evaluation evidence.
- `artifacts/main/rollout_c16_step5000/`: 5k rollout results and reproduction/aggregation scripts.
- `artifacts/main/reproduction/`: B/C16 resume reproduction material.
- `artifacts/c16/`: independent C16 seed42 training configurations, metrics, logs, and asset manifest.

Absolute paths embedded in historical configs and logs refer to the original shared filesystem and are preserved for provenance.
