package utils

import (
	"fmt"
	"strings"
	"context"
	"github.com/google/go-github/v47/github"
)

func GetChangelogPRs(releaseVersion string) (string, error) {
	githubClient := github.NewClient(nil)

	ctx := context.Background()
	opts := &github.SearchOptions{}
	prs, _, err := githubClient.Search.Issues(ctx, "is:pr label:documentation repo:aws/eks-distro label:" + releaseVersion, opts)
	if err != nil {
		return "", fmt.Errorf("Getting PRs from %v: %v", githubClient, err)
	}
	
	var changelog []string
	changelog = append(changelog, releaseVersion)
	for _, pr := range prs.Issues {
		changelog = append(changelog, *pr.Title)
	}
	return strings.Join(changelog, "\n"), nil
}
/*
func mostRecentReleaseDocPR(tag string) (string, error) {

}

func patchPRsSinceLastRelease() (string, error) {

}

func versionChangesSinceLastRelease() (string, error) {

}

func baseImageChangesSinceLastRelease() (string, error) {

}*/
