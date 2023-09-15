[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)



 _    ___            _              _ _
| | _( _ ) ___      | |_ ___   ___ | | |__   _____  __
| |/ / _ \/ __|_____| __/ _ \ / _ \| | '_ \ / _ \ \/ /
|   < (_) \__ \_____| || (_) | (_) | | |_) | (_) >  <
|_|\_\___/|___/      \__\___/ \___/|_|_.__/ \___/_/\_\




# k8s-toolbox

Helper to install Kubernetes clusters, based on [kind], on any Linux system. Allow to easily setup:
- multi-nodes cluster
- use of Calico CNI
- use of an insecure private registry

Can be used for VMs launched by a  CI/CD platform, including [Github Action](https://github.com/k8s-school/k8s-toolbox/actions?query=workflow%3A"CI")

[![CI Status](https://github.com/k8s-school/k8s-toolbox/workflows/CI/badge.svg?branch=master)](https://github.com/k8s-school/k8s-toolbox/actions?query=workflow%3A"CI")

Support kind v0.10.0 and k8s v1.20

## Run kind on a workstation, in two lines of code

```shell
# Sudo access is required here
K8S_TOOLBOX_VERSION="v1.0.0-rc1"
curl -sfL https://raw.githubusercontent.com/k8s-school/k8s-toolbox/$K8S_TOOLBOX_VERSION/install.sh | bash

# Run a single node k8s cluster with kind
k8s-toolbox create -s

# Run a 3 nodes k8s cluster with kind
k8s-toolbox create

# Run a k8s cluster with Calico CNI
k8s-toolbox create -c

# Delete the kind cluster
k8s-toolbox delete

```

# Enabling k8s-toolbox auto-completion

## Example for bash on Linux

```shell
# install bash-completion
sudo apt-get install bash-completion

# Add the completion script to your .bashrc file
echo 'source <(k8s-toolbox completion bash)' >>~/.bashrc

# Apply changes
source ~/.bashrc
```

If you have an alias for `k8s-toolbox`, you can extend your shell's completion to work with this alias:

```shell
echo 'alias k8x=k8s-toolbox' >>~/.bashrc

echo 'complete -o default -F __start_k8s-toolbox k8x' >>~/.bashrc
```

## Run kind inside Github Actions


Check this **[tutorial: build a Kubernetes CI with Kind](https://k8s-school.fr/resources/en/blog/k8s-ci/)** in order to learn how to run [kind](https://github.com/kubernetes-sigs/kind) inside [Travis-CI](https://travis-ci.org/k8s-school/k8s-toolbox).

### Pre-requisites

* Create a Github repository for a given application, for example: https://github.com/<GITHUB_ACCOUNT>/<GITHUB_REPOSITORY>

### Setup

Enable Github Action by creating file `.github/workflow/itests.yaml`, based on template below:
```
name: "Integration tests"
on:
  push:
  pull_request:
    branches:
      - main
  itests:
    name: Run integration tests on Kubernetes
    runs-on: ubuntu-22.04
    needs: build
    env:
      GHA_BRANCH_NAME: ${{ github.head_ref || github.ref_name }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Create k8s/kind cluster
        run: |
	  VERSION="v1.0.1"
          curl -sfL https://raw.githubusercontent.com/k8s-school/k8s-toolbox/$VERSION/install.sh | bash
          k8s-toolbox create -s

     - run: |
          kubectl get nodes
          # Add scripts which deploy and tests application on Kubernetes

```


[kind]:https://github.com/kubernetes-sigs/kind


## Additional resource

* [Blog post: running Kubernetes in the ci pipeline](https://www.loodse.com/blog/2019-03-12-running-kubernetes-in-the-ci-pipeline-/)
