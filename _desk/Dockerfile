FROM golang:1.25.1-trixie AS base

LABEL org.opencontainers.image.authors="Fabrice Jammes <fabrice.jammes@in2p3.fr>"

# RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

# Start with this long step not to re-run it on
# each Dockerfile update
RUN apt-get -y update && \
    apt-get -y install apt-utils && \
    apt-get -y upgrade && \
    apt-get -y clean

RUN apt-get -y update && \
    apt-get -y install auditd curl bash-completion git gnupg jq \
    kubectx lsb-release locales make \
    nano openssh-client parallel \
    unzip vim wget zsh \
    apt-transport-https ca-certificates gnupg

# Uncomment en_US.UTF-8 for inclusion in generation
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen

# Generate locale
RUN locale-gen

# Install helm
ENV HELM_VERSION v3.16.2
RUN curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -- --version "$HELM_VERSION"

# Install argo client
ENV ARGOPROJ_HELPER_VERSION v3.4.4
ENV ARGOPROJ_SRC /tmp/argoproj-helper
RUN git clone --depth 1 -b "$ARGOPROJ_HELPER_VERSION" --single-branch https://github.com/k8s-school/argoproj-helper.git "$ARGOPROJ_SRC"
RUN "$ARGOPROJ_SRC"/argo-client-install.sh

# Install kubectl
ENV KUBECTL_VERSION v1.34.1
RUN wget -O /usr/local/bin/kubectl \
    https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
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
ENV STERN_VERSION v1.33.0
RUN go install github.com/stern/stern@$STERN_VERSION

RUN wget -O /etc/kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases

FROM base AS full
RUN echo "Build full k8s-toolbox"

# Install Google cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-cli -y

# Install kubesec
ENV KUBESEC_VERSION v2.14.2
RUN go install github.com/controlplaneio/kubesec/v2@${KUBESEC_VERSION}

# Install kubelinter
ENV KUBE_LINTER v0.7.6
RUN go install golang.stackrox.io/kube-linter/cmd/kube-linter@${KUBE_LINTER}

# Install k9s
# RUN curl -L -o /tmp/k9s_Linux_x86_64.tar.gz "https://github.com/derailed/k9s/releases/download/v0.26.5/k9s_Linux_x86_64.tar.gz" && tar -xzf /tmp/k9s_Linux_x86_64.tar.gz && chmod +x "/tmp/k9s" && sudo mv "/tmp/k9s" "/usr/local/bin/k9s"
ENV K9S_VERSION v0.50.10
RUN curl -L -o /tmp/k9s_Linux.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" \
  && tar -xzf /tmp/k9s_Linux.tar.gz -C "/tmp" \
  && chmod +x "/tmp/k9s" \
  && mv "/tmp/k9s" "/usr/local/bin/k9s"

ARG FORCE_GO_REBUILD=false
RUN go install -v github.com/k8s-school/clouder@v0.0.1-rc6
RUN go install -v github.com/k8s-school/ink@v0.0.1-rc3

# Install rbac-tools
# RUN curl https://raw.githubusercontent.com/alcideio/rbac-tool/master/download.sh | bash

COPY rootfs /
