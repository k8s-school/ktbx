package resources

import (
	_ "embed"
)

//go:embed olm-install.sh
var OlmInstallScript string

//go:embed argocd-install.sh
var ArgoCDInstallScript string

//go:embed kind-config.yaml
var KindConfigTemplate string

//go:embed helm-install.sh
var HelmInstallScript string

//go:embed kubectl-install.sh
var KubectlInstallScript string
