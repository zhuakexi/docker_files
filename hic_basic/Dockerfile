# syntax=docker/dockerfile:1

FROM mambaorg/micromamba:git-8440cec-focal-cuda-11.7.1

# prepare libs for open3d
USER root
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
    libgomp1 \
    git less \
    && rm -rf /var/lib/apt/lists/*

ARG NEW_MAMBA_USER=ychi
ARG NEW_MAMBA_USER_ID=1006
ARG NEW_MAMBA_USER_GID=1006

RUN if grep -q '^ID=alpine$' /etc/os-release; then \
      # alpine does not have usermod/groupmod
      apk add --no-cache --virtual temp-packages shadow; \
    fi && \
    usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${NEW_MAMBA_USER}" \
        --move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
    groupmod "--new-name=${NEW_MAMBA_USER}" \
        "-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
    if grep -q '^ID=alpine$' /etc/os-release; then \
      # remove the packages that were only needed for usermod/groupmod
      apk del temp-packages; \
    fi && \
    # Update the expected value of MAMBA_USER for the
    # _entrypoint.sh consistency check.
    echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
    :
ENV MAMBA_USER=$NEW_MAMBA_USER
USER $MAMBA_USER

# --- set base env ---
# conda install
RUN micromamba install -y -n base -c conda-forge -c bioconda \
    numpy=1.23.1 pandas xarray scikit-learn scikit-misc scipy umap-learn \
    pyarrow h5py openpyxl xlrd pytables h5netcdf netcdf4 \
    matplotlib seaborn plotly python-kaleido pymol-open-source \
    cooler cooltools scanpy scvelo \
    anndata pysam pybedtools pybigwig loompy rmsd upsetplot \
    jupyter jupyter_client ipykernel nbconvert \
    && micromamba clean --all --yes

# pip install
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN pip install opencv-contrib-python-headless open3d

# --- set bioR env ---
RUN micromamba create -n bioR -y -c conda-forge -c bioconda \
    r-tidyverse r-seurat bioconductor-tradeseq bioconductor-slingshot bioconductor-rgreat r-irkernel bioconductor-glmGamPoi \
    jupyter_client \
    && micromamba clean --all --yes

# Install Jupyter kernels for both environments
RUN micromamba run -n base python -m ipykernel install --user --name=base --display-name="Python (base)" && \
    micromamba run -n bioR R -e "IRkernel::installspec(name = 'bioR', displayname = 'R (bioR)')"