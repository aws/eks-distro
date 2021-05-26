package internal

import (
	"fmt"
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
// Expects release.GetBranch() and release.GetEnvironment() to return non-empty values.  Returned path is not guaranteed
// to exist or be valid.
func FormatEnvironmentReleasePath(release ReleaseInput) string {
	return filepath.Join(gitRootDirectory, "release", release.GetBranch(), release.GetEnvironment(), "RELEASE")
}

// FormatKubeGitVersionFilePath returns path to KUBE_GIT_VERSION_FILE for provided release.
// Expects release.GetBranch() to return a non-empty value.  Returned path is not guaranteed to exist or be valid.
func FormatKubeGitVersionFilePath(release ReleaseInput) string {
	return filepath.Join(gitRootDirectory, "projects/kubernetes/kubernetes", release.GetBranch(), "KUBE_GIT_VERSION_FILE")
}

// FormatReleaseDocsDirectory returns path to the directory for the docs' directory for provided release.
// Expects release.GetBranch() and number to be non-empty values. Returned path is not guaranteed to exist or be valid.
func FormatReleaseDocsDirectory(release ReleaseInput, number string) string {
	return filepath.Join(gitRootDirectory, "docs/contents/releases", release.GetBranch(), number)
}
