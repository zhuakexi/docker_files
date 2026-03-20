#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSET_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if [[ "${haystack}" != *"${needle}"* ]]; then
    echo "ASSERTION FAILED: ${label}" >&2
    echo "missing substring: ${needle}" >&2
    exit 1
  fi
}

assert_path_exists() {
  local path="$1"
  local label="$2"
  if [[ ! -e "${path}" ]]; then
    echo "ASSERTION FAILED: ${label}" >&2
    echo "missing path: ${path}" >&2
    exit 1
  fi
}

TMPDIR_TEST="$(mktemp -d)"
cleanup() {
  rm -rf "${TMPDIR_TEST}"
}
trap cleanup EXIT

PROJECT_ROOT="${TMPDIR_TEST}/fixture_project"
BAD_PROJECT_ROOT="${TMPDIR_TEST}/bad_project"
BIN_DIR="${TMPDIR_TEST}/bin"
ENV_ROOT="${TMPDIR_TEST}/envs"
DEFAULT_ENV_PREFIX="${ENV_ROOT}/hic_basic_v096"
ALT_ENV_PREFIX="${ENV_ROOT}/bioR"
CREATED_ENV_PREFIX="${ENV_ROOT}/rna_tools"
IN_CONTAINER_CREATED_ENV_PREFIX="${ENV_ROOT}/in_container_tools"
ABS_ENV_PREFIX="${TMPDIR_TEST}/custom_envs/absolute_env"
IMAGE_PATH="${TMPDIR_TEST}/light_base_test.sif"
SPEC_DIR="${TMPDIR_TEST}/specs"
SPEC_FILE="${SPEC_DIR}/rna_tools.yaml"
RUNTIME_LOG="${TMPDIR_TEST}/runtime.log"
CONTAINER_LOG="${TMPDIR_TEST}/container.log"

make_env() {
  local env_prefix="$1"
  mkdir -p "${env_prefix}/bin"
  ln -sf "$(command -v python3)" "${env_prefix}/bin/python"
}

mkdir -p "${PROJECT_ROOT}" "${BAD_PROJECT_ROOT}" "${BIN_DIR}" "${ENV_ROOT}" "${SPEC_DIR}" "$(dirname "${ABS_ENV_PREFIX}")"
touch "${IMAGE_PATH}"
make_env "${DEFAULT_ENV_PREFIX}"
make_env "${ALT_ENV_PREFIX}"
make_env "${ABS_ENV_PREFIX}"

cp "${ASSET_DIR}/run_in_env.sh" "${PROJECT_ROOT}/run_in_env.sh"
chmod +x "${PROJECT_ROOT}/run_in_env.sh"
cp "${ASSET_DIR}/run_in_env.sh" "${BAD_PROJECT_ROOT}/run_in_env.sh"
chmod +x "${BAD_PROJECT_ROOT}/run_in_env.sh"

cat > "${PROJECT_ROOT}/run_in_env.local.sh" <<EOF
IMAGE="${IMAGE_PATH}"
ENV_ROOT="${ENV_ROOT}"
DEFAULT_ENV_NAME="hic_basic_v096"
RUNTIME="${BIN_DIR}/fake_runtime.sh"
BINDS=(
  "/tmp:/tmp"
)
RUNTIME_ARGS=()
EOF

cat > "${BIN_DIR}/fake_runtime.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="__RUNTIME_LOG__"

if [[ "${1:-}" != "exec" ]]; then
  echo "fake_runtime: expected first argument 'exec'" >&2
  exit 64
fi
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    -B)
      shift 2
      ;;
    --*)
      shift
      ;;
    *)
      IMAGE="$1"
      shift
      break
      ;;
  esac
done

printf '%s\n' "$*" >> "${LOG_PATH}"

