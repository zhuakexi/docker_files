## Execution Rules

This file is the shared source of truth for command execution in this project.

All compute commands must use the project execution entrypoint:

```bash
./run_in_env.sh <command> [args...]
```

By default, `./run_in_env.sh` uses the Conda environment prefix
`/share/home/ychi/mambaforge/envs/hic_basic_v096`.

Examples:

```bash
./run_in_env.sh --self-check
./run_in_env.sh --env bioR --self-check
./run_in_env.sh python script.py
./run_in_env.sh --env bioR python script.py
./run_in_env.sh python -c "import sys; print(sys.executable)"
./run_in_env.sh --create-env --env rna_tools --file /share/home/ychi/dev/docker_files/conda_envs/rna_tools.yaml
```

Use `./run_in_env.sh` when your current directory is the project root. From a
subdirectory, call the project-root script by absolute path instead of
reconstructing the environment command by hand.

Rules:

- Before the first compute command in a session, run `./run_in_env.sh --self-check`.
- If the default `hic_basic_v096` environment is suitable, use it without adding extra environment commands.
- If you need a different existing environment, switch explicitly with `--env <name-or-prefix>`. A bare name such as `bioR` means `/share/home/ychi/mambaforge/envs/bioR`.
- If no existing environment is sufficient, create a new one under `/share/home/ychi/mambaforge/envs/` with `./run_in_env.sh --create-env --env <name-or-prefix> --file <local-yaml-or-lock>`, then continue to use `./run_in_env.sh --env <name-or-prefix> ...` for execution.
- Treat `--create-env` as an explicit setup step. Do not assume the runner will auto-create environments during normal command execution.
- Do not inline raw `singularity`, `apptainer`, `docker`, `micromamba`, `mamba`, or `conda` command templates in prompts or outputs when `./run_in_env.sh` exists.
- Do not fall back to direct host commands such as `python`, `python3`, `Rscript`, `micromamba`, `mamba`, `conda`, `singularity`, or `apptainer` when `./run_in_env.sh` fails.
- If `./run_in_env.sh` fails, stop and report the failure explicitly.
- Treat direct-host fallback as a workflow violation, not as a success path.
- If older docs in the repo still show raw environment commands, prefer `./run_in_env.sh` over those older examples.
