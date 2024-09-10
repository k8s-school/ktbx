/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log/slog"
	"os"
	"regexp"
	"strings"

	"github.com/k8s-school/ktbx/internal"
	"github.com/spf13/cobra"
	// Add this import
)

var clusterNamePattern string

func deleteCluster(clusterName string) {

	optName := ""
	if clusterName != "" {
		optName = " --name " + clusterName
	}

	cmd_tpl := "%v delete cluster%v"

	cmd := fmt.Sprintf(cmd_tpl, internal.Kind, optName)

	_, _, err := ExecCmd(cmd, false)
	if err != nil {
		slog.Error("Error while deleting cluster", "error", err)
		os.Exit(1)
	}
}

func getClusterByPattern(pattern string) []string {

	cmd_tpl := "%v get clusters"
	cmd := fmt.Sprintf(cmd_tpl, internal.Kind)

	out, _, err := ExecCmd(cmd, false)
	if err != nil {
		slog.Error("Error while getting clusters", "error", err)
		os.Exit(1)
	}

	slog.Debug("Get clusters", "output", out)
	r, _ := regexp.Compile(pattern)

	clusterMatches := make([]string, 0)

	clusters := strings.Split(out, "\n")

	for _, cluster := range clusters {
		if r.MatchString(cluster) {
			clusterMatches = append(clusterMatches, cluster)
		}
	}

	return clusterMatches

}

// deleteCmd represents the delete command
var deleteCmd = &cobra.Command{
	Use:   "delete",
	Short: "Delete a kind cluster",
	Run: func(cmd *cobra.Command, args []string) {

		if clusterNamePattern != "" {
			// Get the output of "kind get clusters"
			// Loop over the output and delete the clusters that match the pattern
			slog.Info("Delete kind cluster with pattern", "pattern", clusterNamePattern)
			clusters := getClusterByPattern(clusterNamePattern)
			slog.Debug("Cluster matches", "clusters", clusters)

		} else {

			slog.Info("Delete kind cluster")
			deleteCluster("")
		}
	},
}

func init() {
	rootCmd.AddCommand(deleteCmd)

	pattern := "pattern"
	deleteCmd.PersistentFlags().StringVarP(&clusterNamePattern, pattern, "p", "", "delete cluster by name regexp pattern")
}
