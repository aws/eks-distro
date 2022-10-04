package values

import (
	"fmt"
	"strings"
	"context"

	"github.com/google/go-github/v47/github"
)

const (
	baseQuery = "repo:aws/eks-distro is:pr is:merged"
)

func GetChangelogPRs(releaseVersion string) (string, error) {
	githubClient := github.NewClient(nil)

	ctx := context.Background()
	opts := &github.SearchOptions{}
	prs, _, err := githubClient.Search.Issues(ctx, "is:pr label:documentation repo:aws/eks-distro label:" + releaseVersion, opts)
	if err != nil {
		return "", fmt.Errorf("Getting PRs from %v: %v", githubClient, err)
	}

	lastDocRelease := prs.Issues[0].ClosedAt.Format("2006-01-02T15:04:05+00:00")
	
	patchPRs, _, err := githubClient.Search.Issues(ctx, fmt.Sprintf("%v merged:>%v label:patch label:%v", baseQuery, lastDocRelease, releaseVersion), opts)

	baseImgPRs, _, err := githubClient.Search.Issues(ctx, fmt.Sprintf("%v merged:>%v label:base-img-pkg-update label:%v",baseQuery, lastDocRelease, releaseVersion), opts)

	versPRs, _, err := githubClient.Search.Issues(ctx, fmt.Sprintf("%v merged:>%v label:project label:%v",baseQuery, lastDocRelease, releaseVersion), opts)
	
	var changelog []string
	changelog = append(changelog, PRsSinceLastRelease(patchPRs, "### Patches"))
	changelog = append(changelog, PRsSinceLastRelease(versPRs, "### Projects"))
	changelog = append(changelog, PRsSinceLastRelease(baseImgPRs, "### Base Image"))

	return strings.Join(changelog, "\n"), nil
}

func PRsSinceLastRelease(prs *github.IssuesSearchResult, sectionName string) (string) {
	var section []string
	section = append(section, sectionName)

	if len(prs.Issues) == 0 {
		section = append(section, "No changes since last release")
	}

	for _, pr := range prs.Issues {
		section = append(section, fmt.Sprintf("* %v ([%v](%v))", *pr.Title, *pr.ID, *pr.URL))
	}
	return strings.Join(section, "\n")
}
