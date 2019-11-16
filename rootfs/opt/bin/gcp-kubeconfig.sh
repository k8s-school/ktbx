#!/bin/sh

set -e
set -x

CFG_FILE="$HOME/env-gcp.sh"
if [ -f "$CFG_FILE" ]; then
    >&2 echo "ERROR: missing $CFG_FILE"
    exit 2
fi
. "$HOME/env-gcp.sh"

gcloud container clusters get-credentials "$CLUSTER" --zone $REGION --project "$PROJECT"
