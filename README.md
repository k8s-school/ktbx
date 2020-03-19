[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)

# ⎈ k8s-toolbox
The ultimate Kubernetes client toolbox, embedded inside a customized container.

## What's embedded in that toolbox?

This toolbox offers a convenient set of popular Kubernetes client tools. Its
goal is to ease sysadmin, devops and developers life.

- [cfssl](https://github.com/cloudflare/cfssl): PKI and TLS toolkit https://cfssl.org/
- [clouder](https://github.com/k8s-school/clouder): One-liner to create Google Cloud GKE or GCE cluster
- [gnu-parallel](https://www.gnu.org/software/parallel/): GNU parallel is a shell tool for executing jobs in parallel using one or more computers
- [go-lang](https://golang.org): The go programming langage tools
- [gcloud](https://cloud.google.com/sdk/gcloud): Google Cloud command-line tool
- [helm](https://helm.sh/), and autocompletion: Helm is the package manager for Kubernetes
- **[kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)** and autocompletion: kubectl controls the Kubernetes cluster manager.
- [kubectl aliases](https://github.com/ahmetb/kubectl-aliases): Programmatically generated handy kubectl aliases. https://ahmet.im/blog/kubectl-aliases/
- [kubeval](https://github.com/instrumenta/kubeval): Validation of kubernetes YAML configurations
- [kustomize](https://github.com/kubernetes-sigs/kustomize): Customization of kubernetes YAML configurations
- [stern](https://github.com/wercker/stern): Multi pod and container log tailing for Kubernetes

## Installation

### Pre-requisites

- Ubuntu LTS is recommended
- Internet access
- `sudo` access
- And up and running Kubernetes cluster, and related KUBECONFIG file (see [Light speed Kubernetes installation](https://github.com/k8s-school/kind-travis-ci/blob/master/README.md))
- Install dependencies below:
```shell
sudo apt-get install curl docker.io

# then add current user to docker group and restart desktop session
sudo usermod -a -G docker <USER>
```
- Create work directory
```shell
WORKDIR=$HOME/k8s
mkdir $WORKDIR
cd $WORKDIR
```

### Launch
```shell
curl -lO https://raw.githubusercontent.com/k8s-school/k8s-toolbox/master/toolbox.sh
chmod +x toolbox.sh
./toolbox.sh
# If you have a valid KUBECONFIG file on your host, inside $HOME/.kube/config, command below will work fine:
kubectl get nodes
```
`toolbox` launch open a shell inside a Docker container.

**NOTE**: `toolbox` container `home` folder mount `$WORKDIR/homefs` host directory.

## How-to

- On the host machine, launch an editor or IDE and add Kubernetes applications code and scripts to `homefs` directory.
- Inside the `k8s-toolbox` container, directly run code and scripts.

## Google Cloud setup

### Pre-requisites

gmail account for regular users must have IAM roles below:
```
Compute OS Admin Login
Compute OS Login
Kubernetes Engine Developer
Service Account User
```
See https://cloud.google.com/compute/docs/instances/managing-instance-access#configure_users for additional informations.

### Initialize gcloud project

```
cp /opt/gcp/env-gcp.example.sh $HOME/env-gcp.sh
# Customize $HOME/env-gcp.sh
. $HOME/env-gcp.sh
gcloud auth login
gcloud config set project $PROJECT
```

### Connect to instances

``` shell
# ssh is an alias for  `gcloud compute ssh`
ssh clusX-0
```

### Follow Kubernetes install documentation 

[Official Kubernetes installation documentation with kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
[Simple Kubernetes installation procedure with kubeadm](https://www.k8s-school.fr/resources/en/blog/kubeadm/)


