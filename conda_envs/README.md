# conda_envs

`conda_envs/` contains all active Conda environment definitions for this repository. YAML and lock files are kept flat at the directory root, while longer notes and release records live under [`docs/`](./docs/).

## Usage

For local testing in this repository, install environments under `/share/home/ychi/mambaforge/envs/` and always run them by absolute path.

Create from YAML:

```bash
micromamba create -p /share/home/ychi/mambaforge/envs/<env> --yes --file /share/home/ychi/dev/docker_files/conda_envs/<env>.yaml
```

Create from lock file:

```bash
micromamba create -p /share/home/ychi/mambaforge/envs/<env> --yes --file /share/home/ychi/dev/docker_files/conda_envs/<env>.lock
```

Smoke test example:

```bash
micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 python -c "import pandas as pd; print(pd.__version__)"
```

## Layout

- Root files: environment definitions such as `hic_basic_v095.yaml`, `hic_basic_v095.lock`, `DNA_tools.yaml`, `bioR.yaml`, `ML.yaml`
- `docs/`: release notes, package-change notes, and environment-specific command examples

## Notes

- `hic_basic` series updates and working notes are tracked in [`docs/hic_basic.md`](./docs/hic_basic.md).
- Package news for the `hic_basic` baseline is tracked in [`docs/core_package_news.md`](./docs/core_package_news.md).
- Historical Docker-only workflows and retired image streams are stored under `../archieved/`.
