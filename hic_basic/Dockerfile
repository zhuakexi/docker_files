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
RUN conda install -y -c conda-forge mamba
# --- install valid packages ---
# set embryo env ML
RUN mamba install -y -n base -c conda-forge \
    numpy=1.23.1 pandas scikit-learn scikit-misc scipy umap-learn \
    pyarrow h5py openpyxl \
    matplotlib seaborn plotly python-kaleido pymol-open-source
# set embryo env 3D
RUN conda run -n base pip install opencv-python open3d
# Add an entrypoint script to activate the conda base environment
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# launching
USER toolman