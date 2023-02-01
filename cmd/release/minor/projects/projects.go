package projects

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/aws/eks-distro/cmd/release/utils/projects"
)

var (
	prevReleaseBranch string
	nextReleaseBranch string
)

// CreateFilesAndDirectories returns the number of files generated. If there was an error, returns -1
func CreateFilesAndDirectories(prevReleaseBranchInput string, nextReleaseBranchInput string) (int, error) {
	prevReleaseBranch, nextReleaseBranch = prevReleaseBranchInput, nextReleaseBranchInput

	eksdProjects, err := projects.GetProjects()
	if err != nil {
		return -1, fmt.Errorf("getting projects: %w", err)
	}
	for _, project := range eksdProjects {
		projectPath := project.GetFilePath()
		prevReleaseBranchRepoPath := filepath.Join(projectPath, prevReleaseBranch)
		if _, err = os.Stat(prevReleaseBranchRepoPath); os.IsNotExist(err) {
			return -1, fmt.Errorf("expected %s to exist but it does not", prevReleaseBranchRepoPath)
		}
		// Create new release branch directory at projects/<org>/<repo>/<release_branch>
		nextReleaseBranchRepoPath := filepath.Join(projectPath, nextReleaseBranch)
		if err = os.Mkdir(nextReleaseBranchRepoPath, 0755); err != nil {
			return -1, fmt.Errorf("creating new directory %s", nextReleaseBranchRepoPath)
		}
		// Copy all files and directories from the latest release branch to new one
		err = copyDir(prevReleaseBranchRepoPath, nextReleaseBranchRepoPath)
		if err != nil {
			return -1, fmt.Errorf("copying directories and files: %w", err)
		}
	}

	// Validate results
	prevReleaseBranchFileCount, err := getFileCount(prevReleaseBranch)
	if err != nil {
		return -1, fmt.Errorf("getting previous release branch project file count: %w", err)
	}
	nextReleaseBranchFileCount, err := getFileCount(nextReleaseBranch)
	if err != nil {
		return -1, fmt.Errorf("getting next release branch project file count: %w", err)
	}
	if prevReleaseBranchFileCount != nextReleaseBranchFileCount {
		return -1, fmt.Errorf("expected previous release branch file count (%d) to match next release branch file count (%d)",
			prevReleaseBranchFileCount, nextReleaseBranchFileCount)
	}
	return nextReleaseBranchFileCount, nil
}

func copyDir(prevReleaseBranchPath, nextReleaseBranchPath string) error {
	prevReleaseBranchDirs, err := os.ReadDir(prevReleaseBranchPath)
	if err != nil {
		return fmt.Errorf("reading directory at path %s: %w", prevReleaseBranchPath, err)
	} else if len(prevReleaseBranchDirs) == 0 {
		return nil
	}

	for _, prevReleaseBranchChildDir := range prevReleaseBranchDirs {
		prevReleaseBranchChildPath := filepath.Join(prevReleaseBranchPath, prevReleaseBranchChildDir.Name())
		nextReleaseBranchDirPath := filepath.Join(nextReleaseBranchPath, prevReleaseBranchChildDir.Name())
		if prevReleaseBranchChildDir.IsDir() {
			if err = os.Mkdir(nextReleaseBranchDirPath, 0755); err != nil {
				return fmt.Errorf("creating new directory to copy %s", nextReleaseBranchDirPath)
			}
			if err = copyDir(prevReleaseBranchChildPath, nextReleaseBranchDirPath); err != nil {
				return fmt.Errorf("copying child directory %s", prevReleaseBranchChildPath)
			}
		} else {
			if err = copyFile(prevReleaseBranchChildPath, nextReleaseBranchDirPath); err != nil {
				return fmt.Errorf("coping file: %w", err)
			}
		}
	}
	return nil
}

func copyFile(prevReleaseBranchFilePath, nextReleaseBranchFilePath string) error {
	existingFile, err := os.Open(prevReleaseBranchFilePath)
	if err != nil {
		return fmt.Errorf("opening file %s to copy: %w", prevReleaseBranchFilePath, err)
	}
	defer existingFile.Close()

	newFile, err := os.Create(nextReleaseBranchFilePath)
	if err != nil {
		return fmt.Errorf("creating file %s to write to as a copy: %w", nextReleaseBranchFilePath, err)
	}
	defer newFile.Close()

	if filepath.Base(existingFile.Name()) == "CHECKSUMS" {
		scanner := bufio.NewScanner(existingFile)
		for scanner.Scan() {
			updatedLine := strings.ReplaceAll(scanner.Text(), prevReleaseBranch, nextReleaseBranch)
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

func getFileCount(releaseBranch string) (int, error) {
	pathPattern := filepath.Join(projects.GetProjectPathRoot(), "*", "*", releaseBranch, "*")
	out, err := exec.Command("bash", "-c", fmt.Sprintf("find %s -type f | wc -l", pathPattern)).Output()
	if err != nil {
		return -1, fmt.Errorf("getting file count for %s: %w", releaseBranch, err)
	}
	count, err := strconv.Atoi(strings.TrimSpace(string(out)))
	if err != nil {
		return -1, fmt.Errorf("converting file count %v to int: %w", out, err)
	}
	return count, nil
}
