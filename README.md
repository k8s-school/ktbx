[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)

# ⎈ k8s-toolbox
The ultimate Kubernetes client toolbox, embedded inside a customized container.

## What's in that toolbox?

- [cfssl](https://github.com/cloudflare/cfssl): PKI and TLS toolkit https://cfssl.org/
- [clouder](https://github.com/k8s-school/clouder): One-liner to create Google Cloud GKE or GCE cluster
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
- And up and running Kubernetes cluster, and related KUBECONFIG file
- Install dependencies below:
```shell
sudo apt-get install curl docker.io

# then add current user to docker group and restart desktop session
sudo usermod -a -G docker <USER>
```
- Create work directory, and copy KUBECONFIG file inside it
```shell
WORKDIR=$HOME/k8s-toolbox
mkdir -p $WORKDIR/homefs/.kube
cp $KUBECONFIG $WORKDIR/homefs/.kube/config
cd $WORKDIR
```

### Launch
```shell
curl -lO https://raw.githubusercontent.com/k8s-school/k8s-toolbox/master/toolbox.sh
./toolbox.sh
```


