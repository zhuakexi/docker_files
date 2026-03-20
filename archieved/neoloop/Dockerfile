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
# install valid packages
RUN conda config --add channels r
RUN conda config --add channels defaults
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN mamba install -n base cooler matplotlib pyensembl pybigwig intervaltree scikit-learn=1.1.2 joblib=1.1.0 rpy2 r-mgcv
RUN apt-get update && apt-get -y install git gcc g++
RUN conda run -n base --live-stream pip install -U neoloop TADLib pomegranate -i https://mirrors.pku.edu.cn/pypi/web/simple
# Add an entrypoint script to activate the conda base environment
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# launching
USER toolman