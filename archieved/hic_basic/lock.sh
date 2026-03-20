docker run --rm -v "$(pwd):/tmp" \
   zhuakexi/hic_basic:v0.4 /bin/bash -c "\
     micromamba env export --name base --explicit" > base.lock

docker run --rm -v "$(pwd):/tmp" \
   zhuakexi/hic_basic:v0.4 /bin/bash -c "\
     pip freeze | grep -E 'ipykernel|open3d|opencv' > requirements.txt"