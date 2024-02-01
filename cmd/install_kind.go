/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log/slog"
	"os"

	"github.com/k8s-school/ktbx/internal"
	"github.com/k8s-school/ktbx/resources"
	"github.com/spf13/cobra"
)

var kindVersion string

type KindInstallConfig struct {
	KindVersion string
}

// helmCmd represents the helm command
var kindCmd = &cobra.Command{
	Use:   "kind",
	Short: "Install Kubectl on the client machine",
	Long:  `Install Kubectl on the client machine. Sudo access is required to install components on the client machine.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Install kind")

		k := KindInstallConfig{
			KindVersion: kindVersion,
		}

		script := internal.FormatTemplate(resources.KindInstallScript, k)

		_, _, err := ExecCmd(script, false)
		if err != nil {
			slog.Error("Error while installing kind", "error", err)
			os.Exit(1)
		}
	},
}

func init() {
	installCmd.AddCommand(kindCmd)

	kindCmd.Flags().StringVar(&kindVersion, "kind-version", "v0.20.0", "Kind version to install")
}
