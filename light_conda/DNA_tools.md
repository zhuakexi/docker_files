1. v01 基于light_base_02的第一个版本，安装了必要的格式转换等工具
```
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/DNA_tools_v01 --file /share/home/ychi/dev/docker_files/light_conda/DNA_tools_v01.yaml
```
