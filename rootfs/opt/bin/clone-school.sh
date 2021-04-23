#!/bin/sh

set -e

cd $HOME

REPO=k8s-school
git clone https://github.com/$REPO/examples.git
cd examples

cd $HOME
git clone https://github.com/luksa/kubernetes-in-action.git
git clone https://github.com/k8s-school/k8s-advanced
git clone https://github.com/k8s-school/k8s-school
