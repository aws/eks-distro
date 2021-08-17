package pull_request

import (
	. "../internal"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strconv"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr
)

type PullRequest struct {
	branch        string
	commitMessage string
	filesPaths    string
	isBot         bool
}

func (pr PullRequest) Open() error {
	cmd := exec.Command(
		"/bin/bash",
		CreateReleasePRScriptPath,
		pr.branch,
		pr.commitMessage,
		pr.filesPaths,
		strconv.FormatBool(pr.isBot),
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error opending PR: %v", err)
	}
	return nil
}
