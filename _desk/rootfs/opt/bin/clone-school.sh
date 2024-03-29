#!/bin/sh

set -e

cd "$HOME"

REPOS="https://github.com/k8s-school/examples https://github.com/k8s-school/k8s-advanced https://github.com/k8s-school/k8s-school https://github.com/k8s-school/openshift-advanced"

for r in $REPOS
do
    reposrc="$HOME/$(basename $r)"
    if [ ! -d "$reposrc" ]
    then
        echo "Cloning $reposrc"
        git clone "$r" $reposrc
    else
        echo "Updating $reposrc"
        cd "$reposrc"
        git pull
	cd $HOME
    fi
done
cd "$HOME"
