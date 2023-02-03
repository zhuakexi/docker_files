# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:latest

ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID toolman && \
    adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID toolman && \
    adduser root toolman && \
    chown -R root:toolman /opt/conda && \
    chmod -R g-w /opt/conda && \
    chmod -R g+rX /opt/conda
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
    numpy pandas scikit-learn scipy umap-learn louvain \
    h5py anndata pysam pybedtools pybigwig pyarrow loompy \
    scanpy scvelo cooler cooltools \
    matplotlib seaborn plotly \
    jupyter_client ipykernel ipywidgets python-kaleido
RUN conda run -n embryo pip install opencv-python open3d
RUN conda run -n embryo python -m ipykernel install --name=embryo --display-name="Python (embryo)"
# configure jupyterlab
RUN mamba install -n lab -c conda-forge nodejs=16
RUN conda run -n lab jupyter labextension install jupyterlab-plotly
COPY jupyter_entrypoint.sh /opt/conda/
RUN chown toolman:toolman /opt/conda/jupyter_entrypoint.sh && \
    chmod +x /opt/conda/jupyter_entrypoint.sh
USER toolman
WORKDIR /share/Data/ychi/notebook
ENTRYPOINT ["/opt/conda/jupyter_entrypoint.sh"]
# TODO:
# 1. fix numba bug when import scanpy
# 2. adding R packages
