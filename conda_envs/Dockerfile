# syntax=docker/dockerfile:1

FROM quay.io/jupyter/datascience-notebook:latest

# --- set base ML env ---
USER root
# prepare libs for open3d
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}
RUN mamba install --yes -c conda-forge -c plotly python-kaleido jupyter-dash \
    cooler cooltools pymol-open-source scanpy scvelo anndata pysam pybedtools pybigwig loompy rmsd upsetplot && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
RUN pip install --no-cache-dir opencv-contrib-python-headless open3d && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# --- set py2 env ---
# Name your environment and choose the Python version
ARG env_name=py2
ARG py_ver=2.7.15
COPY --chown=${NB_UID}:${NB_GID} conda_files/dip-c.yaml /tmp/
RUN mamba env create -p "${CONDA_DIR}/envs/${env_name}" -f /tmp/dip-c.yaml && \
    mamba clean --all -f -y
# Create Python kernel and link it to jupyter
RUN "${CONDA_DIR}/envs/${env_name}/bin/python" -m ipykernel install --user --name="${env_name}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
# RUN "${CONDA_DIR}/envs/${env_name}/bin/pip" install --no-cache-dir \
#     'flake8'

# --- set bioR env ---
ARG env_name=bioR
ARG py_ver=3.8.8
RUN mamba create --yes -p "${CONDA_DIR}/envs/${env_name}" \
    python=${py_ver} \
    'jupyter_client' \
    'r-tydyverse' \
    'r-seurat' \
    'bioconductor-tradeseq' \
    'bioconductor-slingshot' \
    'bioconductor-rgreat' \
    'r-irkernel' \
    'bioconductor-glmGamPoi' \
    && \
    mamba clean --all -f -y
# Create Python kernel and link it to jupyter
RUN "${CONDA_DIR}/envs/${env_name}/bin/R" -e "IRkernel::installspec(name = 'bioR', user = TRUE, displayname = 'R (bioR)')" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
# TODO:
# 1. make jupyter running in background
# 2. a same docker can run jupyterlab and exec custom command, hack jupyter_entrypoint.sh
# 3. fix kaleido