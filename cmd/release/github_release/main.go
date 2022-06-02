package main

import (
	. "github.com/aws/eks-distro/cmd/release/utils"

	"flag"
	"fmt"
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
// TODO: update after refactor is done
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-22")
	number := flag.String("number", "", "Release branch, e.g. 5")

	flag.Parse()

	err := createRelease(*branch, *number)
	if err != nil {
		log.Fatal(err)
	}
}

func createRelease(branch, number string) error {
	docsDirectory := fmt.Sprintf("%s/docs/contents/releases/%s/%s", GetGitRootDirectory(), branch, number)
	changelogFilepath := fmt.Sprintf("%s/CHANGELOG-v%s-eks-%s.md", docsDirectory, branch, number)
	indexFilepath := fmt.Sprintf("%s/index.md", docsDirectory)

	releaseGitTag := fmt.Sprintf("v%s-eks-%s", branch, number)
	releaseVersion := "REPLACE WITH release.version" //"v" + GetBranchWithDotAndNumberWithDashFormat(branch, number)

	cmd := exec.Command(
		"/bin/bash",
		filepath.Join(GetGitRootDirectory(), "cmd/release/github_release/create_github_release.sh"),
		releaseGitTag,
		releaseVersion,
		changelogFilepath,
		indexFilepath,
	)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error creating release: %v", err)
	}

	log.Printf(
		"Published release!\nYou can view at it https://github.com/aws/eks-distro/releases/tag/%s",
		releaseGitTag)
	return nil
}
