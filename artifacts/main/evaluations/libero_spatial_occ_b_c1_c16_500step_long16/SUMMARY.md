# LIBERO-Spatial B/C1/C16 matched rollout summary

- Complete: True
- Paired temporal_occlusion states: True

| Model | Condition | Success | SR (95% Wilson CI) | Recovery success | Mean calls | Mean calls (success) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| B | temporal_occlusion | 3/100 | 3.0% (1.0%–8.5%) | 3/100 (3.0%) | 27.99 | 27.67 |
| C1 | temporal_occlusion | 4/100 | 4.0% (1.6%–9.8%) | 3/99 (3.0%) | 27.88 | 25.00 |
| C16 | temporal_occlusion | 6/100 | 6.0% (2.8%–12.5%) | 5/99 (5.1%) | 27.87 | 25.83 |

## Paired C16 comparisons

- temporal_occlusion, C16 vs B: ΔSR=3.0%, wins/losses=5/2, exact McNemar p=0.4531.
- temporal_occlusion, C16 vs C1: ΔSR=2.0%, wins/losses=5/3, exact McNemar p=0.7266.

Recovery success is success among episodes that reached the recovered-visible phase.
Paired significance and effect size, not training loss alone, determine whether history is effective.
