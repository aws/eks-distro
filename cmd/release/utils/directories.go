package utils

import (
	"fmt"
	"os/exec"
	"strings"
)

var (
	gitRootDirectory = func() string {
		gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
		if err != nil {
			panic(fmt.Sprintf("Unable to get git root directory: %v", err))
		}
		return strings.Join(strings.Fields(string(gitRootOutput)), "")
	}()
)

func GetGitRootDirectory() string {
	return gitRootDirectory
}
