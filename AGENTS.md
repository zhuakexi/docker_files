# Repository Guidelines

## Project Structure & Module Organization
- This repository has three active streams:
  1. `light_base/` for Docker base images and related build scripts;
  2. `conda_envs/` for all Conda environment definitions and environment-specific notes;
  3. `agent_env_instructions/` for prompt and instruction assets that describe how agents should use the environment model.
- `light_base/Dockerfile` defines the active lightweight micromamba-enabled base image. `light_base/build.sh` builds it.
- `light_base/` also has an external publication path used for cloud builds:
  `light_base/` in this repo -> `/share/home/ychi/dev/light_base` -> `https://github.com/zhuakexi/light_base.git`
- Treat this repository's `light_base/` as the development starting point. Sync outward to `/share/home/ychi/dev/light_base` and then GitHub when publishing updates for online container builds.
- `conda_envs/` keeps YAML and lock files flat at the directory root. Supporting notes live under `conda_envs/docs/`.
- `archieved/` stores older image-specific build contexts and legacy setups kept for reference only. Do not treat it as the primary implementation path unless a task explicitly targets historical content.

## Build, Test, and Development Commands
- Build the current base image from the active workflow: `cd light_base && ./build.sh`
- Build directly with Docker if needed: `docker build -t zhuakexi/light_base:v0.2 light_base`
- Mirror/publish workflow for `light_base`: update this repo first, then sync the same changes to `/share/home/ychi/dev/light_base`, then push that repo to `https://github.com/zhuakexi/light_base.git`

### light_base Release and Publishing Workflow
The `light_base/` directory is the upstream source. Changes flow through this path:
```
this repo (light_base/) -> /share/home/ychi/dev/light_base -> GitHub -> Aliyun Container Registry
```

**Step-by-step release process:**

1. **Make changes in this repo** (`/share/home/ychi/dev/docker_files/light_base/`)

2. **Sync to publishing repo**:
   ```bash
   cp /share/home/ychi/dev/docker_files/light_base/Dockerfile /share/home/ychi/dev/light_base/Dockerfile
   ```

3. **Commit and push to GitHub**:
   ```bash
   cd /share/home/ychi/dev/light_base
   git add Dockerfile
   git commit -m "describe your changes"
   git push origin master
   ```

4. **Create and push a release tag**:
   ```bash
   git tag release-v1.2
   git push origin release-v1.2
   ```

5. **Publish GitHub Release** (required to trigger Aliyun build):
   - Visit https://github.com/zhuakexi/light_base/releases
   - Select the tag `release-v1.2`
   - Set Release title: `release-v1.2`
   - Click "Publish release"
   - This triggers the automated build in Aliyun Container Registry

6. **Wait for Aliyun auto-build** (at least 10 minutes)

7. **Pull and verify the image**:
   ```bash
   docker pull crpi-iljsyiotrsmkpbnu.cn-beijing.personal.cr.aliyuncs.com/zhuakexi/light_base_github:1.2
   
   # Verify slurm commands (sbatch, srun, scontrol, squeue, scancel)
   docker run --rm --entrypoint bash crpi-iljsyiotrsmkpbnu.cn-beijing.personal.cr.aliyuncs.com/zhuakexi/light_base_github:1.2 -c "which sbatch srun scontrol squeue scancel"
   
   # Verify ssh for git operations inside container
   docker run --rm --entrypoint bash crpi-iljsyiotrsmkpbnu.cn-beijing.personal.cr.aliyuncs.com/zhuakexi/light_base_github:1.2 -c "which ssh"
   
   # Verify git
   docker run --rm --entrypoint bash crpi-iljsyiotrsmkpbnu.cn-beijing.personal.cr.aliyuncs.com/zhuakexi/light_base_github:1.2 -c "git --version"
   ```

**Current packages in light_base:**
- Base: `mambaorg/micromamba:git-6d896e6-cuda12.2.2-ubuntu22.04`
- Graphics/libs: `libgl1`, `libgomp1`
- Tools: `git`, `less`, `curl`, `nodejs`, `npm`, `libreoffice`, `build-essential`
- Cluster: `slurm-client` (sbatch, srun, scontrol, squeue, scancel)
- SSH: `openssh-client` (for git ssh operations inside container)

- For local testing in this repository, install all Conda environments under `/share/home/ychi/mambaforge/envs/`.
- When creating or running Conda environments, always reference them by absolute path with `-p /share/home/ychi/mambaforge/envs/<env>` rather than by environment name. This avoids environment lookup issues when the same setup is used inside Docker.
- Create an environment from a YAML file:
  `micromamba create -p /share/home/ychi/mambaforge/envs/<env> --yes --file /path/to/conda_envs/<env>.yaml`
- Reproduce an environment from a lock file when stability matters:
  `micromamba create -p /share/home/ychi/mambaforge/envs/<env> --yes --file /path/to/conda_envs/<env>.lock`
- Minimal validation is usually:
  1. build or start the base image;
  2. create the target Conda environment;
  3. run a smoke test such as `micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 python -c "import pandas as pd; print(pd.__version__)"`

## Coding Style & Naming Conventions
- Shell scripts are Bash (`.sh`) and should stay concise and executable.
- Keep Docker-related assets in `light_base/` and Conda definitions in `conda_envs/`; do not mix the two concerns in one active directory.
- Keep environment definitions in YAML or lock form with clear names, typically reflecting purpose and version, such as `hic_basic_v095.yaml`, `hic_basic_v095.lock`, or `torch_clean.yaml`.
- Keep `conda_envs/` definitions flat at the directory root. Put longer release notes, environment rationale, and command examples under `conda_envs/docs/`.
- Prefer updating active streams over `archieved/` unless the task is explicitly about a legacy workflow.

## Testing Guidelines
- There is no centralized automated test suite for the repository.
- For tests in this repo, place Conda environments under `/share/home/ychi/mambaforge/envs/` and invoke them with `-p /share/home/ychi/mambaforge/envs/<env>` instead of using named environments.
- Validate changes with the smallest realistic smoke test for the modified layer:
  - Docker layer changes: rebuild the `light_base` image.
  - Conda environment changes: create the environment from the YAML or lock file in `conda_envs/`.
  - Package/runtime changes: verify one or two critical imports or commands under `micromamba run`.
- If a change affects portability, note whether it was verified only in the Docker base image or also in another runtime.

## Commit & Pull Request Guidelines
- Use short, descriptive commit messages focused on the main change, preferably lowercase and under about 72 characters.
- PRs should state:
  - whether the change affects `light_base`, `conda_envs`, `agent_env_instructions`, or only `archieved`;
  - which files or environment variants changed;
  - which build or smoke-test commands were run.
- If a change only touches historical material under `archieved/`, say so explicitly.

## Security & Configuration Tips
- Do not hard-code secrets, tokens, or private registry credentials in Dockerfiles, scripts, YAML files, or prompt assets.
- Pin important base images and major package versions where reproducibility matters.
- Prefer lock files for environments that must be recreated exactly, and YAML files for more maintainable high-level specs.
