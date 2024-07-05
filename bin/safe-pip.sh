#!/bin/bash

echo 'Before you ask:  💛 You know how many Linux machines Ive ruined in Google because of a pip install? Three.' >&2

set -euo pipefail
which pip | grep .venv

pip "$@"

echo "👍 safe-pip correctly terminated"
