/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log/slog"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"

	"github.com/k8s-school/ktbx/internal"
)

// createCmd represents the create command
var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a kind cluster",
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		internal.ReadConfig()
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Create k8s cluster")

		internal.LogConfiguration()
		createCluster()

		// Write golang code to create a file inside a docker container using the ContainerExec operation of the docker API

	},
}

func init() {
	rootCmd.AddCommand(createCmd)

	single := "single"
	createCmd.PersistentFlags().BoolP(single, "s", false, "create a single node k8s cluster, take precedence over configuration file 'workers' parameter")
	viper.BindPFlag(single, createCmd.PersistentFlags().Lookup(single))

	calico := "calico"
	createCmd.PersistentFlags().BoolP(calico, "c", false, "install calico CNI, take precedence over configuration file 'usecalico' parameter")
	viper.BindPFlag("kind."+calico, createCmd.PersistentFlags().Lookup(calico))

	auditlog := "auditlog"
	createCmd.PersistentFlags().BoolP(auditlog, "a", false, "enable audit log inside API server, take precedence over configuration file 'auditlog' parameter")
	viper.BindPFlag("kind."+auditlog, createCmd.PersistentFlags().Lookup(auditlog))
}

func createCluster() {
	_, err := exec.LookPath(internal.Kind)
	if err != nil {
		slog.Error("binary not found in PATH", "binary", internal.Kind)
		os.Exit(1)
	}

	c := internal.GetConfig()

	slog.Debug("ktbx configuration", "data", c)

	internal.GenerateKindConfigFile(c)

	optName := ""
	if clusterName != "" {
		optName = " --name" + clusterName
	}

	cmd_tpl := "%v create cluster --config %v%v"
	cmd := fmt.Sprintf(cmd_tpl, internal.Kind, internal.KindConfigFile, optName)

	ExecCmd(cmd, false)

	if c.Calico {
		slog.Info("Install Calico CNI")
		cmd = `kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml &&
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml`
		ExecCmd(cmd, false)

	}

	slog.Info("Wait for Kubernetes nodes to be up and running")
	cmd = "kubectl wait --timeout=180s --for=condition=Ready node --all"
	ExecCmd(cmd, false)
}
