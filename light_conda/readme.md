# 整体架构
轻量的ubunt-cuda-micromamba docker image + portable conda env

# release
## hic_basic
0. v091

2024年12月间较为稳定的常用基本python包（见core_package_news.md）。  
在/share/home/ychi/mambaforge/envs/hic_basic_v091中第一次创建并导出为hic_basic_v091.explicit.yaml。  
可以在容器中使用
```shell
micromamba create -p xxx --yes --file hic_basic_v091.explicit.yaml
```
来复制。

1. v092
添加了open3d和opencv等不适合用conda装的包。  
```shell
singularity run -B /share/home/ychi:/share/home/ychi light_base_v01.sif micromamba create -p /share/home/ychi/mambaforge/envs/hic_basic_v092 --yes --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v091.lock
singularity run -B /share/home/ychi:/share/home/ychi light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v092 pip install opencv-contrib-python-headless open3d
```
2. [tmp] v093 添加了squidpy和tangram用来做ST分析。
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba create -p /share/home/ychi/mambaforge/envs/hic_basic_v093 --yes --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v091.lock
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v093 pip install opencv-contrib-python-headless open3d
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba install -p /share/home/ychi/mambaforge/envs/hic_basic_v093 pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v093 pip install squidpy>=1.1.0 tangram-sc==0.4.0
```
3. [tmp] v094 只添加了squidpy的版本，因为发现tangram依赖包版本过低，不适合放在现有环境里。
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba create -p /share/home/ychi/mambaforge/envs/hic_basic_v094 --yes --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v091.lock
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v094 pip install opencv-contrib-python-headless open3d
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/light_base_v01.sif micromamba install -p /share/home/ychi/mambaforge/envs/hic_basic_v094 -c conda-forge --yes squidpy
```
4. v095 基于light_base_02，使用新的lockfile，添加了pytorch，提升了numexpr的版本

安装conda包
```shell
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
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 python -c "import pandas as pd; print(pd.__version__)"
```
制作lockfile
```shell
# This won't work.
# singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba env export --explicit -p /share/home/ychi/mambafoge/envs/hic_basic_v095 > /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.lock

# Have to use the host conda. Don't know why
mamba list --explicit --md5 -p /share/home/ychi/mambaforge/envs/hic_basic_v095 > /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.lock
```
安装仅支持pip的包
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple opencv-contrib-python-headless open3d torch torchvision torchaudio
```
编辑模式安装hires_utils和hic_basic
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 pip install -e /share/home/ychi/dev/hires_utils
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v095 pip install -e /share/home/ychi/dev/hic_basic
```

5. v096 基于v095，添加cellrank
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/hic_basic_v096 --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.yaml
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple opencv-contrib-python-headless open3d torch torchvision torchaudio
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -e /share/home/ychi/dev/hires_utils
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -e /share/home/ychi/dev/hic_basic
# 安装bbknn,cellrank,palantir,fasthigashi
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba install -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/hic_basic_v096 -c conda-forge -c bioconda -c ruochiz bbknn cellrank palantir fasthigashi
# 安装genes2genes
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple genes2genes
# 安装scvi
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple gscvi-tools[optional]

# <!-- ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
# dask-expr 1.1.13 requires dask==2024.8.2, but you have dask 2024.7.1 which is incompatible.
# distributed 2024.8.2 requires dask==2024.8.2, but you have dask 2024.7.1 which is incompatible.
# pygpcca 1.0.4 requires jinja2==3.0.3, but you have jinja2 3.1.6 which is incompatible. -->

# 安装pyslingshot 
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple pyslingshot

# 安装ptorch dct
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple torch-dct

# 安装nbconvert
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba install -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/hic_basic_v096 -c conda-forge nbconvert

# 安装nodejs
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba install -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/hic_basic_v096 -c conda-forge nodejs
# 安装pytest
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple pytest

# 安装go相关库
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple goatools mygene gseapy obonet

# 安装scarches
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple scarches

# ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
# dask-expr 1.1.13 requires dask==2024.8.2, but you have dask 2024.7.1 which is incompatible.
# dask-expr 1.1.13 requires pandas>=2, but you have pandas 1.5.3 which is incompatible.
# genes2genes 0.2.0 requires pandas>=2.0.3, but you have pandas 1.5.3 which is incompatible.

# 安装doubletdetection
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/hic_basic_v096 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple doubletdetection
```


## bioR
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba install -p /share/home/ychi/mambaforge/envs/bioR -c conda-forge -y r-rmarkdown r-irkernel r-languageserver nbconvert

## scsv
```shell
# This takes hours and 6G memory and won't finish
# singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/scsv_v1 --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.yaml
# Use lockfile instead
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/scsv_v1 --file /share/home/ychi/dev/docker_files/light_conda/hic_basic_v095.lock
# cooler needs to be upgraded, otherwise:
# ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
# cooltools 0.7.1 requires cython, which is not installed.
# bioframe 0.7.2 requires numpy<2,>=1.10, but you have numpy 2.2.6 which is incompatible.
# cooler 0.10.2 requires numpy<2,>=1.9, but you have numpy 2.2.6 which is incompatible.
# numba 0.60.0 requires numpy<2.1,>=1.22, but you have numpy 2.2.6 which is incompatible.
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple --upgrade cooltools bioframe cooler numba
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple opencv-contrib-python-headless open3d torch torchvision torchaudio ultralytics
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple --upgrade numexpr
# in wd /share/home/ychi/dev/ChromaPalette
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip install .
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple --upgrade pybigwig cooltools
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip uninstall cooltools
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/scsv_v1 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple --upgrade cooltools
```

## torch clean
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/torch_clean python=3.10
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/torch_clean pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple torch torchvision
# use 2.6.0
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/torch_clean python=3.10
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/torch_clean pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple torch==2.6.0 torchvision==0.21.0
```

## torch clean mgt
```shell
mamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/torch_clean_mgt python=3.10
mamba run -p /share/home/ychi/mambaforge/envs/torch_clean_mgt pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple torch torchvision
mamba run -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/torch_clean_mgt python -c "import torch; print(torch.cuda.is_available())"
```
## gumnet

1. original requirements
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/gumnet python=3.6

singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/gumnet pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple keras==2.2.4 tensorflow-gpu==1.12.0 h5py==2.10.0
```

2. new keras_tf
```shell
singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba create -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/gumnet2 python=3.10

singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/gumnet2 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple tf-keras h5py

<!-- singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba install -y -r /share/home/ychi/mambaforge -p /share/home/ychi/mambaforge/envs/gumnet2 -c conda-forge h5py=2.10.0 -->

singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/gumnet2 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jupyter jupyter_client ipykernel nbconvert

singularity run -B /share/home/ychi:/share/home/ychi /shareb/ychi/ana/envs/light_base_02.sif micromamba run -p /share/home/ychi/mambaforge/envs/gumnet2 pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple pandas plotly xarray kaleido

```
