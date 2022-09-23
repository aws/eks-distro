package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/aws/eks-distro/cmd/release/utils"
	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr

	ghReleaseScriptPath = filepath.Join(values.GetGitRootDirectory(), "cmd/release/gh-release/create.sh")
)

// Generates a release on GitHub. IMPORTANT! Only run after the prod release is out, you've pulled down the latest
// changes, and the git tag for the release is on GitHub.
// TODO: implement number override for release
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-22")
	flag.Parse()

	release, err := utils.NewRelease(*branch, changetype.GHRelease)
	if err != nil {
		log.Fatalf("creating release values: %v", err)
	}
	if err = createGitHubRelease(release); err != nil {
		log.Fatalf("creating GitHub release: %v", err)
	}
}

func createGitHubRelease(r *utils.Release) error {
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
