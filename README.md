[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)

# k8s-toolbox

Helper to install Kubernetes clusters, based on [kind], on any Linux system. Allow to easily setup:
- mono or multi-nodes development clusters
- use of Calico CNI
- use of an insecure private registry

Can be used for VMs launched by a  CI/CD platform, including [Github Action](https://github.com/k8s-school/k8s-toolbox/actions?query=workflow%3A"CI")

[![CI Status](https://github.com/k8s-school/ktbx/actions/workflows/e2e.yml/badge.svg?branch=main)](https://github.com/k8s-school/ktbx/actions/workflows/e2e.yml)

Support kind v0.10.0 and k8s v1.20

## Run kind on a workstation, in two lines of code

```shell
go install github.com/k8s-school/ktbx@v1.1.1-rc2

# Run a single node k8s cluster with kind
ktbx create -s

# Run a 3 nodes k8s cluster with kind
ktbx create

# Run a k8s cluster with Calico CNI
ktbx create -c

# Delete the kind cluster
ktbx delete

```

# Enabling k8s-toolbox auto-completion

## Example for bash on Linux

```shell
# install bash-completion
sudo apt-get install bash-completion

# Add the completion script to your .bashrc file
echo 'source <(ktbx completion bash)' >>~/.bashrc

# Apply changes
source ~/.bashrc
```

## Run kind inside Github Actions

### Pre-requisites

* Create a Github repository for a given application, for example: https://github.com/<GITHUB_ACCOUNT>/<GITHUB_REPOSITORY>

### Setup

Enable Github Action by creating file `.github/workflow/itests.yaml`, based on template below:
```
name: "Install k8s cluster"
on:
  push:
  pull_request:
    branches:
      - master

jobs:
  k8s-install:
    name: Install k8s
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: actions/setup-go@v3
        with:
          go-version: '^1.20.3'
      - name: Create k8s/kind cluster
        run: |
          go install github.com/k8s-school/ktbx@main
          ktbx create -s
          ktbx install kubectl
      - name: Install and test application
        run: |
          kubectl create deployment my-nginx --image=nginx
          kubectl expose deployment my-nginx --port=80
```

[kind]:https://github.com/kubernetes-sigs/kind
