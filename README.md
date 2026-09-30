# SpatialMemoryVLA paper artifacts

Paper-facing experiment artifacts collected from `/media/fulei/jlu` on 2026-09-30.

## Main results

| Suite | A | B | C | Episodes |
|---|---:|---:|---:|---:|
| LIBERO-Spatial | 95.60% (478/500) | 96.20% (481/500) | **97.00% (485/500)** | 1,500 |
| LIBERO-10 | 77.80% (389/500) | **79.40% (397/500)** | 77.60% (388/500) | 1,500 |

- A: MemoryVLA baseline.
- B: spatial forcing.
- C: spatial forcing plus spatial memory.

## Repository layout

- `inventory/jlu_paper_inventory.md`: human-readable inventory and caveats.
- `inventory/jlu_official_rollout_task_results.csv`: 60 official per-task results.
- `inventory/jlu_training_run_summary.tsv`: normalized training-run statistics.
- `inventory/jlu_paper_file_inventory.tsv`: full local artifact index and backup coverage.
- `artifacts/jlu/`: original configs, training curves, logs, rollout tables, failure traces, summaries, and RoboMME statistics, preserving their source-relative paths.

## Important caveats

- The two `libero_staged_20260906*` trees are incomplete early runs and are not official paper results.
- `memoryvla_libero_spatial_ab_A--image_aug` contains 12,000 metric records but 10,000 unique steps; steps 1–2,000 are duplicated and should be deduplicated before plotting.
- Model weights, optimizer state, videos, archive ZIPs, extracted dataset files, credentials, upload caches, and `proxy.env` are intentionally excluded.
- Configuration files refer to `.hf_token` by name only; no token file or token value is included.

The authoritative provenance and detailed interpretation are in `inventory/jlu_paper_inventory.md`.
