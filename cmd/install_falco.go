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

// falcoCmd represents the argocd command
var falcoCmd = &cobra.Command{
	Use:     "falco",
	Aliases: []string{"fa"},
	Short:   "Install Falco",
	Long:    `Install Falco`,
	Run: func(cmd *cobra.Command, args []string) {
		slog.Info("Install Falco")

		_, _, err := ExecCmd(resources.FalcoInstallScript, false)
		if err != nil {
			slog.Error("Error while installing Falco", "error", err)
			os.Exit(1)
		}
	},
}

func init() {
	installCmd.AddCommand(falcoCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// argocdCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// argocdCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
