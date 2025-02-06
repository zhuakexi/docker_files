# 整体架构
轻量的ubunt-cuda-micromamba docker image + portable conda env

# release
0. v091

2024年12月间较为稳定的常用基本python包（见core_package_news.md）。  
在/share/home/ychi/mambaforge/envs/hic_basic_v091中第一次创建并导出为hic_basic_v091.explicit.yaml。  
可以在容器中使用
```
micromamba create -p xxx --yes --file hic_basic_v091.explicit.yaml
```
来复制。

1. v092
添加了open3d和opencv等不适合用conda装的包。  
```
singularity run -B /share/home/ychi:/share/home/ychi light_base_v01.sif micromamba create -p /share/home/ychi/mambaforge/envs/hic_basic_v092 --yes --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v091.lock
singularity run -B /share/home/ychi:/share/home/ychi light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v092 pip install opencv-contrib-python-headless open3d
```
2. [tmp] v093 添加了squidpy和tangram用来做ST分析。
```
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba create -p /share/home/ychi/mambaforge/envs/hic_basic_v093 --yes --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v091.lock
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v093 pip install opencv-contrib-python-headless open3d
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba install -p /share/home/ychi/mambaforge/envs/hic_basic_v093 pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v093 pip install squidpy>=1.1.0 tangram-sc==0.4.0
```
3. [tmp] v094 只添加了squidpy的版本，因为发现tangram依赖包版本过低，不适合放在现有环境里。
```
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba create -p /share/home/ychi/mambaforge/envs/hic_basic_v094 --yes --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v091.lock
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v094 pip install opencv-contrib-python-headless open3d
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba install -p /share/home/ychi/mambaforge/envs/hic_basic_v094 -c conda-forge --yes squidpy
```
4. v095 基于light_base_02，使用新的lockfile，添加了pytorch，提升了numexpr的版本

安装conda包
```
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/hic_basic_v095 -c conda-forge -c bioconda \
    python=3.10 numpy=1.23.1 pandas=2.2.3 numexpr=2.8.4 xarray scikit-learn=1.5.2 scikit-image=0.24.0 scikit-misc=0.1.4 scipy=1.13.1 umap-learn \
    pyarrow h5py openpyxl xlrd pytables h5netcdf netcdf4 \
    matplotlib seaborn plotly python-kaleido pymol-open-source \
    cooler cooltools scanpy scvelo \
    anndata pysam pybedtools pybigwig loompy rmsd upsetplot \
    jupyter jupyter_client ipykernel nbconvert
# 也可以使用下面命令，hic_basic_v095.yaml是手动写的dependecies文件，conda可以直接从这个文件安装指定的包
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/hic_basic_v095 --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.yaml
```
test
```
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 python -c "import pandas as pd; print(pd.__version__)"
```
制作lockfile
```
# This won't work.
# singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba env export --explicit -p /share/home/ychi/mambafoge/envs/hic_basic_v095 > /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.lock

# Have to use the host conda. Don't know why
mamba list --explicit --md5 -p /share/home/ychi/mambaforge/envs/hic_basic_v095 > /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.lock
```
安装仅支持pip的包
```
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple opencv-contrib-python-headless open3d torch torchvision torchaudio
```