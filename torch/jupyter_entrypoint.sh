#!/bin/bash

# Activate the conda base environment
. /opt/conda/etc/profile.d/conda.sh
conda activate lab

# launch jupyter lab
exec jupyter lab --ip=0.0.0.0 --port=8086 --no-browser

# invoke this script in docker file with:
# COPY jupyter_entrypoint.sh ./
# ENTRYPOINT ["./jupyter_entrypoint.sh"]