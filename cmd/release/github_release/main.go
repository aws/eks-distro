package main

import (
	"flag"
	"fmt"
	"github.com/aws/eks-distro/cmd/release/utils"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr
)

// Generates a release on GitHub.
// IMPORTANT! Only run after the release is out, you've pulled own the
// latest changes, and the release is tagged on GitHub.
// TODO: implement number override for release
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-22")

	flag.Parse()

	release, err := utils.NewRelease(*branch, utils.GHRelease)
	if err != nil {
		log.Fatal(err)
	}
	createGitHubRelease(&release)
}

func createGitHubRelease(r *utils.Release) error {
	docsDirectory := utils.GetReleaseDocsDirectory(r.Branch(), r.Number())

	cmd := exec.Command(
		"/bin/bash",
		filepath.Join(utils.GetGitRootDirectory(), "cmd/release/github_release/create_github_release.sh"),
		r.Tag(),
		filepath.Join(docsDirectory, utils.GetChangelogFileName(r)),
		filepath.Join(docsDirectory, "index.md"),
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error creating release: %v", err)
	}

	log.Printf("Published release!\nYou can view at it https://github.com/aws/eks-distro/releases/tag/%s", r.Tag())
	return nil
}
