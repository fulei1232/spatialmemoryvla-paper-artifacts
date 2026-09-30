#!/usr/bin/env bash

set -Eeuo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

command -v uv >/dev/null || { echo "uv is required on the A100 server" >&2; exit 1; }
command -v nvidia-smi >/dev/null || { echo "nvidia-smi is required" >&2; exit 1; }

project_sha="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
libero_sha="$(git -C "${LIBERO_ROOT}" rev-parse HEAD)"
[[ "${project_sha}" == "${EXPECTED_PROJECT_SHA}" ]] || { echo "Bad project SHA: ${project_sha}" >&2; exit 1; }
[[ "${libero_sha}" == "${EXPECTED_LIBERO_SHA}" ]] || { echo "Bad LIBERO SHA: ${libero_sha}" >&2; exit 1; }

gpu_count="$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)"
[[ "${gpu_count}" -ge 4 ]] || { echo "Need at least four visible GPUs, found ${gpu_count}" >&2; exit 1; }

echo "Creating locked environment at ${VENV}"
(
  cd "${PROJECT_ROOT}"
  UV_PROJECT_ENVIRONMENT="${VENV}" CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    uv sync --frozen --no-dev
)

# LIBERO is an external checkout rather than a uv.lock dependency. The checkout
# contains the required namespace-package discovery compatibility patch.
uv pip install --python "${PYTHON}" --no-deps --editable "${LIBERO_ROOT}"

"${PYTHON}" - <<'PY'
import json
import sys
from importlib.metadata import version
import torch
import transformers
import mujoco
import robosuite
import libero

report = {
    "python": sys.version.split()[0],
    "torch": torch.__version__,
    "torch_cuda": torch.version.cuda,
    "nccl": torch.cuda.nccl.version(),
    "cudnn": torch.backends.cudnn.version(),
    "transformers": transformers.__version__,
    "mujoco": mujoco.__version__,
    "robosuite": version("robosuite"),
    "libero": version("libero"),
    "cuda_available": torch.cuda.is_available(),
    "gpu_count": torch.cuda.device_count(),
    "gpus": [torch.cuda.get_device_name(i) for i in range(torch.cuda.device_count())],
}
print(json.dumps(report, indent=2))
assert report["gpu_count"] >= 4
assert report["torch"] == "2.2.0+cu121"
assert report["transformers"] == "4.40.1"
assert report["mujoco"] == "2.3.7"
assert report["robosuite"] == "1.4.0"
PY

verify_bundle
echo "A100 rollout environment is ready. Next: ${BUNDLE_ROOT}/smoke_a100.sh"