if [[ $# -lt 4 || "$1" != "micromamba" ]]; then
  echo "fake_runtime: unexpected command payload: $*" >&2
  exit 64
fi

MODE="$2"

case "${MODE}" in
  run)
    if [[ "$3" != "-p" ]]; then
      echo "fake_runtime: expected 'micromamba run -p <env>'" >&2
      exit 64
    fi
    ENV_PREFIX="$4"
    shift 4
    if [[ ! -d "${ENV_PREFIX}" ]]; then
      echo "fake_runtime: env prefix not found: ${ENV_PREFIX}" >&2
      exit 64
    fi
    exec "$@"
    ;;
  create)
    if [[ "$3" != "-p" ]]; then
      echo "fake_runtime: expected 'micromamba create -p <env>'" >&2
      exit 64
    fi
    ENV_PREFIX="$4"
    shift 4
    if [[ "${1:-}" != "--yes" || "${2:-}" != "--file" || $# -ne 3 ]]; then
      echo "fake_runtime: unexpected create payload: $*" >&2
      exit 64
    fi
    SPEC_FILE="$3"
    if [[ ! -f "${SPEC_FILE}" ]]; then
      echo "fake_runtime: spec file not found: ${SPEC_FILE}" >&2
      exit 64
    fi
    mkdir -p "${ENV_PREFIX}/bin"
    ln -sf "$(command -v python3)" "${ENV_PREFIX}/bin/python"
    echo "created=${ENV_PREFIX} spec=${SPEC_FILE}" >> "${LOG_PATH}"
    echo "fake_runtime: created ${ENV_PREFIX}"
    exit 0
    ;;
  *)
    echo "fake_runtime: unsupported micromamba mode: ${MODE}" >&2
    exit 64
    ;;
esac
EOF
sed -i "s|__RUNTIME_LOG__|${RUNTIME_LOG}|g" "${BIN_DIR}/fake_runtime.sh"
chmod +x "${BIN_DIR}/fake_runtime.sh"

cat > "${BIN_DIR}/mamba" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="__CONTAINER_LOG__"
printf '%s\n' "$*" >> "${LOG_PATH}"

if [[ $# -lt 3 ]]; then
  echo "fake_mamba: expected at least 3 arguments" >&2
  exit 64
fi

case "$1" in
  run)
    if [[ "${2:-}" != "-p" ]]; then
      echo "fake_mamba: expected 'run -p <env>'" >&2
      exit 64
    fi
    ENV_PREFIX="$3"
    shift 3
    if [[ ! -d "${ENV_PREFIX}" ]]; then
      echo "fake_mamba: env prefix not found: ${ENV_PREFIX}" >&2
      exit 64
    fi
    exec "$@"
    ;;
  create)
    if [[ "${2:-}" != "-p" ]]; then
      echo "fake_mamba: expected 'create -p <env>'" >&2
      exit 64
    fi
    ENV_PREFIX="$3"
    shift 3
    if [[ "${1:-}" != "--yes" || "${2:-}" != "--file" || $# -ne 3 ]]; then
      echo "fake_mamba: unexpected create payload: $*" >&2
      exit 64
    fi
    SPEC_FILE="$3"
    if [[ ! -f "${SPEC_FILE}" ]]; then
      echo "fake_mamba: spec file not found: ${SPEC_FILE}" >&2
      exit 64
    fi
    mkdir -p "${ENV_PREFIX}/bin"
    ln -sf "$(command -v python3)" "${ENV_PREFIX}/bin/python"
    echo "fake_mamba: created ${ENV_PREFIX}"
    exit 0
    ;;
  *)
    echo "fake_mamba: unsupported mode: $1" >&2
    exit 64
    ;;
esac
EOF
sed -i "s|__CONTAINER_LOG__|${CONTAINER_LOG}|g" "${BIN_DIR}/mamba"
chmod +x "${BIN_DIR}/mamba"

cat > "${SPEC_FILE}" <<'EOF'
name: rna_tools
dependencies:
  - python=3.11
EOF

echo "[1/9] validate prompt text"
PROMPT_TEXT="$(cat "${ASSET_DIR}/execution_rules_section.md")"
assert_contains "${PROMPT_TEXT}" "./run_in_env.sh --self-check" "prompt requires self-check"
assert_contains "${PROMPT_TEXT}" "/share/home/ychi/mambaforge/envs/hic_basic_v096" "prompt documents default env"
assert_contains "${PROMPT_TEXT}" "--env bioR" "prompt documents alternate env selection"
assert_contains "${PROMPT_TEXT}" "--create-env --env <name-or-prefix> --file <local-yaml-or-lock>" "prompt documents explicit env creation"
assert_contains "${PROMPT_TEXT}" "Do not fall back to direct host commands" "prompt forbids host fallback"
assert_contains "${PROMPT_TEXT}" "Treat direct-host fallback as a workflow violation" "prompt defines workflow violation"

echo "[2/9] validate runner syntax"
bash -n "${ASSET_DIR}/run_in_env.sh"

echo "[3/9] exercise default host_via_target_image mode"
HOST_SELF_CHECK="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --self-check)"
assert_contains "${HOST_SELF_CHECK}" "mode=host_via_target_image" "host self-check mode"
assert_contains "${HOST_SELF_CHECK}" "runner=micromamba@target_image" "host self-check runner"
assert_contains "${HOST_SELF_CHECK}" "env_root=${ENV_ROOT}" "host self-check env root"
assert_contains "${HOST_SELF_CHECK}" "default_env_name=hic_basic_v096" "host self-check default env name"
assert_contains "${HOST_SELF_CHECK}" "env_prefix=${DEFAULT_ENV_PREFIX}" "host self-check default env prefix"
DEFAULT_CMD_OUTPUT="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh python -c 'print("ok-default")')"
assert_contains "${DEFAULT_CMD_OUTPUT}" "ok-default" "default host execution command"

echo "[4/9] exercise explicit env selection on host"
ALT_SELF_CHECK="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --env bioR --self-check)"
assert_contains "${ALT_SELF_CHECK}" "env_prefix=${ALT_ENV_PREFIX}" "alternate env self-check"
ALT_CMD_OUTPUT="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --env bioR python -c 'print("ok-alt")')"
assert_contains "${ALT_CMD_OUTPUT}" "ok-alt" "alternate env execution command"
ABS_SELF_CHECK="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --env "${ABS_ENV_PREFIX}" --self-check)"
assert_contains "${ABS_SELF_CHECK}" "env_prefix=${ABS_ENV_PREFIX}" "absolute env self-check"
ABS_CMD_OUTPUT="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --env "${ABS_ENV_PREFIX}" python -c 'print("ok-abs")')"
assert_contains "${ABS_CMD_OUTPUT}" "ok-abs" "absolute env execution command"

echo "[5/9] exercise explicit environment creation on host"
CREATE_OUTPUT="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --create-env --env rna_tools --file "${SPEC_FILE}")"
assert_contains "${CREATE_OUTPUT}" "fake_runtime: created ${CREATED_ENV_PREFIX}" "host create output"
assert_path_exists "${CREATED_ENV_PREFIX}/bin/python" "created env python"
assert_contains "$(cat "${RUNTIME_LOG}")" "micromamba create -p ${CREATED_ENV_PREFIX} --yes --file ${SPEC_FILE}" "host create command log"
CREATED_CMD_OUTPUT="$(cd "${PROJECT_ROOT}" && ./run_in_env.sh --env rna_tools python -c 'print("ok-created")')"
assert_contains "${CREATED_CMD_OUTPUT}" "ok-created" "created env execution command"

echo "[6/9] verify failure modes for existing or missing envs"
set +e
EXISTS_OUTPUT="$(
  cd "${PROJECT_ROOT}" && \
  ./run_in_env.sh --create-env --env bioR --file "${SPEC_FILE}" 2>&1
)"
EXISTS_CODE=$?
set -e
if [[ ${EXISTS_CODE} -eq 0 ]]; then
  echo "ASSERTION FAILED: existing env creation should fail" >&2
  exit 1
fi
assert_contains "${EXISTS_OUTPUT}" "target env already exists: ${ALT_ENV_PREFIX}" "existing env failure message"

set +e
MISSING_ENV_OUTPUT="$(
  cd "${PROJECT_ROOT}" && \
  ./run_in_env.sh --env missing_env python -c 'print("should-not-run")' 2>&1
)"
MISSING_ENV_CODE=$?
set -e
if [[ ${MISSING_ENV_CODE} -eq 0 ]]; then
  echo "ASSERTION FAILED: missing env execution should fail" >&2
  exit 1
