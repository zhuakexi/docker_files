# syntax=docker/dockerfile:1

FROM suwangbio/hint:latest

# add user
ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID toolman && \
    adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID toolman && \
    adduser root toolman && \
    chown -R root:toolman /miniconda3 && \
    chmod -R g-w /miniconda3 && \
    chmod -R g+rX /miniconda3
# fix bugs
COPY coolToMatrix.py /miniconda3/lib/python3.6/site-packages/HiNT/coolToMatrix.py
# init conda
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
USER toolman