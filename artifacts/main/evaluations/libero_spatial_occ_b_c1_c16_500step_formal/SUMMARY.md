# LIBERO-Spatial B/C1/C16 matched rollout summary

- Complete: True
- Paired normal states: True
- Paired temporal-occlusion states: True

| Model | Condition | Success | SR (95% Wilson CI) | Recovery success | Mean calls | Mean calls (success) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| B | normal | 58/100 | 58.0% (48.2%–67.2%) | NA | 18.44 | 11.52 |
| B | temporal_occlusion | 27/100 | 27.0% (19.3%–36.4%) | 27/100 (27.0%) | 25.33 | 18.11 |
| C1 | normal | 68/100 | 68.0% (58.3%–76.3%) | NA | 17.38 | 12.38 |
| C1 | temporal_occlusion | 29/100 | 29.0% (21.0%–38.5%) | 29/100 (29.0%) | 24.92 | 17.38 |
| C16 | normal | 72/100 | 72.0% (62.5%–79.9%) | NA | 16.84 | 12.50 |
| C16 | temporal_occlusion | 35/100 | 35.0% (26.4%–44.7%) | 35/100 (35.0%) | 24.75 | 18.71 |

## Paired C16 comparisons

- normal, C16 vs B: ΔSR=14.0%, wins/losses=25/11, exact McNemar p=0.02882.
- normal, C16 vs C1: ΔSR=4.0%, wins/losses=19/15, exact McNemar p=0.6076.
- temporal_occlusion, C16 vs B: ΔSR=8.0%, wins/losses=22/14, exact McNemar p=0.243.
- temporal_occlusion, C16 vs C1: ΔSR=6.0%, wins/losses=18/12, exact McNemar p=0.3616.

Recovery success is success among episodes that reached the recovered-visible phase.
Paired significance and effect size, not training loss alone, determine whether history is effective.
