#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$PROJECT_DIR/configs/robot.env" ]]; then
    source "$PROJECT_DIR/configs/robot.env"
fi

mode="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi
dry_run=false
if [[ "${1:-}" == --dry-run ]]; then dry_run=true; shift; fi
if [[ $# -gt 0 ]]; then echo "Unexpected argument: $1" >&2; exit 2; fi
if [[ "$mode" == help || "$mode" == --help || "$mode" == -h ]]; then
    echo 'Usage: bash scripts/run_robot.sh {calibrate-follower|calibrate-leader|teleoperate|record|evaluate} [--dry-run]'
    exit 0
fi

export HF_HUB_OFFLINE="${HF_HUB_OFFLINE:-1}"
export TRANSFORMERS_OFFLINE="${TRANSFORMERS_OFFLINE:-1}"
export PYTHONUNBUFFERED="${PYTHONUNBUFFERED:-1}"
if [[ -n "${LEROBOT_SOURCE:-}" ]]; then
    export PYTHONPATH="$LEROBOT_SOURCE/src${PYTHONPATH:+:$PYTHONPATH}"
fi
if [[ -n "${REBOT_GRAVITY_SDK_ROOT:-}" ]]; then export REBOT_GRAVITY_SDK_ROOT; fi

LEROBOT_PYTHON="${LEROBOT_PYTHON:-python}"
follower=(--robot.type=rebot_b601_follower "--robot.port=${FOLLOWER_PORT:-/dev/ttyACM0}" "--robot.id=${FOLLOWER_ID:-rebot_follower1103}")
leader=(--teleop.type=rebot_102_leader "--teleop.port=${LEADER_PORT:-/dev/ttyUSB0}" "--teleop.id=${LEADER_ID:-rebot_leader1103}")
# JSON encoding also handles camera paths containing spaces or punctuation.
cameras="$("$LEROBOT_PYTHON" -c 'import json,sys; print(json.dumps({k:dict(type="opencv",index_or_path=p,width=640,height=480,fps=30,fourcc="MJPG") for k,p in zip(["wrist","front"],sys.argv[1:])}))' "${WRIST_CAMERA:-/dev/cam_left}" "${FRONT_CAMERA:-/dev/cam_back}")"
export REBOT_GRAVITY_URDF="${REBOT_GRAVITY_URDF:-}"

case "$mode" in
    calibrate-follower)
        cmd=("$LEROBOT_PYTHON" -m lerobot.scripts.lerobot_calibrate "${follower[@]}") ;;
    calibrate-leader)
        cmd=("$LEROBOT_PYTHON" -m lerobot.scripts.lerobot_calibrate "${leader[@]}") ;;
    teleoperate)
        cmd=("$LEROBOT_PYTHON" -m lerobot.scripts.lerobot_teleoperate "${follower[@]}" "${leader[@]}") ;;
    record|evaluate)
        cmd=("$LEROBOT_PYTHON" -m lerobot.scripts.lerobot_human_inloop_record
            "${follower[@]}" "--robot.cameras=$cameras" "${leader[@]}"
            '--dataset.single_task=sort, pick and place parts'
            --dataset.reset_time_s=1 --dataset.push_to_hub=false --display_data=false
            "--resume=${RESUME:-false}")
        if [[ "$mode" == record ]]; then
            cmd+=("--dataset.repo_id=${RECORD_DATASET_ID:-local/pick_place_parts_new_round}"
                "--dataset.num_episodes=${RECORD_EPISODES:-100}" --dataset.episode_time_s=200)
        else
            if [[ -z "${POLICY_PATH:-}" ]]; then echo "Set POLICY_PATH to an existing checkpoint." >&2; exit 2; fi
            cmd+=("--dataset.repo_id=${EVAL_DATASET_ID:-local/eval_pick_place_parts_new_run}"
                "--dataset.num_episodes=${EVAL_EPISODES:-20}" --dataset.episode_time_s=100
                "--policy.path=$POLICY_PATH" --acp_inference.enable=true --play_sounds=false
                --intervention_toggle_key=i --intervention_confirm_key=i)
        fi ;;
    *) echo "Unknown mode: $mode" >&2; exit 2 ;;
esac

if $dry_run; then printf '%q ' "${cmd[@]}"; printf '\n'; exit 0; fi
exec "${cmd[@]}"
