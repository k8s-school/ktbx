package internal

import (
	"log"
	"os"
	"path/filepath"
	"testing"

	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
)

func setupSuite(tb testing.TB) func(tb testing.TB) {
	log.Println("setup suite")

	assert := assert.New(tb)
	wd, err := os.Getwd()
	assert.NoError(err)
	parent := filepath.Dir(wd)
	ktbxConfigFile := filepath.Join(parent, "dot-config.example")
	err = os.Setenv("KTBXCONFIG", ktbxConfigFile)
	assert.NoError(err)

	// Return a function to teardown the test
	return func(tb testing.TB) {
		log.Println("teardown suite")
	}
}

func TestReadConfig(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	assert := assert.New(t)
	ReadConfig()
	assert.Equal(
		map[string]interface{}(
			map[string]interface{}{
				"extramountpath":  "/media",
				"localcertsans":   false,
				"privateregistry": "docker-registry.docker-registry:5000",
				"workers":         1}),
		viper.AllSettings()["kind"])
}

func TestGetConfig(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	assert := assert.New(t)
	ReadConfig()
	c := GetConfig()
	t.Logf("Config: %+v", c)
	assert.Equal(uint(1), c.Workers)
	assert.Equal(false, c.Calico)

}
