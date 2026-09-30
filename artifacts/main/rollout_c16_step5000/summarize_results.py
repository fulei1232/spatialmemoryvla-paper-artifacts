#!/usr/bin/env python3
import json
import pathlib
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("root", type=pathlib.Path)
parser.add_argument("--require-conditions", nargs="*")
args = parser.parse_args()
root = args.root
rows = []
for path in sorted(root.rglob("rollouts.jsonl")):
    condition = path.relative_to(root).parts[0]
    with path.open() as stream:
        for line in stream:
            if line.strip():
                row = json.loads(line)
                row["evaluation_condition"] = condition
                rows.append(row)

if not rows:
    raise SystemExit(f"No rollout records found under {root}")

by_task = {}
for row in rows:
    key = (row["evaluation_condition"], row["runtime_task_index"], row["task_name"])
    by_task.setdefault(key, []).append(bool(row["success"]))

if args.require_conditions:
    episode_sets = {}
    for condition in args.require_conditions:
        condition_ids = [
            row["episode_id"] for row in rows if row["evaluation_condition"] == condition
        ]
        if len(condition_ids) != len(set(condition_ids)):
            raise SystemExit(f"Duplicate episode IDs found for {condition}")
        episode_sets[condition] = set(condition_ids)
    expected = episode_sets[args.require_conditions[0]]
    for condition, episodes in episode_sets.items():
        if episodes != expected:
            missing = sorted(expected - episodes)
            extra = sorted(episodes - expected)
            raise SystemExit(
                f"Unpaired episode set for {condition}: missing={missing[:5]}, extra={extra[:5]}"
            )

summary = {
    "output_root": str(root.resolve()),
    "episodes": len(rows),
    "successes": sum(bool(row["success"]) for row in rows),
    "success_rate": sum(bool(row["success"]) for row in rows) / len(rows),
    "tasks": [
        {
            "condition": key[0],
            "task_id": key[1],
            "task_name": key[2],
            "episodes": len(values),
            "successes": sum(values),
            "success_rate": sum(values) / len(values),
        }
        for key, values in sorted(by_task.items())
    ],
}
if args.require_conditions:
    summary["paired_episode_set_verified"] = True
    summary["required_conditions"] = args.require_conditions
output = root / "summary.json"
output.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n")
print(json.dumps(summary, indent=2, ensure_ascii=False))
print(f"Wrote {output}")
