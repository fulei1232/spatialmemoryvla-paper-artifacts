# LIBERO-Spatial B/C1/C16 matched rollout summary

- Complete: True
- Paired normal states: True
- Paired temporal-occlusion states: True

| Model | Condition | Success | SR (95% Wilson CI) | Recovery success | Mean calls | Mean calls (success) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| B | normal | 1/2 | 50.0% (9.5%–90.5%) | NA | 18.50 | 9.00 |
| B | temporal_occlusion | 0/2 | 0.0% (0.0%–65.8%) | 0/2 (0.0%) | 28.00 | NA |
| C1 | normal | 1/2 | 50.0% (9.5%–90.5%) | NA | 18.50 | 9.00 |
| C1 | temporal_occlusion | 0/2 | 0.0% (0.0%–65.8%) | 0/2 (0.0%) | 28.00 | NA |
| C16 | normal | 1/2 | 50.0% (9.5%–90.5%) | NA | 19.00 | 10.00 |
| C16 | temporal_occlusion | 0/2 | 0.0% (0.0%–65.8%) | 0/2 (0.0%) | 28.00 | NA |

## Paired C16 comparisons

- normal, C16 vs B: ΔSR=0.0%, wins/losses=0/0, exact McNemar p=1.
- normal, C16 vs C1: ΔSR=0.0%, wins/losses=0/0, exact McNemar p=1.
- temporal_occlusion, C16 vs B: ΔSR=0.0%, wins/losses=0/0, exact McNemar p=1.
- temporal_occlusion, C16 vs C1: ΔSR=0.0%, wins/losses=0/0, exact McNemar p=1.

Recovery success is success among episodes that reached the recovered-visible phase.
Paired significance and effect size, not training loss alone, determine whether history is effective.
