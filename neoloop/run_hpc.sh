# this will create a docker container with random name and run bash
# --rm: remove container while exit
docker run --rm -it --mount type=bind,src=/share/Data/ychi,target=/share/Data/ychi --mount type=bind,src=/share/home/ychi,target=/share/home/ychi --mount type=bind,src=/shareb/ychi,target=/shareb/ychi zhuakexi/neoloop:0.2 /bin/bash
# using `exit` to quit the container 

# to run a certain command in the container:
# docker run --rm -it zhuakexi/neoloop:0.2 calculate-cnv -H SKNMC-MboI-allReps-filtered.mcool::resolutions/10000 -g hg38 -e MboI --output SKNMC_10k.CNV-profile.bedGraph