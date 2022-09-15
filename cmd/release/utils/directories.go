package utils

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var (
	gitRootDirectory = func() string {
		gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
		if err != nil {
			panic(fmt.Sprintf("Unable to get git root directory: %v", err))
		}
		return strings.Join(strings.Fields(string(gitRootOutput)), "")
	}()
)

type ReleaseTag interface {
	Tag() string
}

// GetGitRootDirectory returns path to root of project. Example: /Users/lovelace/go/eks-distro
func GetGitRootDirectory() string {
	return gitRootDirectory
}

// GetReleaseDocsDirectory returns the directory path. Example: ~/go/eks-distro/docs/contents/releases/1-24/1
func GetReleaseDocsDirectory(branch, number string) string {
	return filepath.Join(GetGitRootDirectory(), "docs", "contents", "releases", branch, number)
}

func GetGitTag(projectOrg, projectName, releaseBranch string) ([]byte, error) {
	getTagPath := filepath.Join(GetGitRootDirectory(), "projects", projectOrg, projectName, releaseBranch, "GIT_TAG")
	fileOutput, err := os.ReadFile(getTagPath)
	if err != nil {
		return []byte{}, fmt.Errorf("reading GIT_TAG at %s path:%v", getTagPath, err)
	}
	return bytes.TrimSpace(fileOutput), nil
}

func GetDefaultReleaseBranch() (string, error) {
	defaultReleaseBranchPath := filepath.Join(GetGitRootDirectory(), "release", "DEFAULT_RELEASE_BRANCH")
	fileOutput, err := os.ReadFile(defaultReleaseBranchPath)
	if err != nil {
		return "", fmt.Errorf("getting default release branch at %s path:%v", defaultReleaseBranchPath, err)
	}
	return strings.TrimSpace(string(fileOutput)), nil
}

// StripRootDirectory returns provided fullFilePath with the root directory path removed.
func StripRootDirectory(fullFilePath string) string {
	return strings.TrimPrefix(fullFilePath, GetGitRootDirectory())
}

func GetChangelogFileName(rt ReleaseTag) string {
	return fmt.Sprintf("CHANGELOG-%s.md", rt.Tag())
}
