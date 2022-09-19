package utils

import (
	"fmt"
	"strings"
	"context"
	"github.com/google/go-github/v47/github"
)

func GetChangelogPRs(tag string) (string, error) {
	githubClient := github.NewClient(nil)

	ctx := context.Background()
	opts := &github.SearchOptions{}
	prs, _, err := githubClient.Search.Issues(ctx, "is:pr label:documentation", opts)
	if err != nil {
		return "", fmt.Errorf("PRs: %v", err)
	}
	
	var changelog []string

	for _, pr := range prs.Issues {
		changelog = append(changelog, *pr.Title)
	}
	return strings.Join(changelog, "\n"), nil
}
