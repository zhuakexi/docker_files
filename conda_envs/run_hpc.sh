# jupyter 8087
docker run -p 8087:8087 -e JUPYTER_ENABLE_LAB=yes -e JUPYTER_TOKEN=docker --name jupyter_ychi --mount type=bind,src=/share/Data/ychi,target=/share/Data/ychi --mount type=bind,src=/share/home/ychi,target=/share/home/ychi --mount type=bind,src=/shareb/ychi,target=/shareb/ychi zhuakexi/jupyterbio:conda_s2.7