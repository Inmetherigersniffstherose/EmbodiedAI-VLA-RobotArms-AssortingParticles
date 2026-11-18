# Customized robot setup

## Project hardware

This pick and place project uses one Seeed reBot B601-DM follower and one reBot Arm 102 leader, also called StarArm102. The dataset has seven state and action components, corresponding to six arm joints and a gripper. Dual-arm configurations from the other local projects are not used here.

The recorded project device mapping is:

- Follower: `rebot_b601_follower`, port `/dev/ttyACM0`, ID `rebot_follower1103`.
- Leader: `rebot_102_leader`, port `/dev/ttyUSB0`, ID `rebot_leader1103`.
- Wrist RGB camera: feature `observation.images.wrist`, OpenCV device `/dev/cam_left`.
- Front RGB camera: feature `observation.images.front`, OpenCV device `/dev/cam_back`.
- Both cameras: 640 × 480 pixels, 30 FPS, MJPG capture. Dataset videos are encoded as AV1.

`front` is the policy feature name even though its device alias is `cam_back`. Preserve the feature names when changing camera devices. These aliases are created by local udev rules and must be configured on another machine; they are not standard Linux device names. Serial port numbering may also change after reconnecting hardware.

## Runtime and driver provenance

The inspected hardware-enabled environment is `evo-rl-yt`, using Python 3.10.21 and the editable source checkout `/home/rui/yt_workspace/Codes/Evo-RL`. The original source commit is recorded in [the source manifest](../hardware/source-manifest.json), together with SHA-256 hashes of the actual customized files. A commit alone does not capture the local modifications.

Observed package versions on 18 November 2026 were LeRobot 0.4.4, `motorbridge` 0.5.5, `motorbridge-smart-servo` 0.0.4, Pinocchio distribution `pin` 4.1.0, PyTorch 2.7.1, PyAV 15.1.0, and draccus 0.10.0. These are an environment snapshot, not a complete dependency lockfile.

The parent `/home/rui/Evo-RL` checkout currently does not contain the reBot device adapters. Installing that checkout alone will not register these robot types. The launch script must use the existing hardware-enabled runtime or another framework installation with equivalent reBot support. For this machine:

```bash
conda activate evo-rl-yt
python -c 'import lerobot; print(lerobot.__file__)'
```

The [driver snapshot](../hardware/driver_snapshot/) preserves the single-arm follower, its gravity model helper, and the leader implementation with their original license. It is a source archive, not an independently installable plugin. Porting it to another framework revision also requires robot and teleoperator factory branches, CLI config imports, optional dependency detection, and dependency declarations. It must be checked against that framework's APIs before use.

## Control configuration

[The hardware manifest](../configs/hardware.json) combines the recorded project ports and cameras with inspected driver defaults. It is documentation, not a top-level configuration accepted directly by every LeRobot CLI. These defaults describe the inspected runtime and do not establish the exact software state of every historical trial.

The follower communicates through a Damiao serial CAN bridge at 921,600 baud. Its six arm joints use MIT control by default. The gripper uses force-position control, with a torque ratio of 0.07. In joint order `shoulder_pan`, `shoulder_lift`, `elbow_flex`, `wrist_flex`, `wrist_yaw`, `wrist_roll`, `gripper`:

- Send CAN IDs are `0x01` through `0x07`; receive CAN IDs are `0x11` through `0x17`.
- The first three motor models are `4340P`; the remaining motors are `4310`.
- Default MIT proportional gains are `[45, 45, 45, 8, 9, 8, 8]` and derivative gains are `[12, 12, 12, 1, 1, 1, 1]`. The gripper has separate settings when operated in MIT mode.
- Joint limits in degrees are `[-150, 150]`, `[-200, 1]`, `[-200, 1]`, `[-80, 90]`, `[-90, 90]`, `[-90, 90]`, and `[-270, 5]`.

The leader communicates with FashionStar UART servos at 1,000,000 baud. Joint IDs run from 0 through 6 in the same order. Its direction and scaling factors are `[-1, -1, 1, 1, 1, -1, -6]`; the gripper factor maps its travel into follower coordinates. Its configured ranges are preserved in the hardware manifest.

The customized follower uses measured-state gravity feedforward in MIT mode and requires a B601-DM URDF. The project sets `REBOT_GRAVITY_SDK_ROOT=~/yt_workspace/Codes/third_party/reBotArm_control_py`; the driver finds the model at `urdf/DM/urdf/ReBot_Arm_DM.urdf` within that SDK. Alternatively, set `REBOT_GRAVITY_URDF` to the model file itself. The URDF and SDK are external dependencies and are not bundled here.

The inspected disconnect routine returns toward the startup pose by default. Its configured home duration is 6 seconds at 25 Hz, with a home velocity of 12 degrees per second. It opens the gripper before homing, keeps it open during the return, and closes it afterward. Account for that motion and any held part when ending a session.

