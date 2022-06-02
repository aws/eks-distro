package main

import (
	"flag"
	"fmt"
	. "github.com/aws/eks-distro/cmd/release/docs/existing_docs"
	. "github.com/aws/eks-distro/cmd/release/docs/new_docs"
	"github.com/aws/eks-distro/cmd/release/utils"
	. "github.com/aws/eks-distro/cmd/release/utils/git_manager"
	"log"
	"path/filepath"
)

const changeType = utils.Docs

var rootDirectory = utils.GetGitRootDirectory()

// Generates docs for release. Value for 'branch' flag must be provided. The release MUST already be out, and all
// upstream changes MUST be pulled down locally.
// TODO: fix all logic around undoing changes if error.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-23")
	flag.Parse()

	// Create Release with values. The actual release MUST already be out, and all upstream changes MUST be pulled
	// down locally.
	release, err := utils.NewRelease(*branch, changeType)
	if err != nil {
		log.Fatalf("Error that was encountered while creating new release: %v", err)
	}

	// Create GitManager
	gm, err := CreateGitManager(release.Branch(), release.Number(), changeType)
	if err != nil {
		log.Fatalf("Error that was encountered while creating new git manager: %v", err)
	}

	// Create new docs
	docs, err := CreateNewDocsInfo(&release)
	if err != nil {
		log.Fatalf("Error that was encountered while creating new docs input: %v", err)
	}
	newReleaseDocDirectory := utils.GetReleaseDocsDirectory(release.Branch(), release.Number())
	changedFiles, err := GenerateNewDocs(docs, newReleaseDocDirectory)
	if err != nil {
		_ = gm.AbandonBranch()
		log.Fatalf("Error that was encountered while creating new docs: %v", err)
	}
	err = gm.AddAndCommit(changedFiles...)
	if err != nil {
		log.Fatalf("Failed to update doc due to error: %v", err)
	}

	// Update existing files
	readmePath := filepath.Join(rootDirectory, "README.md")
	if err = updateExistingDocs(gm, UpdateREADME, readmePath, &release); err != nil {
		log.Fatalf("Failed to update README due to error: %v", err)
	}
	indexPath := filepath.Join(rootDirectory, "docs", "contents", "index.md")
	if err = updateExistingDocs(gm, UpdateDocsIndex, indexPath, &release); err != nil {
		log.Fatalf("Failed to update index due to error: %v", err)
	}

	// Open PR
	if err = gm.OpenPR(); err != nil {
		log.Fatalf("error opening PR: %v", err)
	}
}

func updateExistingDocs(gm *GitManager, updateFunc func(utils.Release, string) error, filePath string, r *utils.Release) error {
	err := updateFunc(*r, filePath)
	if err != nil {
		_ = gm.RestoreFile(filePath)
		_ = gm.AbandonBranch()
		return fmt.Errorf("error encountered while updating %s: %v", filePath, err)
	}

	if err = gm.AddAndCommit(filePath); err != nil {
		_ = gm.RestoreFile(filePath)
		_ = gm.AbandonBranch()
		return fmt.Errorf("error encountered while adding and committing %s: %v", filePath, err)
	}
	return nil
}
