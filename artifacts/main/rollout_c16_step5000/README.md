# C16 step-5000 LIBERO-Spatial rollout bundle

This directory is the A100 rollout entry point. Everything referenced by the
scripts is on the shared `/media` filesystem. Python environments are not
copied between servers; `.venv-rollout` is created on the A100 host from the
repository's frozen `uv.lock`.

Pinned inputs:

- SpatialMemoryVLA: `bb02b05d48f3eb1135a618f00489557b81faf4c6`
- LIBERO: `8f1084e3132a39270c3a13ebe37270a43ece2a01`
- model: C16 seed 42, step 5000
- checkpoint: `model/C16-step5000/checkpoints/step-005000-epoch-24-loss=0.0068.pt`
- protocol: LIBERO-Spatial, official initial states, seed 7, BF16, DDIM 10,
  CFG 1.5, action chunk 8, standard C16 memory (no per-step reset)

On the 4xA100 server:

```bash
cd /media/fulei/jlu/SpatialMemoryVLA/rollout_c16_step5000
./prepare_a100_env.sh
./smoke_a100.sh
./run_c16_formal_3conditions.sh
```

Alternatively, run the guarded end-to-end sequence with
`./start_c16_pipeline.sh`; the formal run starts only if environment setup and
smoke both exit successfully.

Monitor from another shell with `./status.sh` (or pass a specific evaluation
directory as its first argument).

The smoke evaluates tasks 0 and 8 under normal visibility, eight fully black
policy observations, and twelve fully black policy observations, using two
official states per task and condition. The formal run follows the existing
repository sweep: tasks 0 and 8, fifty official states each, all three
conditions (300 matched episodes). Four independent inference replicas use all
four A100s. The summarizer refuses success unless all three conditions contain
the exact same episode IDs. Results, logs, JSONL, CSV and `summary.json` are
written under `evaluations/`; formal videos are disabled to limit shared-I/O.

Do not add `--reset_memory_every_step` for the normal C16 evaluation: that flag
is a memory-ablation mode. The VGGT teacher, optimizer state, and RLDS training
dataset are intentionally absent because rollout does not load them.
