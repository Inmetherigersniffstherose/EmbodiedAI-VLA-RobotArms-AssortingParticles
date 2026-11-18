# Experiment records

Create one record per training run and attach a separate evaluation record. Unfilled fields are not measured results.

## Training record template

- Run ID and date:
- Objective and baseline:
- Framework remote and full commit:
- Framework uncommitted patch reference, if applicable:
- Project full commit:
- Dataset identity, immutable revision or content manifest:
- Training and validation episode assignments:
- Initial policy and checkpoint:
- Value model and checkpoint, if applicable:
- Value and advantage field names and inference settings:
- Exact launch command and saved configuration:
- Random seed, hardware, and environment versions:
- Training steps and batch size:
- Final checkpoint and logs location:

## Robot evaluation record template

- Evaluation ID and date:
- Policy checkpoint and training run ID:
- Robot calibration and camera setup:
- Object set, initial conditions, and reset procedure:
- Success criterion and time limit:
- Number of fresh trials:
- Autonomous successful trials:
- Trials requiring human takeover:
- Completion time distribution:
- Failure categories and counts:
- Success rate and uncertainty interval:
- Matched baseline comparison:
- Raw trial log and video locations:

Keep demonstration collection labels separate from autonomous evaluation results. A human-rescued trial must not count as an autonomous success.
