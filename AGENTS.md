# Repository Guidelines

## Project Structure & Module Organization
- This repository is a collection of Docker image build contexts for multiple tool stacks. Each top-level directory (e.g., `eaglec/`, `hic_basic/`, `neoloop/`, `HiNT_tl/`, `jimnet/`, `torch/`, `conda_envs/`, `light_conda/`, `gumnet/`) is its own image context with a `Dockerfile` and helper scripts.
- Shared environment specifications live in `conda_yaml/` and `conda_envs/conda_files/` (YAMLs).
- Runtime helpers are typically in the same image directory (e.g., `entrypoint.sh`, `jupyter_entrypoint.sh`, `run.sh`, `run_hpc.sh`).
- agent_env_instructions向

## Build, Test, and Development Commands
- Build an image: `./<image>/build.sh` (wraps `docker build` with repository-specific options).
- Run locally or on HPC: `./<image>/run.sh` or `./<image>/run_hpc.sh` (when present).
- Push to registry: `./<image>/push.sh` (when present).
- Example: `./hic_basic/build.sh` builds the `hic_basic` image.

## Coding Style & Naming Conventions
- Shell scripts are Bash (`.sh`) and should remain executable; keep them concise and focused on a single task.
- Use lowercase directory names for image contexts; keep files like `Dockerfile`, `build.sh`, `run_hpc.sh`, and `push.sh` consistent across images.
- YAML environment files should use clear, versioned names (e.g., `hic_basic_v095.yaml`) and be placed under `conda_yaml/` or `light_conda/` as appropriate.

## Testing Guidelines
- There is no centralized test suite. Validation is done by building the image and performing a minimal runtime check (e.g., start a container, verify a key binary is on `PATH`).
- If you add a new image or major dependency, include a short smoke test in the relevant `run.sh` or document it in the PR description.

## Commit & Pull Request Guidelines
- Recent commits use short, descriptive, lowercase messages (no strict convention). Keep messages under ~72 characters and focus on the main change (e.g., “add nodejs for gemini cli”).
- PRs should describe which image(s) changed, note any base image or dependency updates, and include build verification commands you ran (e.g., `./torch/build.sh`).
- If changes affect runtime entrypoints or conda specs, call that out explicitly.

## Security & Configuration Tips
- Avoid hard-coding secrets in Dockerfiles or scripts; prefer environment variables or build args.
- When updating base images, use explicit tags to keep builds reproducible.
