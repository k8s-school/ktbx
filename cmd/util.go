package cmd

import (
	"strings"
	"text/template"

	"github.com/spf13/viper"
	"gopkg.in/yaml.v2"
)

func logConfiguration() {
	c := viper.AllSettings()
	bs, err := yaml.Marshal(c)
	if err != nil {
		logger.Fatalf("unable to marshal kind-helper configuration to YAML: %v", err)
	}
	logger.Infof("Current kind-helper configuration:\n%s", bs)
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

	t, b := new(template.Template).Funcs(funcMap), new(strings.Builder)
	err := template.Must(t.Parse(s)).Execute(b, v)
	if err != nil {
		logger.Fatalf("Error while formatting string %s: %v", s, err)
	}
	return b.String()
}
