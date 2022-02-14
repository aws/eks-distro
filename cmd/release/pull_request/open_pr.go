package pull_request

import (
	. "../utils"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr

	createReleasePRScriptPath = filepath.Join(GetGitRootDirectory(), "cmd/release/pull_request/create_release_pr.sh")
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
		createReleasePRScriptPath,
		pr.branch,
		pr.commitMessage,
		pr.filesPaths,
		strconv.FormatBool(pr.isBot),
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error opening PR: %v", err)
	}
	return nil
}
