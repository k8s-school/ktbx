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

// olmCmd represents the olm command
var olmCmd = &cobra.Command{
	Use:   "olm",
	Short: "Install OLM",
	Long:  `Install Operator Lifecycle Manager (OLM)`,
	Run: func(cmd *cobra.Command, args []string) {
		slog.Info("Install OLM")

		_, _, err := ExecCmd(resources.OlmInstallScript, false)
		if err != nil {
			slog.Error("Error while installing OLM", "error", err)
			os.Exit(1)
		}
	},
}

func init() {
	installCmd.AddCommand(olmCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// olmCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// olmCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
