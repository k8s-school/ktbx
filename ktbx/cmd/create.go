/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log"
	"os/exec"

	"github.com/spf13/cobra"
)

func createCluster() {
	_, err := exec.LookPath(kind_bin)
	if err != nil {
		log.Fatalf("'%v' not found in PATH", kind_bin)
	}

	c := getK8sToolboxConfig()
	logConfiguration()
	generateKindConfigFile(c)

	optName := ""
	if clusterName != "" {
		optName = " --name" + clusterName
	}

	cmd_tpl := "%v create cluster --config %v%v"
	cmd := fmt.Sprintf(cmd_tpl, kind_bin, kindConfigFile, optName)

	ExecCmd(cmd, false)

	if c.UseCalico {
		logger.Info("Install Calico CNI")
		cmd = `kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml &&
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml`
		ExecCmd(cmd, false)

	}

	logger.Info("Wait for Kubernetes nodes to be up and running")
	cmd = "kubectl wait --timeout=180s --for=condition=Ready node --all"
	ExecCmd(cmd, false)
}

// createCmd represents the create command
var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a kind cluster",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Create k8s cluster")
		createCluster()

		// Write golang code to create a file inside a docker container using the ContainerExec operation of the docker API

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
