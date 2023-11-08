#!/bin/bash

# Activate the conda base environment
. /miniconda3/etc/profile.d/conda.sh
conda activate base

# Launch the command provided by the user
exec "$@"
