#!/bin/bash

CFG_FILE="$HOME/env-gcp.sh"
if [ -f "$CFG_FILE" ]; then
    >&2 echo "ERROR: missing $CFG_FILE"
fi
. "$HOME/env-gcp.sh"

gcloud auth login
gcloud config set project $PROJECT
