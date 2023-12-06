# jupyter 8087
#docker run -p 8087:8087 -e JUPYTER_ENABLE_LAB=yes -e JUPYTER_TOKEN=docker --name jupyter_ychi --mount type=bind,src=/share/Data/ychi,target=/share/Data/ychi --mount type=bind,src=/share/home/ychi,target=/share/home/ychi --mount type=bind,src=/shareb/ychi,target=/shareb/ychi zhuakexi/jupyterbio:conda_s2.8.1
docker run -it --rm -p 8888:8888
docker run -it --rm -p 8087:8087 --name bioenvs_ychi -e JUPYTER_PORT=8087 \
--user $(id -u) --group-add users -e CHOWN_HOME=yes \
-e RESTARTABLE=yes \
--mount type=bind,src=/share/Data/ychi,target=/share/Data/ychi --mount type=bind,src=/share/home/ychi,target=/share/home/ychi --mount type=bind,src=/shareb/ychi,target=/shareb/ychi --mount type=bind,src=/sharec/ychi/,target=/sharec/ychi zhuakexi/bioenvs:v0.2.6 /bin/bash \
