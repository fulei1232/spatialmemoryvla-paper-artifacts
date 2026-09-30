# LIBERO temporal-occlusion memory smoke

- Complete: True
- Paired task/initial states: True
- Memory occlusion lifecycle complete: True
- Reset occlusion lifecycle complete: True

| Condition | Success | Rate | Mean policy calls |
| --- | ---: | ---: | ---: |
| memory_normal | 4/4 | 100.0% | 11.75 |
| memory_occlusion | 1/4 | 25.0% | 25.75 |
| reset_occlusion | 2/4 | 50.0% | 25.00 |

Memory advantage under temporal occlusion: -25.0%

This is a technical smoke test; four paired episodes are not a performance claim.
