package values

import (
	"path/filepath"
	"strings"
)

var (
	IndexPath  = getAbsolutePath("docs", "contents", IndexFileName)
	ReadmePath = getAbsolutePath("README.md")
)

type PathValues interface {
	Branch() string
	Number() string
}

// GetReleaseDocsDirectory returns the expected and absolute filepath for the doc directory for the provided PathValues.
// There is no guarantee this directory actually exists. The filepath is simply where it should exist.
// Example: ~/go/eks-distro/docs/contents/releases/1-24/1
func GetReleaseDocsDirectory(pv PathValues) AbsolutePath {
	return getAbsolutePath("docs", "contents", "releases", pv.Branch(), pv.Number())
}

func getGitTagPath(projectOrg, projectName, releaseBranch string) AbsolutePath {
	return getAbsolutePath("projects", projectOrg, projectName, releaseBranch, "GIT_TAG")
}

func getNumberPath(branch, changeTypeString string) AbsolutePath {
	return getAbsolutePath("release", branch, changeTypeString, "RELEASE")
}

type AbsolutePath string

func (ap AbsolutePath) String() string {
	return string(ap)
}

// StripRootDirectory returns the absolute file path with the root directory path removed.
func (ap AbsolutePath) StripRootDirectory() string {
	return strings.TrimPrefix(ap.String(), GetGitRootDirectory()+"/")
}

func getAbsolutePath(parentDirs ...string) AbsolutePath {
	return AbsolutePath(filepath.Join(GetGitRootDirectory(), filepath.Join(parentDirs...)))
}
