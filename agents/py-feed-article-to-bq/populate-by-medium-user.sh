#!/bin/bash

MEDIUM_USER="${1:-rsamborski}"


.venv/bin/python3 main.py \
    --metadata "../medium-articles-by-user/outputs/medium-latest-articles.$MEDIUM_USER.metadata.json" \
    --articles "../medium-articles-by-user/outputs/medium-latest-articles.$MEDIUM_USER.txt.json"
