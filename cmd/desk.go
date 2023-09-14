/*
Copyright © 2023 Fabrice Jammmes fabrice.jammes@k8s-school.fr
*/
package cmd

import (
	"fmt"

	"github.com/k8s-school/k8s-toolbox/resources"
	"github.com/spf13/cobra"
)

// deskCmd represents the desk command
var deskCmd = &cobra.Command{
	Use:   "desk",
	Short: "Lauch a interactive shell with k8s client tools installed",
	Long:  `Lauch a interactive shell with k8s client tools installed, inside a docker container, it mounts host directories $HOME/.kube in $HOME/.kube and homefs/ in $HOME`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Launch interactive desk")

		ExecCmd(resources.DeskRunScript)
	},
}

func init() {
	rootCmd.AddCommand(deskCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// deskCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// deskCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
