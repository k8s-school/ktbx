#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash

set -euxo pipefail

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

echo "Install Falco"
helm install --replace falco --namespace falco --create-namespace \
  --set tty=true \
  --set falcosidekick.enabled=true \
  --set falcosidekick.webui.enabled=true \
  falcosecurity/falco

echo "Check that the Falco pods are running"
kubectl get pods -n falco

echo "Falco pod(s) might need a few seconds to start. Wait until they are ready..."
kubectl wait pods --for=condition=Ready --all -n falco --timeout=600s
