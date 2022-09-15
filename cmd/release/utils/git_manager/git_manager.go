package git_manager

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"
	"time"

	"github.com/aws/eks-distro/cmd/release/utils"
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

type GitManager struct {
	originalBranch string
	currentBranch  string
	changesType    utils.ChangesType
	version        string

	// Runners
	add               func(string) error
	commit            func(string) error
	checkoutBranch    func(string) error
	checkoutNewBranch func(string) error
	deleteBranch      func(string) error
	restoreFile       func(string) error
	showCurrentBranch func() ([]byte, error)
}

func CreateGitManager(releaseBranch, number string, ct utils.ChangesType) (*GitManager, error) {
	gm := initializeWithRunners()
	gm.changesType = ct
	gm.version = strings.Replace(releaseBranch, "-", ".", 1)

	originalBr, err := gm.determineCheckedOutBranch()
	if err != nil {
		return &GitManager{}, err
	}
	gm.originalBranch = string(originalBr)

	newBranch := fmt.Sprintf("%s-%s_%s_%d", gm.version, number, gm.changesType, time.Now().Unix())
	if err = gm.checkoutNewBranch(newBranch); err != nil {
		return &GitManager{}, fmt.Errorf("checking out new branch %s: %v", newBranch, err)
	}
	gm.currentBranch = newBranch

	return gm, nil
}

func (gm *GitManager) AddAndCommit(filepaths ...string) error {
	isExpectedBranch, err := gm.isCurrentBranchMatchExpected()
	if err != nil {
		return err
	} else if !isExpectedBranch {
		return fmt.Errorf("expected branch does not match the current branch")
	}

	for _, filepath := range filepaths {
		if err = gm.add(filepath); err != nil {
			return fmt.Errorf("adding file %s: %v", filepath, err)
		}
		if err = gm.commit("Added " + utils.StripRootDirectory(filepath)); err != nil {
			return fmt.Errorf("committing file %s: %v", filepath, err)
		}
	}
	return nil
}

func (gm *GitManager) AbandonBranch() error {
	if err := gm.checkoutOriginalBranch(); err != nil {
		return fmt.Errorf("abandoning branch while checking out original branch: %v", err)
	}

	if err := gm.deleteBranch(gm.currentBranch); err != nil {
		return fmt.Errorf("abandoning branch while deleting branch: %v", err)
	}
	return nil
}

func (gm *GitManager) RestoreFile(filepath string) error {
	if err := gm.restoreFile(filepath); err != nil {
		return fmt.Errorf("restoring file %s: %v", filepath, err)
	}
	return nil
}

func (gm *GitManager) checkoutOriginalBranch() error {
	if err := gm.checkoutBranch(gm.originalBranch); err != nil {
		return fmt.Errorf("checking out original branch %s: %v", gm.originalBranch, err)
	}
	return nil
}

func (gm *GitManager) isCurrentBranchMatchExpected() (bool, error) {
	checkedOutBranch, err := gm.determineCheckedOutBranch()
	if err != nil {
		return false, fmt.Errorf("checking if current branch matched expected: %v", err)
	}
	return bytes.Equal([]byte(gm.currentBranch), checkedOutBranch), nil
}

func (gm *GitManager) determineCheckedOutBranch() ([]byte, error) {
	currBr, err := gm.showCurrentBranch()
	if err != nil {
		return []byte{}, fmt.Errorf("showing current branch: %v", err)
	}
	return currBr[:len(currBr)-1], nil
}

func initializeWithRunners() *GitManager {
	cmdName := "git"
	baseCmd := []string{"-C", utils.GetGitRootDirectory()}

	var cmdRunner = func(gitArgs ...string) func(string) error {
		stdCmd := append(baseCmd, gitArgs...)
		return func(additionalArg string) error {
			allArgs := append(stdCmd, additionalArg)
			return exec.Command(cmdName, allArgs...).Run()
		}
	}

	var cmdOutput = func(gitArgs ...string) func() ([]byte, error) {
		stdCmd := append(baseCmd, gitArgs...)
		return func() ([]byte, error) {
			return exec.Command(cmdName, stdCmd...).Output()
		}
	}

	return &GitManager{
		add:               cmdRunner("add"),
		commit:            cmdRunner("commit", "-m"),
		checkoutBranch:    cmdRunner("checkout"),
		checkoutNewBranch: cmdRunner("checkout", "-b"),
		deleteBranch:      cmdRunner("branch", "-D"),
		restoreFile:       cmdRunner("restore"),
		showCurrentBranch: cmdOutput("branch", "--show-current"),
	}
}
