#!/bin/sh

set -e

cd "$HOME"

REPOS="https://github.com/k8s-school/openshift-advanced"

for r in $REPOS
do
    reposrc="$HOME/$(basename $r)"
    if [ ! -d "$reposrc" ]
    then
        echo "Cloning $reposrc"
        git clone "$r"
    else
        echo "Updating $reposrc"
        cd "$reposrc"
        git pull
    fi
done
cd "$HOME"
