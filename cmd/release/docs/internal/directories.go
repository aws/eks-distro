package internal

import (
	. "../../utils"
	"fmt"
	"io/ioutil"
	"path/filepath"
	"strings"
)

var (
	gitRootDirectory = GetGitRootDirectory()

	READMEPath = filepath.Join(gitRootDirectory, "README.md")

	docsContentsDirectory = filepath.Join(gitRootDirectory, "docs/contents")
	DocsIndexPath         = filepath.Join(docsContentsDirectory, "index.md")
)

// GetKubernetesReleaseGitTag returns the trimmed value of Kubernetes release GIT_TAG
func GetKubernetesReleaseGitTag(releaseBranch string) (string, error) {
	fileOutput, err := ioutil.ReadFile(fmt.Sprintf("%s/projects/kubernetes/release/%s/GIT_TAG", gitRootDirectory, releaseBranch))
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(fileOutput)), nil
}

// formatReleaseDocsDirectory returns path to the directory for the docs' directory for provided release.
// Expects branch and number to be non-empty values. Returned path is not guaranteed to exist or be valid.
func formatReleaseDocsDirectory(branch, number string) string {
	return filepath.Join(docsContentsDirectory, FormatRelativeReleaseDocsDirectory(branch, number))
}

// FormatRelativeReleaseDocsDirectory return relative path to (example: "releases/1-20/1").
// Expects branch and number to be non-empty values.
func FormatRelativeReleaseDocsDirectory(branch, number string) string {
	return filepath.Join("releases", branch, number)
}
