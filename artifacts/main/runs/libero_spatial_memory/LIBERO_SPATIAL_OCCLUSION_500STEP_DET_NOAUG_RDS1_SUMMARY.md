# LIBERO-Spatial occlusion training smoke

- Complete: True
- Matched shared configuration: True
- Matched per-rank occlusion sequence: True

| Run | Steps | Action first → last | Action last-50 | Spatial first → last | Total first → last | Max grad | Occluded | Max history |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| B | 500 | 0.3675 → 0.0699 | 0.0676 | 1.0247 → 0.0221 | 0.8798 → 0.0809 | 3.5207 | 25.6% | 1 |
| C1 | 500 | 0.4513 → 0.0736 | 0.0689 | 1.0247 → 0.0280 | 0.9636 → 0.0876 | 8.3060 | 25.6% | 1 |
| C16 | 500 | 0.4509 → 0.0720 | 0.0678 | 1.0247 → 0.0281 | 0.9632 → 0.0860 | 8.2988 | 25.6% | 16 |

Training losses are diagnostic only; model quality must be decided by matched simulator rollouts.
