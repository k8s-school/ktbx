package resources

import (
	_ "embed"
)

//go:embed install-olm.sh
var OlmInstallScript string

//go:embed install-argocd.sh
var ArgoCDInstallScript string

//go:embed install-argoworkflows.sh
var ArgoWorkflowInstallScript string

//go:embed install-cilium.sh
var CiliumInstallScript string

//go:embed desk.sh
var DeskRunScript string

//go:embed kind-config.yaml
var KindConfigTemplate string

//go:embed install-helm.sh
var HelmInstallScript string

//go:embed install-kind.sh
var KindInstallScript string

//go:embed install-kubectl.sh
var KubectlInstallScript string

//go:embed install-telepresence.sh
var TelepresenceInstallScript string