fi
assert_contains "${MISSING_ENV_OUTPUT}" "target env prefix is not visible on the host" "missing env failure mode"
assert_contains "${MISSING_ENV_OUTPUT}" "./run_in_env.sh --create-env --env ${ENV_ROOT}/missing_env --file /path/to/spec.yaml" "missing env creation hint"

echo "[7/9] exercise simulated in_container mode"
CONTAINER_SELF_CHECK="$(cd "${PROJECT_ROOT}" && PATH="${BIN_DIR}:$PATH" SINGULARITY_NAME=test_container ./run_in_env.sh --env bioR --self-check)"
assert_contains "${CONTAINER_SELF_CHECK}" "mode=in_container" "container self-check mode"
assert_contains "${CONTAINER_SELF_CHECK}" "runner=mamba" "container self-check runner"
assert_contains "${CONTAINER_SELF_CHECK}" "env_prefix=${ALT_ENV_PREFIX}" "container self-check env prefix"
CONTAINER_CMD_OUTPUT="$(cd "${PROJECT_ROOT}" && PATH="${BIN_DIR}:$PATH" SINGULARITY_NAME=test_container ./run_in_env.sh --env bioR python -c 'print("ok-container")')"
assert_contains "${CONTAINER_CMD_OUTPUT}" "ok-container" "container execution command"

