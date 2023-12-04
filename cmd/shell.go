package cmd

import (
	"bytes"
	"io"
	"log/slog"
	"os"
	"os/exec"
)

const ShellToUse = "bash"

func ExecCmd(command string, interactive bool) (string, string) {

	var stdoutBuf, stderrBuf bytes.Buffer
	if !dryRun {
		slog.Info("Launch command", "command", command)
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
			slog.Error("cmd.Run() failed", "error", err)
		}
		// logger.Infof("stdout %v", stdoutBuf)
		// logger.Infof("stderr %v", stderrBuf)

	} else {
		slog.Info("Dry run", "command", command)
	}
	return stdoutBuf.String(), stderrBuf.String()
}
