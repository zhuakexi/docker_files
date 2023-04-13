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
    conda install -y -c conda-forge mamba
# prepare libs for open3d
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*
# set jupyterlab
RUN mamba create -y -n lab jupyterlab
# --- set embryo env ---
# set embryo env ML
RUN mamba create -y -n embryo -c conda-forge \
    numpy=1.23.1 pandas scikit-learn scipy umap-learn \
    pyarrow h5py \
    matplotlib seaborn plotly python-kaleido \
    jupyter_client ipykernel ipywidgets
# set embryo env bioinformatics
RUN mamba install -y -n embryo -c conda-forge -c bioconda \
    cooler=0.9.1 cooltools=0.5.4 scanpy scvelo \
    anndata pysam pybedtools pybigwig loompy rmsd upsetplot
# set embryo env 3D
RUN conda run -n embryo pip install opencv-python open3d
# additional packages 1
RUN mamba install -y -c conda-forge openpyxl --freeze-installed
# RUN mamba install -y -n embryo -c conda-forge numpy=1.23.1
RUN conda run -n embryo python -m ipykernel install --name=embryo --display-name="Python (embryo)"
# --- set bioR env ---
RUN mamba create -n bioR -y -c conda-forge -c bioconda r-tidyverse r-seurat bioconductor-tradeseq bioconductor-slingshot bioconductor-rgreat r-irkernel
RUN mamba install -y -n bioR -c conda-forge jupyter_client --freeze-installed
RUN conda run -n bioR R -e "IRkernel::installspec(name = 'bioR', displayname = 'R (bioR)')"
# --- configure jupyterlab ---
RUN mamba install -y -n lab -c conda-forge nodejs=16
RUN conda run -n lab jupyter labextension install jupyterlab-plotly
COPY jupyter_entrypoint.sh /opt/conda/
RUN chown toolman:toolman /opt/conda/jupyter_entrypoint.sh && \
    chmod +x /opt/conda/jupyter_entrypoint.sh
USER toolman
WORKDIR /share/Data/ychi/notebook
ENTRYPOINT ["/opt/conda/jupyter_entrypoint.sh"]
# TODO:
# 1. make jupyter running in background
# 2. fix kaleido