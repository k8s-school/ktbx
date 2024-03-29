/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log/slog"
	"os"

	"github.com/k8s-school/ktbx/resources"
	"github.com/spf13/cobra"
)

var telepresenceCmd = &cobra.Command{
	Use:   "telepresence",
	Short: "Install telepresence",
	Long:  `Install telepresence both on the client machine and on the k8s cluster. Sudo access is required to install components on the client machine.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Install telepresence")

		_, _, err := ExecCmd(resources.TelepresenceInstallScript, false)
		if err != nil {
			slog.Error("Error while installing telepresence", "error", err)
			os.Exit(1)
		}
	},
}

func init() {
	installCmd.AddCommand(telepresenceCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// helmCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// helmCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
