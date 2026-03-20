#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_ROOT="${RUN_IN_ENV_ENV_ROOT:-/share/home/ychi/mambaforge/envs}"
DEFAULT_ENV_NAME="${RUN_IN_ENV_DEFAULT_ENV_NAME:-hic_basic_v096}"

# Copy this script to a project root, then either:
# 1. edit the defaults below directly, or
# 2. create "${PROJECT_ROOT}/run_in_env.local.sh" to override them.
IMAGE="${RUN_IN_ENV_IMAGE:-/path/to/light_base.sif}"
ENV_PREFIX="${RUN_IN_ENV_PREFIX:-${ENV_ROOT}/${DEFAULT_ENV_NAME}}"
INITIAL_ENV_PREFIX="${ENV_PREFIX}"
ENV_PREFIX_WAS_DEFAULT=0
if [[ -z "${RUN_IN_ENV_PREFIX:-}" ]]; then
  ENV_PREFIX_WAS_DEFAULT=1
fi
RUNTIME="${RUN_IN_ENV_RUNTIME:-singularity}"
BINDS=(
  "/share/home/ychi:/share/home/ychi"
  "/shareb/ychi:/shareb/ychi"
  "/shared/ychi:/shared/ychi"
)
RUNTIME_ARGS=()

if [[ -f "${PROJECT_ROOT}/run_in_env.local.sh" ]]; then
  # shellcheck disable=SC1091
  source "${PROJECT_ROOT}/run_in_env.local.sh"
fi

if [[ "${ENV_PREFIX_WAS_DEFAULT}" == "1" && "${ENV_PREFIX}" == "${INITIAL_ENV_PREFIX}" ]]; then
  ENV_PREFIX="${ENV_ROOT}/${DEFAULT_ENV_NAME}"
fi

EXEC_MODE=""
EXEC_RUNNER=""
ACTION="run"
ENV_REQUEST=""
ENV_REQUEST_EXPLICIT=0
SPEC_FILE=""
EXTRA_BINDS=()

usage() {
  cat <<'EOF'
Usage:
  ./run_in_env.sh --env <env-name-or-prefix> --self-check
  ./run_in_env.sh --self-check
  ./run_in_env.sh --env <env-name-or-prefix> <command> [args...]
  ./run_in_env.sh <command> [args...]
  ./run_in_env.sh --create-env --env <env-name-or-prefix> --file <spec.yaml|lock>

This is the only project-supported compute entrypoint.
The default env is hic_basic_v096 under /share/home/ychi/mambaforge/envs/.
EOF
}

usage_error() {
  local message="$1"
  echo "run_in_env.sh: ${message}" >&2
  usage >&2
  exit 64
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "run_in_env.sh: required command not found: $cmd" >&2
    return 127
  fi
}

current_runner() {
  if command -v micromamba >/dev/null 2>&1; then
    printf '%s\n' "micromamba"
    return 0
  fi
  if command -v mamba >/dev/null 2>&1; then
    printf '%s\n' "mamba"
    return 0
  fi
  if command -v conda >/dev/null 2>&1; then
    printf '%s\n' "conda"
    return 0
  fi
  return 1
}

