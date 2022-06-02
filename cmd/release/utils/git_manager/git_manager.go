package git_manager

import (
	"bytes"
	"fmt"
	. "github.com/aws/eks-distro/cmd/release/utils"
	"os/exec"
	"strings"
	"time"
)

/*
*
currBranch format example:

				1.22-7_development_1654162455
				━━┳━━━ ━━━━━┳━━━━━ ━━━━┳━━━━━
		Release branch		┃	 	Current Unix time
		and number			┃
	 				 	ChangesType
				(docs, development, production)

*
*/
var gitRootDir = GetGitRootDirectory()

type GitManager struct {
	originalBranch, currentBranch []byte
	changesType                   ChangesType
	version                       string
}

func CreateGitManager(releaseBranch, releaseNumber string, changesType ChangesType) (*GitManager, error) {
	originalBr, err := determineCheckedOutBranch()
	if err != nil {
		return &GitManager{}, err
	}

	kubernetesMinorVersion := strings.Replace(releaseBranch, "-", ".", 1)

	currBranch := fmt.Sprintf("%s-%s_%s_%d",
		kubernetesMinorVersion,
		releaseNumber,
		changesType.String(),
		time.Now().Unix(),
	)

	if err = exec.Command("git", "-C", gitRootDir, "checkout", "-b", currBranch).Run(); err != nil {
		return &GitManager{}, err
	}

	return &GitManager{
		originalBranch: originalBr,
		currentBranch:  []byte(currBranch),
		changesType:    changesType,
		version:        kubernetesMinorVersion,
	}, nil
}

func (gm *GitManager) CurrentBranch() string {
	return string(gm.currentBranch)
}

func (gm *GitManager) AddAndCommit(filepaths ...string) error {
	isExpectedBranch, err := gm.isCurrentBranchMatchExpected()
	if err != nil {
		return err
	} else if !isExpectedBranch {
		return fmt.Errorf("the expected branch does not match the current branch")
	}

	for _, filepath := range filepaths {
		if err = exec.Command("git", "-C", gitRootDir, "add", filepath).Run(); err != nil {
			return err
		}
		commitMessage := "Added " + StripRootDirectory(filepath)
		if err = exec.Command("git", "-C", gitRootDir, "commit", "-m", commitMessage).Run(); err != nil {
			return err
		}
	}
	return nil
}

func (gm *GitManager) CheckoutOriginalBranch() error {
	return exec.Command("git", "-C", gitRootDir, "checkout", string(gm.originalBranch)).Run()
}

func (gm *GitManager) AbandonBranch() error {
	err := gm.CheckoutOriginalBranch()
	if err != nil {
		return err
	}
	return exec.Command("git", "-C", gitRootDir, "branch", "-D", string(gm.currentBranch)).Run()
}

func (gm *GitManager) RestoreFile(filepath string) error {
	return exec.Command("git", "restore", filepath).Run()
}

func (gm *GitManager) isCurrentBranchMatchExpected() (bool, error) {
	currBr, err := determineCheckedOutBranch()
	if err != nil {
		return false, err
	}
	return bytes.Equal(gm.currentBranch, currBr), nil
}

func determineCheckedOutBranch() ([]byte, error) {
	currBr, err := exec.Command("git", "-C", gitRootDir, "branch", "--show-current").Output()
	if err != nil {
		return []byte{}, err
	}
	return currBr[:len(currBr)-1], nil
}
