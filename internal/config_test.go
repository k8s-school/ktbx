package internal

import (
	"log"
	"os"
	"path/filepath"
	"testing"

	"github.com/spf13/viper"
	require "github.com/stretchr/testify/assert"
)

func setupSuite(tb testing.TB) func(tb testing.TB) {
	log.Println("setup suite")

	require := require.New(tb)
	wd, err := os.Getwd()
	require.NoError(err)
	parent := filepath.Dir(wd)
	ktbxConfigFile := filepath.Join(parent, "utest", "dot-config-audit")
	err = os.Setenv("KTBXCONFIG", ktbxConfigFile)
	require.NoError(err)

	// Return a function to teardown the test
	return func(tb testing.TB) {
		log.Println("teardown suite")
	}
}

func TestReadConfig(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	require := require.New(t)
	ReadConfig()
	require.Equal(
		map[string]interface{}(
			map[string]interface{}{
				"auditpolicy":     "/tmp/audit-policy.yaml",
				"extramountpath":  "/media",
				"localcertsans":   false,
				"privateregistry": "docker-registry.docker-registry:5000",
				"workers":         1}),
		viper.AllSettings()["kind"])
}

func TestGetConfig(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	require := require.New(t)
	ReadConfig()
	c := GetConfig()
	t.Logf("Config: %+v", c)
	require.Equal(uint(1), c.Workers)
	require.Equal("", c.Cni)

}
func TestGenerateKindConfigFile(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	require := require.New(t)

	// Create a temporary directory for the test
	tmpDir, err := os.MkdirTemp("/tmp", "kind-config")
	require.NoError(err)
	defer os.RemoveAll(tmpDir)

	// Create a sample KtbxConfig
	config := KtbxConfig{
		Workers:         1,
		Cni:             "calico",
		AuditPolicy:     "/tmp/audit-policy.yaml",
		ExtraMountPath:  "/tmp/extra-mount-path",
		LocalCertSANs:   true,
		PrivateRegistry: "docker-registry.docker-registry:5000",
	}

	// Call the GenerateKindConfigFile function
	kindConfigFile, err := GenerateKindConfigFile(config)
	require.NoError(err)

	// Read the contents of the generated file
	fileContents, err := os.ReadFile(kindConfigFile)
	require.NoError(err)

	// Assert the expected file contents
	wd, err := os.Getwd()
	require.NoError(err)
	parent := filepath.Dir(wd)
	expectedKindConfigFile := filepath.Join(parent, "utest", "kind-config.yaml")

	expectedContents, err := os.ReadFile(expectedKindConfigFile)
	require.NoError(err)
	require.Equal(string(expectedContents), string(fileContents))
}
