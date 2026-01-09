package internal

import (
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/spf13/viper"
	require "github.com/stretchr/testify/assert"
)

func setupSuite(tb testing.TB) func(tb testing.TB) {
	log.Println("setup suite")

	require := require.New(tb)

	// Create temporary directory for test files
	tmpDir, err := os.MkdirTemp("", "ktbx-test-*")
	require.NoError(err)

	// Create temporary audit policy file
	auditPolicyContent := `apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
`
	auditPolicyPath := filepath.Join(tmpDir, "audit-policy.yaml")
	err = os.WriteFile(auditPolicyPath, []byte(auditPolicyContent), 0644)
	require.NoError(err)

	// Create temporary config file with the correct audit policy path
	wd, err := os.Getwd()
	require.NoError(err)
	parent := filepath.Dir(wd)
	originalConfigFile := filepath.Join(parent, "utest", "dot-config-audit")

	// Read original config and replace audit policy path
	configContent, err := os.ReadFile(originalConfigFile)
	require.NoError(err)

	updatedConfig := strings.Replace(string(configContent), "/tmp/audit-policy.yaml", auditPolicyPath, 1)

	testConfigPath := filepath.Join(tmpDir, "test-config.yaml")
	err = os.WriteFile(testConfigPath, []byte(updatedConfig), 0644)
	require.NoError(err)

	err = os.Setenv("KTBXCONFIG", testConfigPath)
	require.NoError(err)

	// Return a function to teardown the test
	return func(tb testing.TB) {
		log.Println("teardown suite")
		// Clean up the temporary directory
		os.RemoveAll(tmpDir)
	}
}

func TestReadConfig(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	require := require.New(t)
	ReadConfig()
	kindSettings := viper.AllSettings()["kind"].(map[string]interface{})

	// Check all expected values except auditpolicy which is dynamic
	require.Equal("/media", kindSettings["extramountpath"])
	require.Equal(false, kindSettings["localcertsans"])
	require.Equal("docker-registry.docker-registry:5000", kindSettings["privateregistry"])
	require.Equal(1, kindSettings["workers"])

	// Just verify auditpolicy exists and is not empty
	auditPolicy, ok := kindSettings["auditpolicy"].(string)
	require.True(ok)
	require.NotEmpty(auditPolicy)
}

func TestGetConfig(t *testing.T) {
	teardownSuite := setupSuite(t)
	defer teardownSuite(t)

	require := require.New(t)
	ReadConfig()
	c, err := GetConfig()
	t.Logf("Config: %+v", c)
	require.NoError(err)
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