echo "[8/9] exercise in-container env creation"
CONTAINER_CREATE_OUTPUT="$(cd "${PROJECT_ROOT}" && PATH="${BIN_DIR}:$PATH" SINGULARITY_NAME=test_container ./run_in_env.sh --create-env --env in_container_tools --file "${SPEC_FILE}")"
assert_contains "${CONTAINER_CREATE_OUTPUT}" "fake_mamba: created ${IN_CONTAINER_CREATED_ENV_PREFIX}" "container create output"
assert_path_exists "${IN_CONTAINER_CREATED_ENV_PREFIX}/bin/python" "in-container created env python"
CONTAINER_CREATED_CMD_OUTPUT="$(cd "${PROJECT_ROOT}" && PATH="${BIN_DIR}:$PATH" SINGULARITY_NAME=test_container ./run_in_env.sh --env in_container_tools python -c 'print("ok-container-created")')"
assert_contains "${CONTAINER_CREATED_CMD_OUTPUT}" "ok-container-created" "container created env execution command"

echo "[9/9] verify failure on missing image"
set +e
FAIL_OUTPUT="$(
  cd "${BAD_PROJECT_ROOT}" && \
  RUN_IN_ENV_IMAGE="${TMPDIR_TEST}/missing.sif" \
  RUN_IN_ENV_PREFIX="${DEFAULT_ENV_PREFIX}" \
  RUN_IN_ENV_RUNTIME="${BIN_DIR}/fake_runtime.sh" \
  ./run_in_env.sh --self-check 2>&1
)"
FAIL_CODE=$?
set -e
if [[ ${FAIL_CODE} -eq 0 ]]; then
  echo "ASSERTION FAILED: missing-image check should fail" >&2
  exit 1
fi
assert_contains "${FAIL_OUTPUT}" "container image not found" "missing image failure message"

echo "test_run_env_assets.sh: all checks passed"
