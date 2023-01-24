package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/aws/eks-distro/cmd/release/minor/projects"
	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

func main() {
	latestSupportedReleaseBranch, err := values.GetLatestSupportedReleaseBranch()
	if err != nil {
		log.Fatalf("getting the latest supported release branch to create new minor release: %v", err)
	}

	// Adds new release branch to SUPPORTED_RELEASE_BRANCHES
	addedReleaseBranch, err := values.AddNextReleaseBranch()
	if err != nil {
		log.Fatalf("getting the new release branch: %v", err)
	}
	log.Printf("Added %s to SUPPORTED_RELEASE_BRANCHES", addedReleaseBranch)

	prevReleaseBranch, nextReleaseBranch := string(latestSupportedReleaseBranch), string(addedReleaseBranch)

	// Adds project files new release branch
	projectFilesAddedCount, err := projects.CreateFilesAndDirectories(prevReleaseBranch, nextReleaseBranch)
	if err != nil {
		log.Fatalf("creating project files and directories: %v", err)
	}
	log.Printf("Generated %d project files", projectFilesAddedCount)

	// Adds release directory and sets RELEASE values to "0"
	err = createReleaseDirectoryAndFiles(nextReleaseBranch)
	if err != nil {
		log.Fatalf("creating RELEASE files: %v", err)
	}
	log.Printf("Generated RELEASE files")
}

func createReleaseDirectoryAndFiles(nextReleaseBranch string) error {
	newRBReleasePath := filepath.Join(values.GetGitRootDirectory(), "release", nextReleaseBranch)
	if err := os.Mkdir(newRBReleasePath, 0755); err != nil {
		return fmt.Errorf("creating new directory for release: %w", err)
	}

	for _, ct := range []changetype.ChangeType{changetype.Dev, changetype.Prod} {
		ctDirPath := filepath.Join(newRBReleasePath, ct.String())
		if err := os.Mkdir(ctDirPath, 0755); err != nil {
			return fmt.Errorf("creating new directory for %s release: %w", ct.String(), err)
		}
		if err := os.WriteFile(filepath.Join(ctDirPath, "RELEASE"), []byte("0\n"), 0744); err != nil {
			return fmt.Errorf("writing to RELEASE file: %w", err)
		}
	}
	return nil
}
