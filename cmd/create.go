/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"context"
	"fmt"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/filters"
	"github.com/spf13/cobra"

	"github.com/docker/docker/client"
)

func createCluster() {

	c := getK8sToolboxConfig()
	logConfiguration()
	generateKindConfigFile(c)

	cmd_tpl := "kind create cluster --config %v"
	cmd := fmt.Sprintf(cmd_tpl, kindConfigFile)

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

func createFileInContainer(cli *client.Client, containerID, filePath string, content []byte) error {

	cli, err := client.NewClientWithOpts(client.FromEnv)
	if err != nil {
		panic(err)
	}

	filter := types.ContainerListOptions{
		Filters: filters.NewArgs(
			filters.Arg("name", "kind*"),
		),
	}

	containers, err := cli.ContainerList(context.Background(), filter)
	if err != nil {
		panic(err)
	}

	for _, c := range containers {
		writeCloser, err := cli.ContainerExecAttach(context.Background(), c.ID, types.ExecStartCheck{
			Tty: true,
		})
		if err != nil {
			return err
		}
		defer writeCloser.Close()

		_, err = writeCloser.Conn.Write(content)
		if err != nil {
			return err
		}

		writeCloser.CloseWrite()
	}

	return nil
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
