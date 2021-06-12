package internal

import (
	"fmt"
	"io/ioutil"
	"os/exec"
	"path/filepath"
	"strings"
)

var gitRootDirectory = GetGitRootDirectory()

func GetGitRootDirectory() string {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		panic(fmt.Sprintf("Unable to get git root directory: %v", err))
	}
	return strings.Join(strings.Fields(string(gitRootOutput)), "")
}

// GetKubernetesReleaseGitTag returns the trimmed value of Kubernetes release GIT_TAG
func GetKubernetesReleaseGitTag() (string, error) {
	fileOutput, err := ioutil.ReadFile(gitRootDirectory + "/projects/kubernetes/release/GIT_TAG")
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(fileOutput)), nil
}

// FormatEnvironmentReleasePath returns path to RELEASE for provided release.
// Expects release.Branch() and release.Environment() to return non-empty values.  Returned path is not guaranteed
// to exist or be valid.
func FormatEnvironmentReleasePath(release *Release) string {
	return filepath.Join(gitRootDirectory, "release", release.Branch(), release.Environment(), "RELEASE")
}

// FormatKubeGitVersionFilePath returns path to KUBE_GIT_VERSION_FILE for provided release.
// Expects release.Branch() to return a non-empty value.  Returned path is not guaranteed to exist or be valid.
func FormatKubeGitVersionFilePath(release *Release) string {
	return filepath.Join(gitRootDirectory, "projects/kubernetes/kubernetes", release.Branch(), "KUBE_GIT_VERSION_FILE")
}

// FormatReleaseDocsDirectory returns path to the directory for the docs' directory for provided release.
// Expects release.Branch() and number to be non-empty values. Returned path is not guaranteed to exist or be valid.
func FormatReleaseDocsDirectory(release *Release, number string) string {
	return filepath.Join(gitRootDirectory, "docs/contents/releases", release.Branch(), number)
}

func GetREADMEPath() string {
	return filepath.Join(gitRootDirectory, "README.md")
}
