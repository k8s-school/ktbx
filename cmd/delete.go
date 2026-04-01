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
	"time"

	"github.com/k8s-school/ktbx/internal"
	"github.com/spf13/cobra"
)

var clusterNamePattern string
var maxAgeHours int

// deleteCmd represents the delete command
var deleteCmd = &cobra.Command{
	Use:   "delete",
	Short: "Delete a kind cluster",
	Run: func(cmd *cobra.Command, args []string) {

		if clusterNamePattern != "" || maxAgeHours > 0 {
			// Get the output of "kind get clusters"
			// Loop over the output and delete the clusters that match the pattern and/or age criteria
			slog.Info("Delete kind cluster with filters", "pattern", clusterNamePattern, "maxAgeHours", maxAgeHours)
			clusters := getClusterByFilters(clusterNamePattern, maxAgeHours)
			slog.Debug("Cluster matches", "clusters", clusters)

			for _, cluster := range clusters {
				deleteCluster(cluster)
			}

		} else {
			slog.Info("Delete kind cluster", "name", clusterName)
			deleteCluster(clusterName)
		}
	},
}

func init() {
	rootCmd.AddCommand(deleteCmd)

	pattern := "pattern"
	deleteCmd.PersistentFlags().StringVarP(&clusterNamePattern, pattern, "p", "", "delete cluster by name regexp pattern")

	time := "time"
	deleteCmd.PersistentFlags().IntVarP(&maxAgeHours, time, "t", 0, "delete clusters older than specified hours")
}

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

func getClusterByFilters(pattern string, maxAgeHours int) []string {

	cmd_tpl := "%v get clusters"
	cmd := fmt.Sprintf(cmd_tpl, internal.Kind)

	out, _, err := ExecCmd(cmd, false)
	if err != nil {
		slog.Error("Error while getting clusters", "error", err)
		os.Exit(1)
	}

	slog.Debug("Get clusters", "output", out)

	var r *regexp.Regexp
	if pattern != "" {
		r, _ = regexp.Compile(pattern)
	}

	clusterMatches := make([]string, 0)
	clusters := strings.Split(out, "\n")

	for _, cluster := range clusters {
		cluster = strings.TrimSpace(cluster)
		if cluster == "" {
			continue
		}

		matchesPattern := pattern == "" || r.MatchString(cluster)
		matchesAge := maxAgeHours <= 0 || isClusterOlderThan(cluster, maxAgeHours)

		if matchesPattern && matchesAge {
			clusterMatches = append(clusterMatches, cluster)
		}
	}

	return clusterMatches
}

func isClusterOlderThan(clusterName string, maxAgeHours int) bool {
	// Get cluster creation time via Docker containers
	cmd := fmt.Sprintf("docker ps --filter \"label=io.x-k8s.kind.cluster=%s\" --format \"{{.CreatedAt}}\"", clusterName)

	out, _, err := ExecCmd(cmd, false)
	if err != nil {
		slog.Error("Error while getting cluster creation time", "cluster", clusterName, "error", err)
		return false
	}

	out = strings.TrimSpace(out)
	if out == "" {
		slog.Warn("No containers found for cluster", "cluster", clusterName)
		return false
	}

	// Parse the creation time
	createdAt, err := time.Parse("2006-01-02 15:04:05 -0700 MST", out)
	if err != nil {
		slog.Error("Error parsing creation time", "cluster", clusterName, "time", out, "error", err)
		return false
	}

	// Check if cluster is older than maxAgeHours
	ageThreshold := time.Now().Add(-time.Duration(maxAgeHours) * time.Hour)
	isOlder := createdAt.Before(ageThreshold)

	slog.Debug("Cluster age check", "cluster", clusterName, "createdAt", createdAt, "ageThreshold", ageThreshold, "isOlder", isOlder)

	return isOlder
}
