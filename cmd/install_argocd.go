/*
Copyright © 2023 Fabrice Jammes fabrice.jammes@k8s-school.fr
*/
package cmd

import (
	"log/slog"
	"os"

	"github.com/k8s-school/ktbx/resources"
	"github.com/spf13/cobra"
)

// argocdCmd represents the argocd command
var argocdCmd = &cobra.Command{
	Use:   "argocd",
	Short: "Install ArgoCD",
	Long:  `Install ArgoCD operator using OLM`,
	Run: func(cmd *cobra.Command, args []string) {
		slog.Info("Install ArgoCD")

		_, _, err := ExecCmd(resources.ArgoCDInstallScript, false)
		if err != nil {
			slog.Error("Error while installing ArgoCD", "error", err)
			os.Exit(1)
		}
	},
}

func init() {
	installCmd.AddCommand(argocdCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// argocdCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// argocdCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
