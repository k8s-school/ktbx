/*
Copyright © 2023 Fabrice Jammes fabrice.jammes@gmail.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
package cmd

import (
	"os"

	"github.com/k8s-school/ciux/log"
	"github.com/spf13/cobra"
)

var cfgFile string

var dryRun bool

var (
	verbosity   int
	clusterName string
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "ktbx",
	Short: "A high-level cli on top of kind",
	Long: `Creates kind-based Kubernetes cluster

Examples:
  # Create a configuration file for kind
  ktbx configgen

  # Create a single-node cluster using calico CNI
  ktbx create --single -c calico

  # Delete kind cluster
  ktbx delete
`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	// Run: func(cmd *cobra.Command, args []string) { },
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().IntVarP(&verbosity, "verbosity", "v", 0, "Verbosity level (-v0 for minimal, -v2 for maximum)")
	cobra.OnInitialize(initLogger)

	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().StringVar(&clusterName, "name", "", "cluster name, default to 'kind'")

}

// setUpLogs set the log output ans the log level
func initLogger() {
	log.Init(verbosity)
}
