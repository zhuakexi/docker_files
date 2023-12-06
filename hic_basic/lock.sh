docker run --rm -v "$(pwd):/tmp" \
   zhuakexi/hic_basic:v0.4 /bin/bash -c "\
     micromamba env export --name base --explicit" > base.lock