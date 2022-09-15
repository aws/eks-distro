package main

import (
	"flag"
	"fmt"
	"log"
	"path/filepath"

	"github.com/aws/eks-distro/cmd/release/docs/existing_docs"
	"github.com/aws/eks-distro/cmd/release/docs/new_docs"
	"github.com/aws/eks-distro/cmd/release/utils"
	"github.com/aws/eks-distro/cmd/release/utils/git_manager"
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
		log.Fatalf("creating new release: %v", err)
	}

	// Create GitManager
	gm, err := git_manager.CreateGitManager(release.Branch(), release.Number(), changeType)
	if err != nil {
		log.Fatalf("creating new git manager: %v", err)
	}

	// Create new docs
	docs, err := new_docs.CreateNewDocsInfo(&release)
	if err != nil {
		log.Fatalf("creating new docs input: %v", err)
	}
	newReleaseDocDirectory := utils.GetReleaseDocsDirectory(release.Branch(), release.Number())
	changedFiles, err := new_docs.GenerateNewDocs(docs, newReleaseDocDirectory)
	if err != nil {
		_ = gm.AbandonBranch()
		log.Fatalf("creating new docs: %v", err)
	}
	err = gm.AddAndCommit(changedFiles...)
	if err != nil {
		log.Fatalf("updating docs: %v", err)
	}

	// Update existing files
	readmePath := filepath.Join(rootDirectory, "README.md")
	if err = updateExistingDocs(gm, existing_docs.UpdateREADME, readmePath, &release); err != nil {
		log.Fatalf("updating README: %v", err)
	}
	indexPath := filepath.Join(rootDirectory, "docs", "contents", "index.md")
	if err = updateExistingDocs(gm, existing_docs.UpdateDocsIndex, indexPath, &release); err != nil {
		log.Fatalf("updating existing index doc: %v", err)
	}

	// Open PR
	if err = gm.OpenPR(); err != nil {
		log.Fatalf("opening PR: %v", err)
	}
}

func updateExistingDocs(gm *git_manager.GitManager, updateFunc func(utils.Release, string) error, filePath string, r *utils.Release) error {
	err := updateFunc(*r, filePath)
	if err != nil {
		_ = gm.RestoreFile(filePath)
		_ = gm.AbandonBranch()
		return fmt.Errorf("updating doc: %v", err)
	}

	if err = gm.AddAndCommit(filePath); err != nil {
		_ = gm.RestoreFile(filePath)
		_ = gm.AbandonBranch()
		return fmt.Errorf("adding and committing doc: %v", err)
	}
	return nil
}
