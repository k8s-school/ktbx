/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"log"
	"os"

	"github.com/k8s-school/kind-helper/resources"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

const KIND string = "kind"
const kindConfigFile = "/tmp/kind-config.yaml"

// configgenCmd represents the configgen command
var configgenCmd = &cobra.Command{
	Use:   "configgen",
	Short: "Generate a configuration file for kind",
	Long: `Generate a configuration file for kind based
on .kind-helper high-level configuration file
`,
	Run: func(cmd *cobra.Command, args []string) {
		c := getKindHelperConfig()
		generateKindConfigFile(c)
	},
}

type KindHelperConfig struct {
	ExtraMountPath  string `mapstructure:"extramountpath"`
	LocalCertSANs   bool   `mapstructure:"localcertsans"`
	PrivateRegistry string `mapstructure:"privateregistry"`
	UseCalico       bool   `mapstructure:"usecalico"`
	Workers         uint   `mapstructure:"workers"`
}

func init() {
	rootCmd.AddCommand(configgenCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// configgenCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// configgenCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}

func getKindHelperConfig() KindHelperConfig {

	var c KindHelperConfig

	if err := viper.UnmarshalKey(KIND, &c); err != nil {
		logger.Fatalf("Error while getting kind-helper configuration: %v", err)
	}

	c.UseCalico = viper.GetBool("calico")
	if viper.GetBool("single") {
		c.Workers = 0
	}
	return c
}

func generateKindConfigFile(c KindHelperConfig) {
	logger.Infof("Generate kind configuration file: %s", kindConfigFile)
	logger.Debugf("for configuration: %v", c)

	f, e := os.Create(kindConfigFile)
	if e != nil {
		log.Fatal(e)
	}
	defer f.Close()

	kindconfig := applyTemplate(c)
	f.WriteString(kindconfig)
}

func applyTemplate(sc KindHelperConfig) string {

	// TODO check https://github.com/helm/helm/blob/main/pkg/chartutil/values.go

	kindconfig := format(resources.KindConfigTemplate, &sc)
	return kindconfig
}
