package git_manager

import (
	. "github.com/aws/eks-distro/cmd/release/utils"

	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr

	createPRScriptPath = filepath.Join(gitRootDir, "cmd/release/utils/git_manager/open_pr.sh")
)

func (gm *GitManager) OpenPR() error {
	prDescription, err := getPRDescription(gm.changesType, gm.version)
	if err != nil {
		return err
	}

	cmd := exec.Command(
		"/bin/bash",
		createPRScriptPath,
		gm.CurrentBranch(),
		prDescription,
		gm.version,
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error opening PR: %v", err)
	}
	return gm.CheckoutOriginalBranch()
}

func getPRDescription(changesType ChangesType, version string) (string, error) {
	if changesType.IsDevOrProd() {
		return fmt.Sprintf("Bumped %s release number for %s", changesType.String(), version), nil
	} else if changesType == Docs {
		return "Created and updated docs for " + version, nil
	} else {
		return "", fmt.Errorf("unknown ChangesType %v", changesType)
	}
}
