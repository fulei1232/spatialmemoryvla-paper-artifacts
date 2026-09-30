# LIBERO-Spatial B/C1/C16 matched rollout summary

- Complete: True
- Paired temporal_occlusion states: True

| Model | Condition | Success | SR (95% Wilson CI) | Recovery success | Mean calls | Mean calls (success) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| B | temporal_occlusion | 29/100 | 29.0% (21.0%–38.5%) | 27/98 (27.6%) | 26.00 | 21.10 |
| C1 | temporal_occlusion | 20/100 | 20.0% (13.3%–28.9%) | 19/99 (19.2%) | 26.36 | 19.80 |
| C16 | temporal_occlusion | 38/100 | 38.0% (29.1%–47.8%) | 38/100 (38.0%) | 25.26 | 20.79 |

## Paired C16 comparisons

- temporal_occlusion, C16 vs B: ΔSR=9.0%, wins/losses=23/14, exact McNemar p=0.1877.
- temporal_occlusion, C16 vs C1: ΔSR=18.0%, wins/losses=30/12, exact McNemar p=0.007916.

Recovery success is success among episodes that reached the recovered-visible phase.
Paired significance and effect size, not training loss alone, determine whether history is effective.
