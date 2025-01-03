/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package internal

import (
	"errors"
	"os"
	"path"
	"strings"
	"text/template"

	"github.com/k8s-school/ktbx/resources"
	defaults "github.com/mcuadros/go-defaults"
	"github.com/mitchellh/mapstructure"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"golang.org/x/exp/slog"
	"gopkg.in/yaml.v2"
)

const Kind string = "kind"
const KindConfigFilename string = "kind-config.yaml"

type KtbxConfig struct {
	AuditPolicy     string `mapstructure:"auditPolicy" default:""`
	ExtraMountPath  string `mapstructure:"extraMountPath" default:""`
	LocalCertSANs   bool   `mapstructure:"localCertSans" default:"false"`
	PrivateRegistry string `mapstructure:"privateRegistry" default:""`
	Cni             string `mapstructure:"cni" default:""`
	Workers         uint   `mapstructure:"workers" default:"3"`
}

func LogConfiguration() {
	c := viper.AllSettings()
	bs, err := yaml.Marshal(c)
	if err != nil {
		slog.Error("unable to marshal ktbx configuration to YAML", "error", err)
		os.Exit(1)
	}
	slog.Info("Current ktbx configuration", "data", bs)
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

// FormatTemplate formats a string using a template and a struct.
func FormatTemplate(tplStr string, v interface{}) (string, error) {

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
	err := template.Must(t.Parse(tplStr)).Execute(b, v)
	if err != nil {
		slog.Error("failed formatting string", "string", tplStr, "erro", err)
	}
	return b.String(), err
}

func GetConfig() (KtbxConfig, error) {
	c := new(KtbxConfig)
	defaults.SetDefaults(c)
	err := viperUnmarshalKey(Kind, c)
	if err != nil {
		slog.Error("unable to unmarshal ktbx configuration", "error", err)
		return *c, err
	}

	if viper.GetBool("single") {
		c.Workers = 0
	}

	if c.AuditPolicy != "" {
		info, err := os.Stat(c.AuditPolicy)
		if err != nil {
			slog.Error("Audit policy file not found", "file", c.AuditPolicy, "error", err)
			return *c, errors.New("audit policy file not found: " + c.AuditPolicy)
		}

		if info.IsDir() {
			slog.Error("Audit policy file is a directory", "file", c.AuditPolicy)
			// return error
			return *c, errors.New("audit policy file is a directory: " + c.AuditPolicy)
		}
	}

	return *c, nil
}

func GenerateKindConfigFile(c KtbxConfig) (string, error) {
	slog.Info("Generate kind configuration file", "file", KindConfigFilename)

	tmpdir, err := os.MkdirTemp("/tmp", "kind-config")
	if err != nil {
		slog.Error("unable to create temporary directory", "error", err)
		return "", err
	}

	kindConfigFile := path.Join(tmpdir, KindConfigFilename)

	f, err := os.Create(kindConfigFile)
	if err != nil {
		slog.Error("unable to create kind configuration file", "error", err)
		return "", err
	}
	defer f.Close()

	kindconfig, err := applyTemplate(c)
	slog.Debug("kind configuration", "data", kindconfig)
	f.WriteString(kindconfig)
	return kindConfigFile, err
}

func applyTemplate(sc KtbxConfig) (string, error) {

	// TODO check https://github.com/helm/helm/blob/main/pkg/chartutil/values.go

	kindconfig, err := FormatTemplate(resources.KindConfigTemplate, &sc)
	return kindconfig, err
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
		slog.Debug("Use config file", "file", viper.ConfigFileUsed())
	} else {
		slog.Warn("Fail reading configuration files in $KTBXCONFIG, $HOME/.ktbx, switch to default configuration", "error", err)
	}
}
