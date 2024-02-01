/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log/slog"
	"os"

	"github.com/k8s-school/ktbx/internal"
	"github.com/spf13/cobra"
)

func deleteCluster() {

	optName := ""
	if clusterName != "" {
		optName = " --name" + clusterName
	}

	cmd_tpl := "%v delete cluster%v"

	cmd := fmt.Sprintf(cmd_tpl, internal.Kind, optName)

	_, _, err := ExecCmd(cmd, false)
	if err != nil {
		slog.Error("Error while deleting cluster", "error", err)
		os.Exit(1)
	}
}

// deleteCmd represents the delete command
var deleteCmd = &cobra.Command{
	Use:   "delete",
	Short: "Delete a kind cluster",
	Run: func(cmd *cobra.Command, args []string) {
		slog.Info("Delete %v cluster")
		deleteCluster()
	},
}

func init() {
	rootCmd.AddCommand(deleteCmd)
}
