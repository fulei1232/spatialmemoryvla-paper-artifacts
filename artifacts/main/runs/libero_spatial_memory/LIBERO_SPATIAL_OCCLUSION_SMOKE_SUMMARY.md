# LIBERO-Spatial occlusion training smoke

- Complete: True
- Matched shared configuration: True
- Matched per-rank occlusion sequence: True

| Run | Steps | Action loss first → last | Spatial loss first → last | Total loss first → last | Max grad norm | Occluded rows | Max history |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| B | 20 | 0.3675 → 0.0380 | 1.0247 → 0.6189 | 0.8798 → 0.3475 | 3.2557 | 9.1% | 1 |
| C1 | 20 | 0.4513 → 0.0409 | 1.0247 → 0.6644 | 0.9636 → 0.3731 | 8.3060 | 9.1% | 1 |
| C16 | 20 | 0.4509 → 0.0419 | 1.0247 → 0.6645 | 0.9632 → 0.3742 | 8.2988 | 9.1% | 16 |

Twenty steps validate the pipeline only; they are not a model-quality comparison.
