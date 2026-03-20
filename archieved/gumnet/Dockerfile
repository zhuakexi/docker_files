# syntax=docker/dockerfile:1

FROM mambaorg/micromamba:git-6d896e6-cuda12.2.2-ubuntu22.04

# prepare libs for gumnet
# curl for vscode server
USER root
RUN apt-get update && apt-get install --no-install-recommends -y \
    git gcc g++ liblapack-dev libblas-dev libboost-dev libarmadillo-dev libfftw3-dev

COPY aitom /opt/aitom

RUN micromamba install -y -n base -c conda-forge \
    cython numpy=1.19.2 && \
    micromamba clean --all --yes
# build
RUN cd /opt/aitom && \
    bash build.sh