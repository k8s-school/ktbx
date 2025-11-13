. /etc/bash_completion

PS1="{\[\e[32m\]\u\[\e[m\]@\[\e[36m\]k8s-toolbox\[\e[m\]:\W}$ "

export PATH=/opt/bin:$GOPATH/bin:$GOROOT/bin:$HOME/.krew/bin:$PATH
source <(helm completion bash)

# k8s cli helpers
source <(kubectl completion bash)
alias k='kubectl'
complete -F __start_kubectl k

# See https://github.com/ahmetb/kubectl-aliases
[ -f /etc/kubectl_aliases ] && source /etc/kubectl_aliases
# function kubectl() { echo "+ kubectl $@"; command kubectl $@; }

alias ssh="gcloud compute ssh"
alias kshell='kubectl run -i --rm --tty shell --image=ubuntu:22.04 -- bash'
alias ll="ls -la"
alias gst="git status"
alias gc="git commit"
alias gco="git checkout"
alias gcloud_get_project="gcloud config get-value project"
