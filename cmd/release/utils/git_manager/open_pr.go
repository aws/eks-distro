package git_manager

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/aws/eks-distro/cmd/release/utils"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr

	createPRScriptPath = filepath.Join(utils.GetGitRootDirectory(), "cmd/release/utils/git_manager/open_pr.sh")
)

func (gm *GitManager) OpenPR() error {
	prDescription, err := getPRDescription(gm.changesType, gm.version)
	if err != nil {
		return err
	}

	cmd := exec.Command(
		"/bin/bash",
		createPRScriptPath,
		string(gm.currentBranch),
		prDescription,
		gm.version,
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("opening PR: %v", err)
	}
	return gm.checkoutOriginalBranch()
}

func getPRDescription(changesType utils.ChangesType, version string) (string, error) {
	if changesType.IsDevOrProd() {
		return fmt.Sprintf("Bumped %s release number for %s", changesType.String(), version), nil
	} else if changesType == utils.Docs {
		return "Created and updated docs for " + version, nil
	} else {
		return "", fmt.Errorf("unknown ChangesType %v", changesType)
	}
}
