# Pick and place parts with Evo-RL

This project develops a robot policy for the task **sort, pick and place parts** using a customized Evo-RL framework. It keeps task documentation, dataset references, experiment configurations, and evaluation records in an independent repository. Shared training code and robot integrations belong in the parent Evo-RL fork.

## Repository relationship

Intended location in the customized framework: `projects/pick-place-parts`, mounted as a Git submodule. Each project commit versions task assets independently; the parent repository pins the project commit used with a framework revision.

The original framework is [MINT-SJTU/Evo-RL](https://github.com/MINT-SJTU/Evo-RL). A customized fork should retain the original as `upstream` and use the customized fork as `origin`.

## Current dataset

Local source: `/home/rui/.cache/huggingface/lerobot/local/pick_place_parts_1113_merged`

The recorded task uses a `rebot_b601_follower`, with seven state and action components: shoulder pan, shoulder lift, elbow flex, wrist flex, wrist yaw, wrist roll, and gripper. Front and wrist RGB streams are recorded at 640 by 480 pixels and 30 FPS in LeRobot v3.0 format.

Inspection on 18 November 2026 found:

- 841 episodes and 596,020 frames, equivalent to approximately 5.52 hours at 30 FPS, excluding resets.
- Mean episode length of 23.62 seconds; median 22.43 seconds; range 2.77 to 93.30 seconds, using frame count divided by FPS.
- 840 episodes labeled `success` and one labeled `failure`.
- Every frame attributed to `human`; all intervention flags and recorded policy actions are zero.
- Frame indices are unique and cover 0 through 596,019; episode frame counts agree with episode metadata. Action, observation state, and policy action arrays contain no nonfinite values.

These are demonstration collection statistics. The 99.88% success-label proportion is not an autonomous policy success rate. Zero intervention flags do not establish autonomy when all action sources are human.

The dataset declares all episodes as training data. Its current schema has no value, advantage, or advantage-conditioned indicator fields. The single failure also provides limited negative outcome coverage for value learning.

## Evo-RL workflow

1. Establish and evaluate a demonstration-trained policy baseline using the customized framework.
2. Collect policy rollouts with human takeover available, preserving collector identities and episode outcomes.
3. Merge versioned collection rounds and train the value function on the resulting data pool.
4. Infer values and advantages, then generate binary advantage-conditioned indicators.
5. Train a task-text-compatible policy with those indicators and evaluate it against the baseline.
6. Repeat collection and training, retaining the framework revision, project revision, dataset identity, and checkpoint for every comparison.

This is the intended workflow, not a claim that all stages have been completed for this dataset. Framework README hyperparameters are examples and should become project settings only when an experiment explicitly records them.

## Layout

- `configs/dataset.json`: machine-readable dataset reference and verified snapshot.
- `docs/experiments.md`: experiment and evaluation record format.
- `docs/repository-setup.md`: fork and submodule setup conventions.
- `scripts/`: task-specific launch and evaluation scripts as experiments are established.

Dataset parquet files, videos, model weights, local environments, and generated outputs stay outside this repository. Reference large artifacts by stable location and version instead of committing them.

## Evaluation plan

Reserve whole episodes for validation before training; use source session or collection round boundaries where available to reduce leakage. Evaluate policies on fresh robot trials under a fixed task protocol. Record trial counts, autonomous successes, human takeovers, completion times, and failure categories. Compare policies under the same object distribution and initial conditions, and report uncertainty alongside success rates.

The next project milestone is a reproducible baseline experiment and a separate autonomous evaluation record. Use `docs/experiments.md` to capture measured results.

## Evidence

Dataset facts come from `meta/info.json`, `meta/tasks.parquet`, `meta/episodes/chunk-000/file-000.parquet`, and the dataset frame parquet data. Workflow descriptions follow the parent Evo-RL README sections on value training, value inference, policy training, and closed-loop collection. Dataset values were inspected read-only; videos were not decoded for this summary.
