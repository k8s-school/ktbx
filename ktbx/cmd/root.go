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
	"encoding/json"
	"fmt"
	"os"
	"os/user"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"go.uber.org/zap"
)

var cfgFile string

var dryRun bool

var (
	logger      *zap.SugaredLogger
	verbosity   int
	clusterName string
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "k8s-toolbox",
	Short: "A high-level cli on top of kind",
	Long: `Creates kind-based Kubernetes cluster

Examples:
  # Create a configuration file for kind
  ./k8s-toolbox configgen

  # Create a single-node cluster using calico CNI
  ./k8s-toolbox create --single --calico

  # Delete kind cluster
  ./k8s-toolbox delete
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
	cobra.OnInitialize(initLogger, initConfig)

	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "configuration file (default to $CWD/.k8s-toolbox then $HOME/.k8s-toolbox)")
	rootCmd.PersistentFlags().StringVar(&clusterName, "name", "", "cluster name, default to 'kind'")

	rootCmd.PersistentFlags().BoolP("single", "s", false, "create a single node k8s cluster, take precedence over configuration file 'workers' parameter")
	rootCmd.PersistentFlags().BoolP("calico", "c", false, "install calico CNI, take precedence over configuration file 'usecalico' parameter")
	viper.BindPFlag("single", rootCmd.PersistentFlags().Lookup("single"))
	viper.BindPFlag("calico", rootCmd.PersistentFlags().Lookup("calico"))
}

// setUpLogs set the log output ans the log level
func initLogger() {

	// put current user if in a variable
	user, err := user.Current()
	if err != nil {
		panic(err)
	}

	outputPath := fmt.Sprintf("/tmp/k8s-toolbox-%s.log", user.Username)

	var loglevelStr string
	if verbosity == 0 {
		loglevelStr = "error"
	} else if verbosity == 1 {
		loglevelStr = "info"
	} else {
		loglevelStr = "debug"
	}

	rawJSON := []byte(`{
		"level": "` + loglevelStr + `",
		"encoding": "console",
		"outputPaths": ["stdout", "` + outputPath + `"],
		"errorOutputPaths": ["stderr"],
		"encoderConfig": {
		  "messageKey": "message",
		  "levelKey": "level",
		  "levelEncoder": "lowercase"
		}
	  }`)

	var cfg zap.Config
	if err := json.Unmarshal(rawJSON, &cfg); err != nil {
		panic(err)
	}
	_logger, err := cfg.Build()
	if err != nil {
		panic(err)
	}
	defer _logger.Sync()
	logger = _logger.Sugar()

}

// initConfig reads in config file and ENV variables if set.
func initConfig() {

	// Find home directory.
	home, err := os.UserHomeDir()
	cobra.CheckErr(err)

	cwd, err1 := os.Getwd()
	cobra.CheckErr(err1)

	defaultConfig := `kind:
  # Sets "127.0.0.1" as an extra Subject Alternative Names (SANs) for the API Server signing certificate.
  # See https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/#kubeadm-k8s-io-v1beta3-APIServer
  # localcertsans: true
  # Use calico CNI instead of kindnet
  # useCalico: true
  # Number of worker nodes
  workers: 3`

	viper.AddConfigPath(cwd)
	viper.AddConfigPath(home)
	viper.SetConfigType("yaml")

	viper.ReadConfig(strings.NewReader(defaultConfig))

	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		viper.SetConfigName(".k8s-toolbox/config")
	}

	// If a config file is found, read it in.

	if err := viper.MergeInConfig(); err == nil {
		logger.Debugf("Find user custom configuration %s", viper.ConfigFileUsed())
	} else {
		if _, err := os.Stat(viper.ConfigFileUsed()); err == nil {
			logger.Fatalf("Unable to read user custom configuration %s, %v", viper.ConfigFileUsed(), err)
		} else {
			logger.Debugf("Do not find user custom configuration %s, %v", viper.ConfigFileUsed(), err)
		}
	}

}
