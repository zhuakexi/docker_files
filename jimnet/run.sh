docker run --gpus all -it -p 8086:8086 -e JUPYTER_ENABLE_LAB=yes -e JUPYTER_TOKEN=docker --name jimnet \
 --mount type=bind,src=/home/zhuakexi,target=/home/toolman jimnet:latest