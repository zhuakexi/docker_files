# light_base

`light_base/` contains the active Docker base image for this repository. Its job is to provide a lightweight Ubuntu + CUDA + `micromamba` runtime that Conda environments from [`conda_envs/`](../conda_envs/README.md) can reuse.

## Upstream Sync

`light_base/` also participates in an external sync chain used for cloud-based container builds:

- Current repo source of truth for daily work: `/share/home/ychi/dev/docker_files/light_base`
- Local mirror repo used for standalone `light_base` development: `/share/home/ychi/dev/light_base`
- GitHub repo for online/cloud builds: `https://github.com/zhuakexi/light_base.git`

The intended flow is:

`/share/home/ychi/dev/docker_files/light_base` -> `/share/home/ychi/dev/light_base` -> GitHub

Future `light_base` development should start from this repository first, then be synced outward to the local mirror repo and GitHub.

## Build

```bash
cd /share/home/ychi/dev/docker_files/light_base
./build.sh
```

Equivalent direct build:

```bash
docker build -t zhuakexi/light_base:v0.2 .
```

## Scope

- Keep only Docker image assets here.
- Put Conda environment definitions in `../conda_envs/`.
- Put agent-facing instruction assets in `../agent_env_instructions/`.
- Keep this directory aligned with `/share/home/ychi/dev/light_base` when `light_base` changes need to be published to GitHub for cloud builds.
