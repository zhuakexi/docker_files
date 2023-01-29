# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:latest

WORKDIR /env_files
#COPY conda_files/embryo.yaml embryo.yaml
COPY .condarc /root/.condarc
RUN conda clean -i; \
    conda install -c conda-forge mamba
# prepare libs for open3d
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*
# set jupyterlab
RUN mamba create -n lab jupyterlab
# set embryo env
RUN mamba create -n embryo -c conda-forge -c bioconda \
    numpy pandas scikit-learn scipy umap-learn louvain numba \
    h5py anndata pysam pybedtools pybigwig pyarrow loompy \
    scanpy scvelo cooler cooltools \
    matplotlib seaborn plotly \
    jupyter_client ipykernel ipywidgets python-kaleido
RUN conda run -n embryo pip install opencv-python open3d
RUN conda run -n embryo python -m ipykernel install --user --name=embryo --display-name="Python (embryo)"
# start jupyter
#SHELL ["conda", "run", "-n", "lab", "/bin/bash", "-c"]
#RUN jupyter lab --port=6501 --no-browser

#TODO: 
# 1. fix numba bug
# 2. adding non-priviliged user
# 3. adding jupyterlab command and run in daemon mode