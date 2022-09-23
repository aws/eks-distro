package git

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"

	"github.com/aws/eks-distro/cmd/release/utils/values"
)

const cmdName = "git"

var (
	baseCmd = []string{"-C", values.GetGitRootDirectory()}

	add               = cmdRunner("add")
	commit            = cmdRunner("commit", "-m")
	checkoutBranch    = cmdRunner("checkout")
	checkoutNewBranch = cmdRunner("checkout", "-b")
	deleteBranch      = cmdRunner("branch", "-D")
	restoreFile       = cmdRunner("restore")
	restoreStagedFile = cmdRunner("restore", "--staged")

	showCurrentBranch = cmdOutput("branch", "--show-current")
)

func cmdOutput(gitArgs ...string) func() ([]byte, error) {
	stdCmd := append(baseCmd, gitArgs...)
	return func() ([]byte, error) {
		output, err := exec.Command(cmdName, stdCmd...).Output()
		if err != nil {
			return []byte{}, fmt.Errorf("running %s\n%w\n%s\n",
				fmt.Sprintf("%s %s", cmdName, strings.Join(stdCmd, " ")), err, output)
		}
		return bytes.TrimSpace(output), nil
	}
}

func cmdRunner(gitArgs ...string) func(string) error {
	stdCmd := append(baseCmd, gitArgs...)
	return func(additionalArg string) error {
		allArgs := append(stdCmd, additionalArg)
		cmd := exec.Command(cmdName, allArgs...)
		output, err := cmd.CombinedOutput()
		if err != nil {
			return fmt.Errorf("running %q\n%w\n%s", strings.Join(cmd.Args, " "), err, output)
		}
		return nil
	}
}
