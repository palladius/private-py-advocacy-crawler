#!/bin/bash

echo "Note. For this to work you need to execute these scripts from CLI (or source this script if you feel corageous)"
echo "Note2. to avoid proliferation of .venv dirs, I suggest "


echo 'cd $(git rev-parse --show-toplevel)'
echo "=> cd $(git rev-parse --show-toplevel)"
echo 'python3 -m venv .venv'
echo 'source .venv/bin/activate'

cd $(git rev-parse --show-toplevel)
python3 -m venv .venv
source .venv/bin/activate

#pip install google-cloud-bigquery
#pip install protobuf
#pip freeze > requirements.txt
