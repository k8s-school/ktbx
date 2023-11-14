/*
Copyright © 2023 Fabrice Jammmes fabrice.jammes@k8s-school.fr
*/
package cmd

import (
	"fmt"

	"github.com/k8s-school/k8s-toolbox/ktbx/resources"
	"github.com/spf13/cobra"
)

var showDockerCmd bool

// deskCmd represents the desk command
var deskCmd = &cobra.Command{
	Use:     "desk",
	Aliases: []string{"d"},
	Short:   "Lauch a interactive shell with k8s client tools installed",
	Long:    `Lauch a interactive shell with k8s client tools installed, inside a docker container, it mounts host directories $HOME/.kube in $HOME/.kube and homefs/ in $HOME`,
	Run: func(cmd *cobra.Command, args []string) {

		if showDockerCmd {
			// TODO escape ' in command
			script := "SHOWDOCKERCMD=true\n" + resources.DeskRunScript
			ExecCmd(script, false)
		} else {
			fmt.Println("Launch interactive desk")
			ExecCmd(resources.DeskRunScript, true)
		}

	},
}

func init() {
	rootCmd.AddCommand(deskCmd)

	deskCmd.PersistentFlags().BoolVar(&showDockerCmd, "dry-run", false, "Print docker command")

}
