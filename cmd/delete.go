/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log/slog"

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

	ExecCmd(cmd, false)

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