## Calibration

The project calibration references are included at:

- `hardware/calibration/robots/rebot_b601_follower/rebot_follower1103.json`.
- `hardware/calibration/teleoperators/rebot_102_leader/rebot_leader1103.json`.

The runtime normally reads matching files under `~/.cache/huggingface/lerobot/calibration/`. These references preserve the IDs and ranges used locally. A saved file does not establish the physical zero pose of another arm. Follow the driver's prompts to position the arm at its zero pose with the gripper closed and calibrate the actual hardware.

From this project repository:

```bash
cp configs/robot.env.example configs/robot.env
# Edit configs/robot.env for the installed runtime and connected devices.
bash scripts/run_robot.sh calibrate-follower
bash scripts/run_robot.sh calibrate-leader
bash scripts/run_robot.sh teleoperate
```

`configs/robot.env` is ignored by Git. Environment values in that file are shell assignments; quote paths containing spaces. Add `--dry-run` to any launch command to print it without connecting to the hardware.

## Collection

The project owner's collection and rollout setup uses the following environment. Activate it in the shell before using the original CLI:

```bash
conda activate evo-rl-yt
export REBOT_GRAVITY_SDK_ROOT=~/yt_workspace/Codes/third_party/reBotArm_control_py
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1
export PYTHONUNBUFFERED=1
cd /home/rui/yt_workspace/Codes/Evo-RL
export PYTHONPATH="$PWD/src${PYTHONPATH:+:$PYTHONPATH}"
```

The environment template and launch script preserve these settings. Offline mode assumes required models and assets already exist locally. It applies to robot runs, not to the separate Hugging Face dataset upload.

The original collection command is:

```bash
lerobot-human-inloop-record \
  --robot.type=rebot_b601_follower \
  --robot.port=/dev/ttyACM0 \
  --robot.id=rebot_follower1103 \
  --robot.cameras='{ wrist: {type: opencv, index_or_path: "/dev/cam_left", width: 640, height: 480, fps: 30, fourcc: "MJPG"}, front: {type: opencv, index_or_path: "/dev/cam_back", width: 640, height: 480, fps: 30, fourcc: "MJPG"}}' \
  --teleop.type=rebot_102_leader \
  --teleop.port=/dev/ttyUSB0 \
  --teleop.id=rebot_leader1103 \
  --dataset.repo_id=local/pick_place_parts_1111 \
  --dataset.single_task="sort, pick and place parts" \
  --dataset.num_episodes=100 \
  --dataset.episode_time_s=200 \
  --dataset.reset_time_s=1 \
  --dataset.push_to_hub=false \
  --display_data=false \
  --resume=false
```

This command records demonstrations; it has no `--policy.path` and therefore does not run a trained policy. The evaluation command below adds the policy checkpoint and inference settings for rollout.

The reusable launcher produces the equivalent collection arguments from `configs/robot.env`. Run it from this project repository:

```bash
bash scripts/run_robot.sh record --dry-run
bash scripts/run_robot.sh record
```

The environment template uses the original `local/pick_place_parts_1111` dataset ID. Choose a new `RECORD_DATASET_ID` for a new collection round. Set `RESUME=true` to continue an existing compatible recording, equivalent to changing the original command to `--resume=true`. `RECORD_EPISODES` defaults to 100 per launch; it is not the total size of either training round.

The merged dataset was formed from `local/pick_place_parts_1104` and `local/pick_place_parts_1111`. Historical merge commands list the later collection first, so do not assume the first 500 episode indices in the merged dataset identify round one. Use collection provenance to reconstruct training subsets.

## Policy evaluation

The inspected final checkpoint at `/home/rui/yt_workspace/checkpoints/pi05/1114_ppp/pretrained_model` identifies a `pi05` policy trained with `local/pick_place_parts_1113_merged`. Set `POLICY_PATH` to the required checkpoint. Model weights are not included in this repository.

```bash
bash scripts/run_robot.sh evaluate --dry-run
bash scripts/run_robot.sh evaluate
```

This uses the project's human-in-the-loop recording entry point with ACP inference enabled, a 100-second episode limit, a 1-second reset, and `i` as both intervention toggle and confirm key. The leader remains connected for takeover. Evaluation defaults to 20 episodes per run to match the reported evaluation format; historical shell commands allowed up to 100 episodes per recording session.

Use a distinct `EVAL_DATASET_ID` for each run. Mark outcomes using the recorder's success and failure controls. Record any takeover separately when assessing autonomous success; the human-in-the-loop command permits interventions and does not by itself prove an uninterrupted run.

## Verification scope

The configuration, source hashes, shell syntax, dry-run commands, and CLI argument parsing were checked without connecting to the robot. Robot motion, camera capture, and checkpoint performance require validation on the physical setup.
