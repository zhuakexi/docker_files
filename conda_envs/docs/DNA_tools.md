# DNA_tools Notes

1. v01 基于 `light_base_02` 的第一个版本，安装了必要的格式转换等工具。

```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/DNA_tools_v01 --file /share/home/ychi/dev/docker_files/conda_envs/DNA_tools_v01.yaml
```
