FROM debian:bookworm as base

LABEL org.opencontainers.image.authors="Fabrice Jammes <fabrice.jammes@in2p3.fr>"

# RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

# Start with this long step not to re-run it on
# each Dockerfile update
RUN apt-get -y update && \
    apt-get -y install apt-utils && \
    apt-get -y upgrade && \
    apt-get -y clean

RUN apt-get -y update && \
    apt-get -y install curl bash-completion git gnupg jq \
    kubectx lsb-release locales make \
    nano openssh-client parallel \
    unzip vim wget zsh \
    apt-transport-https ca-certificates gnupg

# Uncomment en_US.UTF-8 for inclusion in generation
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen

# Generate locale
RUN locale-gen

# Install helm
ENV HELM_VERSION v3.10.3
RUN curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -- --version "$HELM_VERSION"

# Install argo client
ENV ARGOPROJ_HELPER_VERSION v3.4.4
ENV ARGOPROJ_SRC /tmp/argoproj-helper
RUN git clone --depth 1 -b "$ARGOPROJ_HELPER_VERSION" --single-branch https://github.com/k8s-school/argoproj-helper.git "$ARGOPROJ_SRC"
RUN "$ARGOPROJ_SRC"/argo-client-install.sh

# Install kubectl
ENV KUBECTL_VERSION 1.25.0
RUN wget -O /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install kustomize
ENV KUSTOMIZE_VERSION v3.8.4
RUN wget -O /tmp/kustomize.tgz \
    https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar zxvf /tmp/kustomize.tgz && \
    rm /tmp/kustomize.tgz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

# Install Stern
ENV STERN_VERSION 1.22.0
RUN wget -O /tmp/stern.tgz \
    https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz && \
    tar zxvf /tmp/stern.tgz && \
    rm /tmp/stern.tgz && \
    chmod +x stern && \
    mv stern /usr/local/bin/stern

ENV GO_VERSION 1.19.5
ENV GO_PKG go${GO_VERSION}.linux-amd64.tar.gz
RUN wget https://dl.google.com/go/$GO_PKG && \
    tar -xvf $GO_PKG && \
    mv go /usr/local

ENV GOROOT /usr/local/go
ENV GOPATH /go

RUN wget -O /etc/kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases

FROM base as full
RUN echo "Build full k8s-toolbox"

# Install Google cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin -y

# Install kubeval
ENV KUBEVAL_VERSION 0.15.0
RUN wget https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar xf kubeval-linux-amd64.tar.gz && \
    mv kubeval /usr/local/bin && \
    rm kubeval-linux-amd64.tar.gz

# Install cfssl
RUN wget -q --show-progress --https-only --timestamping \
    https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
    https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
    chmod o+x cfssl_linux-amd64 cfssljson_linux-amd64 && \
    mv cfssl_linux-amd64 /usr/local/bin/cfssl && \
    mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

# Install k9s
# RUN curl -L -o /tmp/k9s_Linux_x86_64.tar.gz "https://github.com/derailed/k9s/releases/download/v0.26.5/k9s_Linux_x86_64.tar.gz" && tar -xzf /tmp/k9s_Linux_x86_64.tar.gz && chmod +x "/tmp/k9s" && sudo mv "/tmp/k9s" "/usr/local/bin/k9s"
RUN curl -L -o /tmp/k9s_Linux_x86_64.tar.gz "https://github.com/derailed/k9s/releases/download/v0.26.5/k9s_Linux_x86_64.tar.gz" \
  && tar -xzf /tmp/k9s_Linux_x86_64.tar.gz -C "/tmp" \
  && chmod +x "/tmp/k9s" \
  && mv "/tmp/k9s" "/usr/local/bin/k9s"

ARG FORCE_GO_REBUILD=false
RUN $GOROOT/bin/go install -v github.com/k8s-school/clouder@latest

