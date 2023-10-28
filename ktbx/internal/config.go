/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package internal

import (
	"os"
	"path"
	"strings"
	"text/template"

	"github.com/k8s-school/ciux/log"
	"github.com/k8s-school/k8s-toolbox/ktbx/resources"
	defaults "github.com/mcuadros/go-defaults"
	"github.com/mitchellh/mapstructure"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"gopkg.in/yaml.v2"
)

const Kind string = "kind"
const KindConfigFile string = "/tmp/kind-config.yaml"

type KtbxConfig struct {
	ExtraMountPath  string `mapstructure:"extramountpath" default:""`
	LocalCertSANs   bool   `mapstructure:"localcertsans" default:"false"`
	PrivateRegistry string `mapstructure:"privateregistry" default:""`
	Calico          bool   `mapstructure:"calico" default:"false"`
	Workers         uint   `mapstructure:"workers" default:"3"`
}

func LogConfiguration() {
	c := viper.AllSettings()
	bs, err := yaml.Marshal(c)
	if err != nil {
		log.Fatalf("unable to marshal ktbx configuration to YAML: %v", err)
	}
	log.Infof("Current ktbx configuration:\n%s", bs)
}

// viperUnmarshalKey unmarshals the value of a given key from Viper configuration into a struct.
// The key is a string representing the path to the value in the configuration.
// The out parameter is a pointer to the struct that will receive the unmarshalled data.
// Returns an error if the unmarshalling fails.
// viperUnmarshalKey unmarshals the value of the given key from Viper's configuration into the provided output object.
// The output object must be a pointer to a struct or a map.
// This is a workaround for the misbehavior reported here https://github.com/spf13/viper/issues/368
func viperUnmarshalKey(key string, out interface{}) error {
	in := viper.AllSettings()
	return mapstructure.Decode(in[key], out)
}

func format(s string, v interface{}) string {

	funcMap := template.FuncMap{
		"Iterate": func(count uint) []uint {
			var i uint
			var Items []uint
			for i = 0; i < count; i++ {
				Items = append(Items, i)
			}
			return Items
		},
	}

	t := new(template.Template).Funcs(funcMap)

	b := new(strings.Builder)
	err := template.Must(t.Parse(s)).Execute(b, v)
	if err != nil {
		log.Fatalf("Error while formatting string %s: %v", s, err)
	}
	return b.String()
}

func GetConfig() KtbxConfig {
	c := new(KtbxConfig)
	defaults.SetDefaults(c)
	err := viperUnmarshalKey(Kind, c)
	cobra.CheckErr(err)
	if viper.GetBool("single") {
		c.Workers = 0
	}
	return *c
}

func GenerateKindConfigFile(c KtbxConfig) {
	log.Infof("Generate kind configuration file: %s", KindConfigFile)

	f, err := os.Create(KindConfigFile)
	cobra.CheckErr(err)
	defer f.Close()

	kindconfig := applyTemplate(c)
	f.WriteString(kindconfig)
}

func applyTemplate(sc KtbxConfig) string {

	// TODO check https://github.com/helm/helm/blob/main/pkg/chartutil/values.go

	kindconfig := format(resources.KindConfigTemplate, &sc)
	return kindconfig
}

// readConfig reads in config file and ENV variables if set.
func ReadConfig() {

	var ktbxConfigFile = os.Getenv("KTBXCONFIG")
	if len(ktbxConfigFile) != 0 {
		viper.SetConfigFile(ktbxConfigFile)
	} else {
		cwd, err1 := os.Getwd()
		cobra.CheckErr(err1)
		viper.AddConfigPath(cwd)

		// Find home directory.
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		ktbxConfigPath := path.Join(home, ".ktbx")
		viper.AddConfigPath(ktbxConfigPath)
		viper.SetConfigName("config")
	}

	viper.SetConfigType("yaml")

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {

		log.Debugf("Find user custom configuration %s", viper.ConfigFileUsed())
		log.Debugf("Use config file: %s", viper.ConfigFileUsed())
	} else {
		log.Warnf("Fail reading configuration files in $KTBXCONFIG, $HOME/.ktbx, use default configuration", err, viper.ConfigFileUsed())
	}
}
