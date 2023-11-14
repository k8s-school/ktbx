package cmd

import (
	"bytes"
	"io"
	"os"
	"os/exec"

	"github.com/k8s-school/k8s-toolbox/ktbx/log"
)

const ShellToUse = "bash"

func ExecCmd(command string, interactive bool) (string, string) {

	var stdoutBuf, stderrBuf bytes.Buffer
	if !dryRun {
		log.Infof("Launch command: %v", command)
		cmd := exec.Command(ShellToUse, "-c", command)
		if interactive {
			cmd.Stdin = os.Stdin
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
		} else {
			cmd.Stdout = io.MultiWriter(os.Stdout, &stdoutBuf)
			cmd.Stderr = io.MultiWriter(os.Stderr, &stderrBuf)
		}
		err := cmd.Run()
		if err != nil {
			log.Fatalf("cmd.Run() failed with %s\n", err)
		}
		// logger.Infof("stdout %v", stdoutBuf)
		// logger.Infof("stderr %v", stderrBuf)

	} else {
		log.Infof("Dry run %s", command)
	}
	return stdoutBuf.String(), stderrBuf.String()
}
