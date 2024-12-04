# syntax=docker/dockerfile:1

FROM mambaorg/micromamba:git-6d896e6-cuda12.2.2-ubuntu22.04

# prepare libs for open3d
# curl for vscode server
USER root
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
    libgomp1 \
    git less curl \
    && rm -rf /var/lib/apt/lists/*