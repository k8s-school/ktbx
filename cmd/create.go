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
	"github.com/k8s-school/ktbx/resources"
)

var install []string
var count int

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
		createClusters(clusterName, count)
		// Write golang code to create a file inside a docker container using the ContainerExec operation of the docker API
	},
}

func init() {
	rootCmd.AddCommand(createCmd)

	single := "single"
	createCmd.PersistentFlags().BoolP(single, "s", false, "create a single node k8s cluster, take precedence over configuration file 'workers' parameter")
	viper.BindPFlag(single, createCmd.PersistentFlags().Lookup(single))

	cni := "cni"
	createCmd.PersistentFlags().StringP(cni, "c", "", "install custom CNI (cilium, calico), take precedence over configuration file 'cni' parameter")
	viper.BindPFlag("kind."+cni, createCmd.PersistentFlags().Lookup(cni))

	createCmd.PersistentFlags().StringSliceVarP(&install, "install", "i", []string{}, "install additional components (olm, argocd, argo-workflow)")

	createCmd.PersistentFlags().IntVar(&count, "count", 1, "number of clusters to create with numbered suffix (e.g., name-0, name-1, ...)")
}

func createClusters(baseName string, count int) {
	if count <= 1 {
		// Single cluster
		createSingleCluster(baseName)
	} else {
		// Multiple clusters with numbered suffix
		if baseName == "" {
			baseName = "kind"
		}
		for i := 0; i < count; i++ {
			clusterName := fmt.Sprintf("%s-%d", baseName, i)
			slog.Info("Creating cluster", "name", clusterName, "index", i+1, "total", count)
			createSingleCluster(clusterName)
		}
	}
}

func createSingleCluster(clusterName string) {
	_, err := exec.LookPath(internal.Kind)
	if err != nil {
		slog.Error("binary not found in PATH", "binary", internal.Kind)
		os.Exit(1)
	}

	c, err := internal.GetConfig()
	if err != nil {
		slog.Error("unable to get ktbx configuration", "error", err)
		os.Exit(1)
	}

	slog.Debug("ktbx configuration", "data", c)

	kindConfigFile, err := internal.GenerateKindConfigFile(c)
	if err != nil {
		slog.Error("unable to generate kind configuration file", "error", err)
		os.Exit(1)
	}

	optName := ""
	if clusterName != "" {
		optName = " --name " + clusterName
	}

	verbose_opt := ""
	if verbosity > 0 {
		verbose_opt = " --verbosity " + fmt.Sprintf("%d", verbosity)
	}

	cmd_tpl := "%v create cluster --config %v%v" + verbose_opt
	cmd := fmt.Sprintf(cmd_tpl, internal.Kind, kindConfigFile, optName)

	_, _, err = ExecCmd(cmd, false)
	if err != nil {
		slog.Error("kind create cluster failed", "error", err)
		os.Exit(1)
	}

	if len(c.Cni) != 0 {
		slog.Info("Install custom CNI", "name", c.Cni)

		switch c.Cni {
		case "calico":
			_, _, err = ExecCmd(resources.CalicoInstallScript, false)
		case "cilium":
			_, _, err = ExecCmd(resources.CiliumInstallScript, false)

		default:
			err = fmt.Errorf("unsupported cni plugin %s", c.Cni)
		}
		if err != nil {
			slog.Error("Error while installing cni", "error", err)
			os.Exit(1)
		}
	}

	slog.Info("Wait for Kubernetes nodes to be up and running")
	cmd = "kubectl wait --timeout=180s --for=condition=Ready node --all"
	_, _, err = ExecCmd(cmd, false)
	if err != nil {
		slog.Error("kubectl wait failed", "error", err)
		os.Exit(1)
	}

	for _, i := range install {
		switch i {
		case "olm":
			_, _, err = ExecCmd(resources.OlmInstallScript, false)
		case "argocd":
			_, _, err = ExecCmd(resources.ArgoCDInstallScript, false)
		case "argowf":
			_, _, err = ExecCmd(resources.ArgoWorkflowInstallScript, false)
		case "helm":
			_, _, err = ExecCmd(resources.HelmInstallScript, false)
		default:
			err = fmt.Errorf("unsupported component %s", i)
		}
		if err != nil {
			slog.Error("Error while installing component", "error", err)
			os.Exit(1)
		}
	}
}