absolute_existing_path() {
  local raw_path="$1"
  local abs_path
  local dir_path
  local base_name

  if [[ "${raw_path}" == /* ]]; then
    abs_path="${raw_path}"
  else
    abs_path="${PWD}/${raw_path}"
  fi

  dir_path="$(dirname "${abs_path}")"
  base_name="$(basename "${abs_path}")"

  if [[ ! -e "${dir_path}/${base_name}" ]]; then
    echo "run_in_env.sh: path not found: ${raw_path}" >&2
    return 127
  fi

  (
    cd "${dir_path}" &&
    printf '%s/%s\n' "$(pwd -P)" "${base_name}"
  )
}

resolve_env_prefix() {
  local raw_env="$1"
  if [[ "${raw_env}" == /* ]]; then
    printf '%s\n' "${raw_env}"
    return 0
  fi

  printf '%s/%s\n' "${ENV_ROOT}" "${raw_env}"
}

add_bind_if_dir() {
  local dir_path="$1"
  if [[ -n "${dir_path}" && -d "${dir_path}" ]]; then
    EXTRA_BINDS+=("${dir_path}:${dir_path}")
  fi
}

prepare_extra_binds() {
  EXTRA_BINDS=()
  add_bind_if_dir "$(dirname "${ENV_PREFIX}")"
  if [[ -n "${SPEC_FILE}" ]]; then
    add_bind_if_dir "$(dirname "${SPEC_FILE}")"
  fi
}

print_missing_env_hint() {
  echo "run_in_env.sh: create it first with: ./run_in_env.sh --create-env --env ${ENV_PREFIX} --file /path/to/spec.yaml" >&2
}

ensure_env_prefix_visible() {
  local context_label="$1"
  if [[ ! -d "${ENV_PREFIX}" ]]; then
    echo "run_in_env.sh: target env prefix is not visible in ${context_label}: ${ENV_PREFIX}" >&2
    print_missing_env_hint
    return 127
  fi
  if [[ ! -x "${ENV_PREFIX}/bin/python" ]]; then
    echo "run_in_env.sh: target env python is not executable in the current context: ${ENV_PREFIX}/bin/python" >&2
    return 127
  fi
}

build_bind_args() {
  local bind
  local -a args=()
  for bind in "${BINDS[@]}"; do
    args+=(-B "$bind")
  done
  for bind in "${EXTRA_BINDS[@]}"; do
    args+=(-B "$bind")
  done
  printf '%s\0' "${args[@]}"
}

resolve_execution_context() {
  local require_existing_env="$1"
  if [[ -n "${SINGULARITY_NAME:-}" || -n "${APPTAINER_NAME:-}" ]]; then
    if [[ "${require_existing_env}" == "1" ]]; then
      ensure_env_prefix_visible "the current context"
    fi
    if ! EXEC_RUNNER="$(current_runner)"; then
      echo "run_in_env.sh: inside the container, but no supported runner is available (micromamba/mamba/conda)" >&2
      return 127
    fi
    EXEC_MODE="in_container"
    return 0
  fi

  require_command "${RUNTIME}"
  if [[ ! -f "${IMAGE}" ]]; then
    echo "run_in_env.sh: container image not found: ${IMAGE}" >&2
    return 127
  fi
  if [[ "${require_existing_env}" == "1" ]]; then
    if [[ ! -d "${ENV_PREFIX}" ]]; then
      echo "run_in_env.sh: target env prefix is not visible on the host: ${ENV_PREFIX}" >&2
      print_missing_env_hint
      return 127
    fi
    if [[ ! -x "${ENV_PREFIX}/bin/python" ]]; then
      echo "run_in_env.sh: target env python is not executable on the host: ${ENV_PREFIX}/bin/python" >&2
      return 127
    fi
  fi

  prepare_extra_binds
  EXEC_MODE="host_via_target_image"
  EXEC_RUNNER="micromamba@target_image"
}

resolve_run_context() {
  resolve_execution_context 1
}

resolve_create_context() {
  resolve_execution_context 0
}

exec_in_current_container() {
  exec "${EXEC_RUNNER}" run -p "${ENV_PREFIX}" "$@"
}

create_in_current_container() {
  exec "${EXEC_RUNNER}" create -p "${ENV_PREFIX}" --yes --file "${SPEC_FILE}"
}

exec_via_target_image() {
  local -a bind_args=()
  local -a runtime_args=()
  local -a cmd=()
  local arg
  while IFS= read -r -d '' arg; do
    bind_args+=("$arg")
  done < <(build_bind_args)

  if declare -p RUNTIME_ARGS >/dev/null 2>&1 && ((${#RUNTIME_ARGS[@]} > 0)); then
    runtime_args=("${RUNTIME_ARGS[@]}")
  fi

  cmd=("${RUNTIME}" exec)
  if ((${#runtime_args[@]} > 0)); then
    cmd+=("${runtime_args[@]}")
  fi
  if ((${#bind_args[@]} > 0)); then
    cmd+=("${bind_args[@]}")
  fi
  cmd+=("${IMAGE}" micromamba run -p "${ENV_PREFIX}" "$@")

  exec "${cmd[@]}"
}

create_via_target_image() {
  local -a bind_args=()
  local -a runtime_args=()
  local -a cmd=()
  local arg
  while IFS= read -r -d '' arg; do
    bind_args+=("$arg")
  done < <(build_bind_args)

  if declare -p RUNTIME_ARGS >/dev/null 2>&1 && ((${#RUNTIME_ARGS[@]} > 0)); then
    runtime_args=("${RUNTIME_ARGS[@]}")
  fi

  cmd=("${RUNTIME}" exec)
  if ((${#runtime_args[@]} > 0)); then
    cmd+=("${runtime_args[@]}")
  fi
  if ((${#bind_args[@]} > 0)); then
    cmd+=("${bind_args[@]}")
  fi
  cmd+=("${IMAGE}" micromamba create -p "${ENV_PREFIX}" --yes --file "${SPEC_FILE}")

  exec "${cmd[@]}"
}

run_cmd() {
  if [[ $# -eq 0 ]]; then
    usage >&2
    return 64
  fi

  resolve_run_context

  if [[ "${EXEC_MODE}" == "in_container" ]]; then
    exec_in_current_container "$@"
  fi

  exec_via_target_image "$@"
}

self_check() {
  local -a self_check_cmd=(
    python -c "import os, sys; print('python_executable=' + sys.executable); print('cwd=' + os.getcwd())"
  )

  resolve_run_context

  echo "run_in_env.sh: self-check"
  echo "mode=${EXEC_MODE}"
  echo "runtime=${RUNTIME}"
  echo "runner=${EXEC_RUNNER}"
  echo "image=${IMAGE}"
  echo "env_root=${ENV_ROOT}"
  echo "default_env_name=${DEFAULT_ENV_NAME}"
  echo "env_prefix=${ENV_PREFIX}"

  if [[ "${EXEC_MODE}" == "in_container" ]]; then
    exec_in_current_container "${self_check_cmd[@]}"
  fi

  exec_via_target_image "${self_check_cmd[@]}"
}

create_env() {
  if [[ "${ENV_REQUEST_EXPLICIT}" != "1" ]]; then
    usage_error "--create-env requires --env"
  fi
  if [[ -z "${SPEC_FILE}" ]]; then
    usage_error "--create-env requires --file"
  fi
  if [[ -e "${ENV_PREFIX}" ]]; then
    echo "run_in_env.sh: target env already exists: ${ENV_PREFIX}" >&2
    return 1
  fi

  resolve_create_context

  if [[ "${EXEC_MODE}" == "in_container" ]]; then
    create_in_current_container
  fi

  create_via_target_image
}

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --self-check)
      if [[ "${ACTION}" != "run" ]]; then
        usage_error "choose only one action"
      fi
      ACTION="self_check"
      shift
      ;;
    --create-env)
      if [[ "${ACTION}" != "run" ]]; then
        usage_error "choose only one action"
      fi
      ACTION="create_env"
      shift
      ;;
    --env)
      if [[ $# -lt 2 ]]; then
        usage_error "--env requires a value"
      fi
      ENV_REQUEST="$2"
      ENV_REQUEST_EXPLICIT=1
      shift 2
      ;;
    --file)
      if [[ $# -lt 2 ]]; then
        usage_error "--file requires a value"
      fi
      SPEC_FILE="$2"
      shift 2
      ;;
    --)
      shift
      POSITIONAL_ARGS+=("$@")
      break
      ;;
    -*)
      usage_error "unknown option: $1"
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL_ARGS+=("$1")
        shift
      done
      ;;
  esac
done

ENV_PREFIX="$(resolve_env_prefix "${ENV_REQUEST:-${ENV_PREFIX}}")"

if [[ -n "${SPEC_FILE}" ]]; then
  SPEC_FILE="$(absolute_existing_path "${SPEC_FILE}")"
fi

case "${ACTION}" in
  self_check)
    if [[ ${#POSITIONAL_ARGS[@]} -ne 0 ]]; then
      usage_error "--self-check does not accept a command"
    fi
    if [[ -n "${SPEC_FILE}" ]]; then
      usage_error "--self-check does not accept --file"
    fi
    self_check
    ;;
  create_env)
    if [[ ${#POSITIONAL_ARGS[@]} -ne 0 ]]; then
      usage_error "--create-env does not accept a command"
    fi
    create_env
    ;;
  run)
    if [[ -n "${SPEC_FILE}" ]]; then
      usage_error "--file is only valid with --create-env"
    fi
    run_cmd "${POSITIONAL_ARGS[@]}"
    ;;
  *)
    usage_error "unsupported action: ${ACTION}"
    ;;
esac
