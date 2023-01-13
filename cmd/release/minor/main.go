package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

func main() {
	latestSupportedReleaseBranch, err := values.GetLatestSupportedReleaseBranch()
	if err != nil {
		log.Fatalf("getting the latest supported release branch to create new minor release: %v", err)
	}
	newReleaseBranch, err := getNewReleaseBranch(string(latestSupportedReleaseBranch))
	if err != nil {
		log.Fatalf("getting the new release branch: %v", err)
	}

	// Adds new release branch to SUPPORTED_RELEASE_BRANCHES
	err = addSupportedReleaseBranch([]byte(newReleaseBranch))
	if err != nil {
		log.Fatalf("adding %v as new supported release branch: %v", newReleaseBranch, err)
	}

	// Adds project files new release branch
	err = createProjectFilesAndDirectories(latestSupportedReleaseBranch, newReleaseBranch)
	if err != nil {
		log.Fatalf("at the end: %v", err)
	}

	// Adds release directory and sets RELEASE values to "0"
	err = createReleaseDirectoryAndFiles(newReleaseBranch)
	if err != nil {
		log.Fatalf("at the end: %v", err)
	}
}

func getNewReleaseBranch(latestSupportedReleaseBranch string) (string, error) {
	// latestSupportedReleaseBranch format expected to be 1-XX, e.g. 1-26
	prefix := latestSupportedReleaseBranch[:2]
	suffix := latestSupportedReleaseBranch[2:]

	latestMinorNum, err := strconv.Atoi(suffix)
	if err != nil {
		return "", fmt.Errorf("converting the minor release number %v to int: %w\n\n\n", latestMinorNum, err)
	}
	nextMinorNum := latestMinorNum + 1
	foo := prefix + strconv.Itoa(nextMinorNum)
	return foo, nil
}

func addSupportedReleaseBranch(newSupportedReleaseBranch []byte) error {
	releaseBranches, err := values.GetSupportedReleaseBranches()
	if err != nil {
		return fmt.Errorf("getting supported release branches to add %v: %w", newSupportedReleaseBranch, err)
	}
	releaseBranches = append(releaseBranches, newSupportedReleaseBranch)
	return os.WriteFile(values.SupportedReleaseBranchesPath, append(bytes.Join(releaseBranches, []byte("\n")), []byte("\n")...), 0644)
}

func createReleaseDirectoryAndFiles(newReleaseBranch string) error {
	newRBReleasePath := filepath.Join(values.GetGitRootDirectory(), "release", newReleaseBranch)
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

func createProjectFilesAndDirectories(rbToDuplicateBytes []byte, rbToCreateBytes string) error {
	rbToDuplicate := string(rbToDuplicateBytes)
	rbToCreate := rbToCreateBytes

	projects, err := values.GetProjects()
	if err != nil {
		return fmt.Errorf("getting projects: %w", err)
	}
	for _, project := range projects {
		projectPath := project.GetFilePath()
		repoRBToDuplicate := filepath.Join(projectPath, rbToDuplicate)
		if _, err = os.Stat(repoRBToDuplicate); os.IsNotExist(err) {
			return fmt.Errorf("expected %s to exist but it does not", repoRBToDuplicate)
		}
		// Create new release branch directory at projects/<org>/<repo>/<release_branch>
		rbToCreatePath := filepath.Join(projectPath, rbToCreate)
		if err = os.Mkdir(rbToCreatePath, 0755); err != nil {
			return fmt.Errorf("crearing new directory %s", rbToCreatePath)
		}
		// Copy all files and directories from the latest release branch to new one
		if err = copyDir(repoRBToDuplicate, rbToCreatePath, rbToDuplicate, rbToCreate); err != nil {
			return fmt.Errorf("copying directories and files: %w", err)
		}

	}
	return nil
}

func copyDir(existingBRPath, newRBPath, existingReleaseBranch, newReleaseBranch string) error {
	existingBRDirs, err := os.ReadDir(existingBRPath)
	if err != nil {
		return fmt.Errorf("reading directory at path %s: %w", existingBRPath, err)
	} else if len(existingBRPath) == 0 {
		return nil
	}

	for _, existingChildDir := range existingBRDirs {
		existingChildDirName := existingChildDir.Name()
		existingChildPath := filepath.Join(existingBRPath, existingChildDirName)
		newRBDirPath := filepath.Join(newRBPath, existingChildDirName)
		if existingChildDir.IsDir() {
			if err = os.Mkdir(newRBDirPath, 0755); err != nil {
				return fmt.Errorf("creating new directory to copy %s", newRBDirPath)
			}
			return copyDir(existingChildPath, newRBDirPath, existingReleaseBranch, newReleaseBranch)
		} else {
			if err := copyFile(existingChildPath, newRBDirPath, existingReleaseBranch, newReleaseBranch); err != nil {
				return fmt.Errorf("coping file: %w", err)
			}
		}
	}
	return nil
}

func copyFile(existingFilePath, newFilePath, existingReleaseBranch, newReleaseBranch string) error {
	existingFile, err := os.Open(existingFilePath)
	if err != nil {
		return err
	}
	defer existingFile.Close()

	newFile, err := os.Create(newFilePath)
	if err != nil {
		return err
	}
	defer newFile.Close()

	if filepath.Base(existingFile.Name()) == "CHECKSUMS" {
		scanner := bufio.NewScanner(existingFile)
		for scanner.Scan() {
			updatedLine := strings.ReplaceAll(scanner.Text(), existingReleaseBranch, newReleaseBranch)
			if _, err = fmt.Fprintln(newFile, updatedLine); err != nil {
				return fmt.Errorf("modifying CHECKSUM file: %w", err)
			}
		}
		if err = scanner.Err(); err != nil {
			return fmt.Errorf("scanning CHECKSUMS: %w", err)
		}
	} else {
		if _, err = io.Copy(newFile, existingFile); err != nil {
			return fmt.Errorf("copying files: %w", err)
		}
	}
	return nil
}
