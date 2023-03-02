# jupyter 8086, docker
docker run -p 8086:8086 -e JUPYTER_ENABLE_LAB=yes -e JUPYTER_TOKEN=docker --name jimnet \
 --mount type=bind,src=/share/Data/ychi,target=/share/Data/ychi --mount type=bind,src=/share/home/ychi,target=/share/home/ychi --mount type=bind,src=/shareb/ychi,target=/shareb/ychi \
 jimnet:latest