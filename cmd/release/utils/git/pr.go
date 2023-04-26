package git

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/aws/eks-distro/cmd/release/utils/values"
)

var (
	prScriptPathFromRoot           = filepath.Join(values.GetGitRootDirectory(), "cmd/release/utils/git/open-pr.sh")
	outputStream         io.Writer = os.Stdout
	errStream            io.Writer = os.Stderr
)

func (gm *Manager) OpenPR() error {
	if err := gm.currentBranchMustBeChangesBranch(); err != nil {
		return fmt.Errorf("checking expected branch before opening PR: %w", err)
	}

	prTitle, err := gm.ct.GetDescription(gm.version)
	if err != nil {
		return fmt.Errorf("getting PR description: %w", err)
	}

	cmd := exec.Command("/bin/bash", prScriptPathFromRoot, gm.changesBranch, prTitle)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream

	if err = cmd.Run(); err != nil {
		if err = gm.abandonChangesBranch(); err != nil {
			fmt.Printf("checking out original branch after opening PR: %v\n", err)
		}
		return fmt.Errorf("opening PR: %v", err)
	}

	if err = gm.abandonChangesBranch(); err != nil {
		return fmt.Errorf("checking out original branch after opening PR: %w", err)
	}
	return nil
}
