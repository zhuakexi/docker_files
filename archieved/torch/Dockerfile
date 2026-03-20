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
# set jupyterlab
RUN mamba create -y -n lab jupyterlab
# --- set torch env ---
RUN mamba create -y -n torch python=3.9 pytorch torchvision torchaudio cudatoolkit=11.1 \
    plotly ipykernel -c pytorch -c conda-forge
RUN conda run -n torch python -m ipykernel install --name=torch --display-name="Python (torch)"
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
# 1. fix plotly extension installing