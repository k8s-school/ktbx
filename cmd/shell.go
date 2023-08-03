package cmd

import (
	"bytes"
	"io"
	"os"
	"os/exec"
)

const ShellToUse = "bash"

func ExecCmd(command string) (string, string) {

	var stdoutBuf, stderrBuf bytes.Buffer
	if !dryRun {
		logger.Infof("Launch command: %v", command)
		cmd := exec.Command(ShellToUse, "-c", command)

		cmd.Stdout = io.MultiWriter(os.Stdout, &stdoutBuf)
		cmd.Stderr = io.MultiWriter(os.Stderr, &stderrBuf)

		err := cmd.Run()
		if err != nil {
			logger.Fatalf("cmd.Run() failed with %s\n", err)
		}
		// logger.Infof("stdout %v", stdoutBuf)
		// logger.Infof("stderr %v", stderrBuf)

	} else {
		logger.Infof("Dry run %s", command)
	}
	return stdoutBuf.String(), stderrBuf.String()
}
