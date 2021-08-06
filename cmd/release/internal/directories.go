package internal

import (
	"fmt"
	"io/ioutil"
	"os/exec"
	"path/filepath"
	"strings"
)

var (
	gitRootDirectory = GetGitRootDirectory()
	docsContentsDirectory = filepath.Join(gitRootDirectory, "docs/contents")
	baseImagePath = filepath.Join(gitRootDirectory, "EKS_DISTRO_BASE_TAG_FILE")
)


func GetGitRootDirectory() string {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		panic(fmt.Sprintf("Unable to get git root directory: %v", err))
	}
	return strings.Join(strings.Fields(string(gitRootOutput)), "")
}

// GetKubernetesReleaseGitTag returns the trimmed value of Kubernetes release GIT_TAG
func GetKubernetesReleaseGitTag(releaseBranch string) (string, error) {
	fileOutput, err := ioutil.ReadFile(fmt.Sprintf("%s/projects/kubernetes/release/%s/GIT_TAG", gitRootDirectory, releaseBranch))
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(fileOutput)), nil
}

// formatEnvironmentReleasePath returns path to RELEASE for provided branch and environment. Returned path is not
// guaranteed to exist or be valid.
func formatEnvironmentReleasePath(branch string, environment ReleaseEnvironment) string {
	return filepath.Join(gitRootDirectory, "release", branch, environment.String(), "RELEASE")
}

// FormatKubeGitVersionFilePath returns path to KUBE_GIT_VERSION_FILE for provided release.
// Expects release.Branch() to return a non-empty value.  Returned path is not guaranteed to exist or be valid.
func FormatKubeGitVersionFilePath(release *Release) string {
	return filepath.Join(gitRootDirectory, "projects/kubernetes/kubernetes", release.Branch(), "KUBE_GIT_VERSION_FILE")
}

// formatReleaseDocsDirectory returns path to the directory for the docs' directory for provided release.
// Expects branch and number to be non-empty values. Returned path is not guaranteed to exist or be valid.
func formatReleaseDocsDirectory(branch, number string) string {
	return filepath.Join(docsContentsDirectory, FormatRelativeReleaseDocsDirectory(branch, number))
}

// FormatRelativeReleaseDocsDirectory return relative path to (example: "releases/1-20/1").
// Expects release.Branch() and release.Number() to be non-empty values.
func FormatRelativeReleaseDocsDirectory(branch, number string) string {
	return filepath.Join("releases", branch, number)
}

func GetREADMEPath() string {
	return filepath.Join(gitRootDirectory, "README.md")
}

func GetDocsIndexPath() string {
	return filepath.Join(docsContentsDirectory, "index.md")
}
