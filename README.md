[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)

# k8s-toolbox
The ultimate Kubernetes client toolbox, embedded inside a customized container.

## Installation

### Pre-requisites

- Ubuntu LTS is recommended
- Internet access
- `sudo` access
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


