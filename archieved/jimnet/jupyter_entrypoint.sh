#!/bin/bash --login
# The --login ensures the bash configuration is loaded,
# enabling Conda.

# Enable strict mode.
set -euo pipefail
# ... Run whatever commands ...

# Temporarily disable strict mode and activate conda:
set +euo pipefail
#conda activate myenv
source /opt/conda/bin/activate jimnet

# Re-enable strict mode:
set -euo pipefail

# exec the final command:
exec jupyter lab --ip=0.0.0.0 --port=8086 --no-browser

# invoke this script in docker file with:
# COPY jupyter_entrypoint.sh ./
# ENTRYPOINT ["./jupyter_entrypoint.sh"]