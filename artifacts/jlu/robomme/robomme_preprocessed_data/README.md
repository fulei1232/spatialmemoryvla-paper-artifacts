---
license: apache-2.0
---

# RoboMME Training Data (Pickle Format)

[Arxiv Paper](https://arxiv.org/abs/2603.04639) |  [HF Paper](https://huggingface.co/papers/2603.04639) |  [Website](https://robomme.github.io/) | [Benchmark Code](https://github.com/RoboMME/robomme_benchmark) | [Policy Learning Code](https://github.com/RoboMME/robomme_policy_learning)

This repo contains preprocessed pickle files for RoboMME training data and npy files for cached image tokens. We use this dataset in our [MME-VLA](https://github.com/RoboMME/robomme_policy_learning) experiments.

```
.
├── data        # zipped pickle files
├── features    # zipped precompute siglip embeddings
├── meta        # statistics for robomme
├── memer       # VLM subgoal training data for MemER (only used for symbolic memory)
├── qwenvl      # VLM subgoal training data for QwenVL  (only used for symbolic memory)
└── README.md
```