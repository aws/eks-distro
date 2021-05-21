package internal

import (
	"fmt"
	"log"
	"os/exec"
	"path/filepath"
	"strings"
)

var gitRootDirectory = GetGitRootDirectory()

type ReleaseInput interface {
	GetBranch() string
	GetEnvironment() string
}

func GetGitRootDirectory() string {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		panic(fmt.Sprintf("Unable to get git root directory: %v", err))
	}
	return strings.Join(strings.Fields(string(gitRootOutput)), "")
}

// FormatEnvironmentReleasePath returns path to RELEASE for provided release.
// Expects release.GetBranch() and release.GetEnvironment() to return non-empty values. Returned path is not guaranteed
// to exist.
func FormatEnvironmentReleasePath(release ReleaseInput) string {
	return filepath.Join(gitRootDirectory, "release", release.GetBranch(), release.GetEnvironment(), "RELEASE")
}

// FormatKubeGitVersionFilePath returns path to KUBE_GIT_VERSION_FILE for provided release.
// Expects release.GetBranch() to return a non-empty value. Returned path is not guaranteed to exist.
func FormatKubeGitVersionFilePath(release ReleaseInput) string {
	return filepath.Join(gitRootDirectory, "projects/kubernetes/kubernetes", release.GetBranch(), "KUBE_GIT_VERSION_FILE")
}

// RestoreFilePath attempts to restore filepath known to this package
func RestoreFilePath(release ReleaseInput) () {
	paths := []string{
		FormatEnvironmentReleasePath(release),
		FormatKubeGitVersionFilePath(release),
	}

	for _, path := range paths {
		err := exec.Command("git", "restore", path).Run()
		if err == nil {
			log.Printf("If changes were made, restored %s", path)
		}
	}
}
