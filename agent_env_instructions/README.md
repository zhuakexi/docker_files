# agent_env_instructions

`agent_env_instructions/` stores prompt and instruction assets for agents that need to use this repository's environment model directly.

## Scope

- Describe how agents should use `light_base/` and `conda_envs/`
- Keep reusable prompt assets and environment usage guidance here
- Do not store Docker image definitions or Conda YAML/lock files here

## Available Assets

- `execution_rules_section.md`: a concrete `## Execution Rules` section that can be pasted directly into any `AGENTS.md`
- `run_in_env.sh`: a real runner script patterned after `/share/home/ychi/dev/spg/run_in_env.sh`; copy it into a project root, then set the project-specific image/env/binds

## Runner Behavior

- Default execution target: `/share/home/ychi/mambaforge/envs/hic_basic_v096`
- Existing alternate environment: `./run_in_env.sh --env bioR ...`
- New environment creation: `./run_in_env.sh --create-env --env my_env --file /path/to/spec.yaml`
- All Conda environment names resolve under `/share/home/ychi/mambaforge/envs/` unless `--env` is already an absolute prefix
- `--create-env` is explicit and fail-fast: if the target env already exists, the script stops instead of recreating or updating it

Typical flow:

```bash
./run_in_env.sh --self-check
./run_in_env.sh python -c "import pandas as pd; print(pd.__version__)"
./run_in_env.sh --env bioR Rscript script.R
./run_in_env.sh --create-env --env rna_tools --file /share/home/ychi/dev/docker_files/conda_envs/rna_tools.yaml
./run_in_env.sh --env rna_tools python script.py
```

## Tests

- `tests/test_run_env_assets.sh`: validates the prompt section and exercises `run_in_env.sh` through default-env resolution, explicit `--env` selection, explicit `--create-env`, host-side execution, and simulated in-container execution paths

Run:

```bash
bash agent_env_instructions/tests/test_run_env_assets.sh
```
