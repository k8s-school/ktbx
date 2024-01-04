/*
Copyright © 2023 Fabrice Jammes fabrice.jammes@k8s-school.fr
*/
package cmd

import (
	"log/slog"

	"github.com/k8s-school/ktbx/resources"
	"github.com/spf13/cobra"
)

// argocdCmd represents the argocd command
var argoWorkflowCmd = &cobra.Command{
	Use:   "argowf",
	Short: "Install Argo-workflow",
	Long:  `Install Argo-workflow`,
	Run: func(cmd *cobra.Command, args []string) {
		slog.Info("Install Argo-workflow")

		ExecCmd(resources.ArgoWorkflowInstallScript, false)
	},
}

func init() {
	installCmd.AddCommand(argoWorkflowCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// argocdCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// argocdCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
