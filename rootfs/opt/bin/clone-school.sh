#!/bin/sh

set -e

cd $HOME

REPO=kubernetes-up-and-running
git clone https://github.com/$REPO/examples.git
cd examples
git checkout -q 36f0aa615b10617fea5f75ad0bf69d89d35b4164
git checkout -b school

cd $HOME
git clone https://github.com/luksa/kubernetes-in-action.git
git clone https://github.com/k8s-school/k8s-advanced