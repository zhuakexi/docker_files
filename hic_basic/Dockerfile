# syntax=docker/dockerfile:1

FROM mambaorg/micromamba:git-8440cec-focal-cuda-11.7.1

# prepare libs for open3d
USER root
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*
USER $MAMBA_USER
# --- set base env ---
# conda install
RUN micromamba install -y -n base -c conda-forge -c bioconda \
    numpy=1.23.1 pandas scikit-learn scikit-misc scipy umap-learn \
    pyarrow h5py openpyxl \
    matplotlib seaborn plotly python-kaleido pymol-open-source \
    cooler cooltools scanpy scvelo \
    anndata pysam pybedtools pybigwig loompy rmsd upsetplot \
    && micromamba clean --all --yes
# pip install
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN pip install opencv-contrib-python-headless open3d
# --- set bioR env ---
RUN micromamba create -n bioR -y -c conda-forge -c bioconda \
    r-tidyverse r-seurat bioconductor-tradeseq bioconductor-slingshot bioconductor-rgreat r-irkernel bioconductor-glmGamPoi