package pull_request

import (
	. "../internal"
	"fmt"
	"io"
	"os"
	"os/exec"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr
)

type PullRequest struct {
	branch        string
	commitMessage string
	filesPaths    string
}

func (pr PullRequest) Open() error {
	cmd := exec.Command("/bin/bash", CreateReleasePRScriptPath, pr.branch, pr.commitMessage, pr.filesPaths)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error opending PR: %v", err)
	}
	return nil
}
