# C16 continuation from step 500

The source checkpoint is the old C16 run that achieved 72% normal rollout
success. The launcher restores both the model and its sibling `.optimizer`, and
keeps the original recipe: frozen vision and LLM backbones, last LLM layer
trainable, no image augmentation, stream loader, global batch 32, repeated
diffusion steps 1, and the temporal-occlusion curriculum.

`TARGET_MAX_STEPS` is an absolute global step. The formal continuation uses
`5000`, resumes at 501, and saves only at 750, 1000, 2000, 4000 and 5000 via a
checkpoint-scheduling-only training infrastructure patch. The repository checkpoint does not contain RLDS iterator
or RNG state, so the data stream is reconstructed from seed 42 rather than
continued bit-for-bit.

Dry run:

```bash
TARGET_MAX_STEPS=1000 DRY_RUN=1 ./launch_c16_resume_step500.sh
```

Do not launch while another four-GPU training job occupies the node.
