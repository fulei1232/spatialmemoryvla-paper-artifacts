# LIBERO-Spatial B/C1/C16 matched rollout summary

- Complete: True
- Paired temporal_occlusion states: True

| Model | Condition | Success | SR (95% Wilson CI) | Recovery success | Mean calls | Mean calls (success) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| B | temporal_occlusion | 19/100 | 19.0% (12.5%–27.8%) | 18/99 (18.2%) | 27.42 | 24.95 |
| C1 | temporal_occlusion | 13/100 | 13.0% (7.8%–21.0%) | 12/99 (12.1%) | 27.57 | 24.69 |
| C16 | temporal_occlusion | 27/100 | 27.0% (19.3%–36.4%) | 27/100 (27.0%) | 27.49 | 26.11 |

## Paired C16 comparisons

- temporal_occlusion, C16 vs B: ΔSR=8.0%, wins/losses=19/11, exact McNemar p=0.2005.
- temporal_occlusion, C16 vs C1: ΔSR=14.0%, wins/losses=25/11, exact McNemar p=0.02882.

Recovery success is success among episodes that reached the recovered-visible phase.
Paired significance and effect size, not training loss alone, determine whether history is effective.
