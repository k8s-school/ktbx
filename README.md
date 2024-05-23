[<img src="k8s-toolbox.png" alt="k8s-toolbox, all in one" height="50" />](https://github.com/k8s-school/ktbx)

# k8s-toolbox, alias ktbx

Helper to install Kubernetes clusters, based on [kind], on any Linux system. Allow to easily setup:
- mono or multi-nodes development clusters
- use of Calico CNI
- use of an insecure private registry

Can be used for runners launched by a  CI/CD platform, including [Github Action](https://github.com/k8s-school/k8s-toolbox/actions?query=workflow%3A"CI")

[![CI Status](https://github.com/k8s-school/ktbx/actions/workflows/e2e.yml/badge.svg?branch=main)](https://github.com/k8s-school/ktbx/actions/workflows/e2e.yml)

Support `kind-v0.20.0` and `k8s-v1.25+`

## Pre-requisites

- go 1.21+
- `sudo` access
- [docker], [podman] or [nerdctl]

## Run kind on a workstation, in two lines of code

```shell
go install github.com/k8s-school/ktbx@v1.1.1-rc17

# Install kind
ktbx install kind

# Run a single node k8s cluster with kind
ktbx create -s

# Run a 3 nodes k8s cluster with kind
ktbx create

# Run a k8s cluster with Calico CNI
ktbx create -c

# Delete the kind cluster
ktbx delete
```

An optional configuration file, for more advanced tuning, can be created in `$HOME/.ktbx/config`. The project provides a [documented example of this file](./dot-config.example).

## Installing cluster tools with ktbx:

ktbx simplifies the installation of kubectl, OLM, ArgoCD, and Argo Workflows in any Kubernetes cluster where users have appropriate access rights. Streamline your Kubernetes tool setup with ktbx, saving time and ensuring consistency across environments.

```shell
# Install kubectl
ktbx install kubectl

# Install OLM
ktbx install olm

# Install argoCD
ktbx install argocd

# Install argo-workflows
ktbx install argowf

# Install helm
ktbx install helm

# Install telepresence
ktbx install telepresence
```

## Interactive k8s administration with ktbx:

`ktbx` launches on user worstation an interactive container packed with essential sysadmin tools for Kubernetes, including `k9s`, `auto-completion`, `kubens`, `kubectx`, `rbac-tool`, and aliases. Simplify Kubernetes management with ktbx's comprehensive toolset.

```bash
# Launch k8s-toolbox desktop
ktbx desk
# Example: audit cluster authorizations
{user@k8s-toolbox:~} rbac-tool analysis
```

## Enabling k8s-toolbox auto-completion

### Example for bash on Linux

```shell
# install bash-completion
sudo apt-get install bash-completion

# Add the completion script to your .bashrc file
echo 'source <(ktbx completion bash)' >>~/.bashrc

# Apply changes
source ~/.bashrc
```

## Run Kubernetes inside Github Actions

### Pre-requisite

Create a Github repository for a given application, for example: https://github.com/<GITHUB_ACCOUNT>/<GITHUB_REPOSITORY>

### Setup

Enable Github Action by creating file `.github/workflow/itests.yaml`, based on template below:
```yaml
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
      # Optional
      - name: Install olm and argocd operators
        run: |
          ktbx install olm
          ktbx install argocd
      # Optional
      - name: Install argo-workflows
        run: |
          ktbx install argowf
      - name: Install and test application
        run: |
          kubectl create deployment my-nginx --image=nginx
          kubectl expose deployment my-nginx --port=80
```

[kind]:https://github.com/kubernetes-sigs/kind
[docker]: https://www.docker.com/
[podman]: https://podman.io/
[nerdctl]: https://github.com/containerd/nerdctl
[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)
