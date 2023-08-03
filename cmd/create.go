/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

func createCluster() {

	c := getKindHelperConfig()
	logConfiguration()
	generateKindConfigFile(c)

	cmd_tpl := "kind create cluster --config %v"
	cmd := fmt.Sprintf(cmd_tpl, kindConfigFile)

	ExecCmd(cmd)

	if c.UseCalico {
		logger.Info("Install Calico CNI")
		cmd = `kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml &&
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml`
		ExecCmd(cmd)

	}

	logger.Info("Wait for Kubernetes nodes to be up and running")
	cmd = "kubectl wait --timeout=180s --for=condition=Ready node --all"
	ExecCmd(cmd)
}

// createCmd represents the create command
var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a kind cluster",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Create k8s cluster")
		createCluster()
	},
}

func init() {
	rootCmd.AddCommand(createCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// createCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
