package git

import (
	"bytes"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

/*
*
currBranch format example:

				1.22-7_development_1654162455
				━━┳━━━ ━━━━━┳━━━━━ ━━━━┳━━━━━
		Release branch		┃	 	Current Unix time
		and number			┃
	 				 	ChangeType
				(docs, development, production)

*
*/

// Only one Manager can exist due to logic around checked out branches
var alreadyInit = false

type Manager struct {
	originalBranch string
	changesBranch  string
	ct             changetype.ChangeType
	version        string
}

// CreateGitManager creates
func CreateGitManager(releaseBranch, number string, ct changetype.ChangeType) (*Manager, error) {
	if alreadyInit {
		return nil, fmt.Errorf("cannot create more than one GitManager")
	}
	alreadyInit = true

	originalBr, err := showCurrentBranch()
	if err != nil {
		return &Manager{}, err
	}
	version := strings.Replace(releaseBranch, "-", ".", 1)

	newBranch := fmt.Sprintf("%s-%s_%s_%d", version, number, ct, time.Now().Unix())
	if err = checkoutNewBranch(newBranch); err != nil {
		return &Manager{}, fmt.Errorf("checking out new branch %s: %w", newBranch, err)
	}
	log.Printf("Checked out new branch %s off previous branch %s\n", newBranch, originalBr)

	return &Manager{
		ct:             ct,
		version:        version,
		originalBranch: string(originalBr),
		changesBranch:  newBranch,
	}, nil
}

// AddAndCommit adds and commits presumed changes for provided ap. There is no check to see if this file has actually
// changed.
func (gm *Manager) AddAndCommit(ap values.AbsolutePath) error {
	return gm.addAndCommit(ap.String(), "Added file "+ap.StripRootDirectory())
}

// AddAndCommitDirectory adds and commits presumed changes for provided nd. There is no check to see if any filed in the
// directory have actually changed. All changes to directory are
func (gm *Manager) AddAndCommitDirectory(nd values.NewDirectory) error {
	return gm.addAndCommit(nd.String(), "Added directory "+nd.StripRootDirectory())
}

// DeleteDirectoryAndAbandonAllChanges deletes provided directory and all files in it, checks out the git branch that it
// was on before the creation the Manager, and deletes the branch that was checked out when the Manager was created and
// that all the subsequent changes have been added/committed to.
// IMPORTANT!! Due to the logic around git branches, the Manager will be effectively useless after running this command,
// as the changes branch will be deleted.
func (gm *Manager) DeleteDirectoryAndAbandonAllChanges(nd *values.NewDirectory) error {
	if err := gm.currentBranchMustBeChangesBranch(); err != nil {
		return fmt.Errorf("checking expected branch before deleting directory: %w", err)
	}

	if err := nd.RemoveNewDirectory(); err != nil {
		return fmt.Errorf("checking expected branch before deleting directory: %w", err)
	}

	return gm.abandonChangesBranch()
}

// RestoreFileAndAbandonAllChanges restores any changes made to provided filepath, checks out the git branch that it was
// on before the creation the Manager, and deletes the branch that was checked out when the Manager was created and that
// all the subsequent changes have been added/committed to.
// IMPORTANT!! Due to the logic around git branches, the Manager will be effectively useless after running this command,
// as the changes branch will be deleted.
func (gm *Manager) RestoreFileAndAbandonAllChanges(ap values.AbsolutePath) []error {
	var errs []error
	if err := gm.currentBranchMustBeChangesBranch(); err != nil {
		return append(errs, fmt.Errorf("checking expected branch before restoring file: %w", err))
	}

	if err := restoreStagedFile(ap.String()); err != nil {
		errs = append(errs, fmt.Errorf("restoring staged file %s: %w", ap, err))
	}

	if err := restoreFile(ap.String()); err != nil {
		errs = append(errs, fmt.Errorf("restoring file %s: %w", ap, err))
	}

	if err := gm.abandonChangesBranch(); err != nil {
		errs = append(errs, err)
	}

	return errs
}

// Abandon checks out the git branch that it was on before the creation the Manager, and deletes the branch that was
// checked out when the Manager was created. No changes are dealt with.
// IMPORTANT!! Due to the logic around git branches, the Manager will be effectively useless after running this command,
// as the changes branch will be deleted.
func (gm *Manager) Abandon() error {
	if err := gm.currentBranchMustBeChangesBranch(); err != nil {
		return fmt.Errorf("checking expected branch before deleting directory: %w", err)
	}
	return gm.abandonChangesBranch()
}

// currentBranchMustBeChangesBranch returns error the current branch cannot be determined or if the current branch is
// not the changes branch
func (gm *Manager) currentBranchMustBeChangesBranch() error {
	currBranch, err := showCurrentBranch()
	if err != nil {
		return fmt.Errorf("checking if current branch matched expected: %w", err)
	}
	if !bytes.Equal([]byte(gm.changesBranch), currBranch) {
		return fmt.Errorf("expected branch %s does not match the current branch %s", gm.changesBranch, currBranch)
	}
	return nil
}

// addAndCommit adds and commits presumed changes for provided absolutePath. There is no check to see if this file has
// actually changed.
func (gm *Manager) addAndCommit(absolutePath, commitMessage string) error {
	if err := gm.currentBranchMustBeChangesBranch(); err != nil {
		return fmt.Errorf("checking expected branch before adding and committing: %w", err)
	}

	if err := add(absolutePath); err != nil {
		return fmt.Errorf("adding %s: %w", absolutePath, err)
	}
	if err := commit(commitMessage); err != nil {
		return fmt.Errorf("committing %s: %w", absolutePath, err)
	}
	log.Printf("Added and committed %s\n", absolutePath)
	return nil
}

// abandonChangesBranch checks out the original branch, deletes the changes branch, and set gm.changesBranch to "".
func (gm *Manager) abandonChangesBranch() error {
	if err := checkoutBranch(gm.originalBranch); err != nil {
		return fmt.Errorf("abandoning branch while checking out original branch: %w", err)
	}
	log.Printf("Checked out original branch %s\n", gm.originalBranch)

	if err := deleteBranch(gm.changesBranch); err != nil {
		return fmt.Errorf("abandoning branch while deleting branch: %w", err)
	}
	log.Printf("Deleted changes branch %s\n", gm.changesBranch)

	gm.changesBranch = ""
	return nil
}
