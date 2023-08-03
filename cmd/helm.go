/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"

	"github.com/k8s-school/kind-helper/resources"
	"github.com/spf13/cobra"
)

// helmCmd represents the helm command
var helmCmd = &cobra.Command{
	Use:   "helm",
	Short: "Install Helm on the client machine",
	Long:  `Install Helm on the client machine. Sudo access is required to install components on the client machine.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("helm called")

		ExecCmd(resources.HelmInstallScript)
	},
}

func init() {
	installCmd.AddCommand(helmCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// helmCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// helmCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
