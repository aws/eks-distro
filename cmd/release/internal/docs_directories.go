package internal

import (
	"log"
	"os/exec"
	"path/filepath"
)

// FormatReleaseDocsDirectory returns path to the directory for the docs directory for provided release.
// Expects release.GetBranch() and release.GetNumber() to return non-empty values. Returned path is not guaranteed to
// exist.
func FormatReleaseDocsDirectory(release ReleaseBase) string {
	return filepath.Join(gitRootDirectory, "docs/contents/releases", release.GetBranch(), release.GetNumber())
}

// DeleteDocsPath attempts to delete generated docs
func DeleteDocsPath(release ReleaseBase) () {
	paths := []string{
		FormatReleaseDocsDirectory(release),
	}

	for _, path := range paths {
		err := exec.Command("rm", "-rf", path).Run()
		if err == nil {
			log.Printf("If it existsed, deleted file %s", path)
		}
	}
}