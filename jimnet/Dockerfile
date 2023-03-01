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
#RUN apt-get update && apt-get -y install git gcc g++ liblapack-dev libblas-dev libboost-dev libarmadillo-dev libfftw3-dev
RUN mamba create -n jimnet -y jupyterlab python=3.8.10
COPY requirements.txt /opt/requirements.txt
RUN conda run -n jimnet --no-capture-output pip install -r /opt/requirements.txt -i https://mirrors.pku.edu.cn/pypi/web/simple
USER toolman
SHELL ["/bin/bash", "-c"]