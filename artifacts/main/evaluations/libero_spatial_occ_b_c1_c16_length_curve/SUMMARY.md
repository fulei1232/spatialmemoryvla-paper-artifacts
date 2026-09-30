# LIBERO temporal-occlusion length curve

Protocol: matched task/state pairs and inference seed; 5 visible calls, 3 partial-occlusion calls, then the listed number of fully black calls.

| Full-black calls | B SR | C1 SR | C16 SR | C16−B (p) | C16−C1 (p) |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 4 | 27.0% | 29.0% | 35.0% | 8.0% (0.243) | 6.0% (0.3616) |
| 8 | 29.0% | 20.0% | 38.0% | 9.0% (0.1877) | 18.0% (0.007916) |
| 12 | 19.0% | 13.0% | 27.0% | 8.0% (0.2005) | 14.0% (0.02882) |
| 16 | 3.0% | 4.0% | 6.0% | 3.0% (0.4531) | 2.0% (0.7266) |

## Descriptive curve AUC

- B: 21.0%
- C1: 16.5%
- C16: 28.5%

The AUC is the trapezoidal mean success rate over 4–16 full-black calls; it is descriptive, not an independent significance test.
For the four C16-vs-C1 pointwise tests, the 8-call result remains significant after Bonferroni correction (raw p=0.007916; adjusted p=0.03166).
