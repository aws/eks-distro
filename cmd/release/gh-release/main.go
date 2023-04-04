package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/release"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr

	ghReleaseScriptPath = filepath.Join(values.GetGitRootDirectory(), "cmd/release/gh-release/create.sh")
)

// Generates a release on GitHub. IMPORTANT! Only run after the prod release is out, you've pulled down the latest
// changes, and the git tag for the release is on GitHub.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-22")
	overrideNumber := flag.Int("overrideNumber", release.InvalidNumberUpperLimit, "Optional override number, e.g. 1")

	flag.Parse()

	var err error
	var r = &release.Release{}
	if *overrideNumber <= release.InvalidNumberUpperLimit {
		r, err = release.NewRelease(*branch, changetype.GHRelease)
		if err != nil {
			log.Fatalf("creating release values: %v", err)
		}
	} else {
		r, err = release.NewReleaseOverrideNumber(*branch, strconv.Itoa(*overrideNumber))
		if err != nil {
			log.Fatalf("creating release values with override number: %v", err)
		}
	}

	if err = createGitHubRelease(r); err != nil {
		log.Fatalf("creating GitHub release: %v", err)
	}
}

func createGitHubRelease(r *release.Release) error {
	docsDirectory := values.GetReleaseDocsDirectory(r).String()

	cmd := exec.Command(
		"/bin/bash",
		ghReleaseScriptPath,
		r.Tag(),
		filepath.Join(docsDirectory, values.GetChangelogFileName(r)),
		filepath.Join(docsDirectory, "index.md"),
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("creating release from script: %w", err)
	}

	log.Printf("Published release!\nYou can view at it https://github.com/aws/eks-distro/releases/tag/%s\n", r.Tag())
	return nil
}
