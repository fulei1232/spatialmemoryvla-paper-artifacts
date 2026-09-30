# B continuation from the correct step-500 run

This discards the later full-finetune B recipe and resumes the original B
step-500 model plus optimizer. Its optimization/data recipe matches the
successful frozen C16 continuation. The only intended experimental differences
are `experiment_mode=spatial_forcing`, `use_spatial_memory=false`, and the
inactive B memory-length placeholder of 1.

The run stops at global step 5000 and saves model plus optimizer at steps 750,
1000, 2000, 4000 and 5000.
