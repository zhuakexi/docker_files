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
# adding apt packages
RUN apt-get update && apt-get -y install gcc g++
RUN conda install -y -c conda-forge mamba
# install valid packages
RUN conda config --add channels defaults
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN mamba install -n base scikit-learn statsmodels matplotlib cooler pyBigWig pyensembl python=3.8 joblib=1.0.1 tensorflow=2 cython=0.29.24
RUN conda run -n base --live-stream pip install -U eaglec -i https://mirrors.pku.edu.cn/pypi/web/simple
USER toolman
# one of the two
# 1. using conda run
# Make RUN commands use the new environment:
# SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]
# 2. using source
RUN /bin/bash -c "source /opt/conda/bin/activate"
# launching
