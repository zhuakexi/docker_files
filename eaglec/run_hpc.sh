docker run --rm -it --mount type=bind,src=/share/Data/ychi,target=/share/Data/ychi --mount type=bind,src=/share/home/ychi,target=/share/home/ychi --mount type=bind,src=/shareb/ychi,target=/shareb/ychi zhuakexi/eaglec:0.2 /bin/bash