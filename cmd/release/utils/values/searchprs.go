package values

import (
	"context"
	"fmt"
	"strings"

	"github.com/google/go-github/v52/github"
)

const (
	baseQuery        = "repo:aws/eks-distro is:pr is:merged"
	githubTimeFormat = "2006-01-02T15:04:05+00:00"
)

func GetChangelogPRs(releaseVersion string, overrideNumber int) (string, error) {
	githubClient := github.NewClient(nil)

	ctx := context.Background()
	opts := &github.SearchOptions{Sort: "updated"}
	//Get the date of the last document release for the release version
	prs, _, err := githubClient.Search.Issues(ctx, "is:pr is:merged label:release label:documentation repo:aws/eks-distro label:"+releaseVersion, opts)
	if err != nil {
		return "", fmt.Errorf("getting PRs from %v: %w", githubClient, err)
	}

	lastDocRelease := githubTimeFormat
	prevDocRelease := githubTimeFormat
	if len(prs.Issues) > 0 {
		//Select the most recent pr from the above query and format the date expected for the go-github client
		releasePRs, _, err := githubClient.Search.Issues(ctx, "is:pr is:merged label:PROD-release label:"+releaseVersion, opts)
		if err != nil {
			return "", fmt.Errorf("get release PRs from %v: %w", githubClient, err)
		}
		lastDocRelease = releasePRs.Issues[0].ClosedAt.Format(githubTimeFormat)
		prevDocRelease = prs.Issues[0].ClosedAt.Format(githubTimeFormat)
	} else {
		//With no document releases we need to be a little bit clever to generate unannounced changelogs.
		//This finds the
		opts = &github.SearchOptions{Sort: "updated", Order: "asc"}
		prs, _, err := githubClient.Search.Issues(ctx, "is:pr is:merged label:PROD-release label:"+releaseVersion, opts)
		if err != nil {
			return "", fmt.Errorf("get PRs from %v: %w", githubClient, err)
		}
		if overrideNumber == 1 {
			lastDocRelease = prs.Issues[overrideNumber-1].ClosedAt.Format(githubTimeFormat)
		} else {
			lastDocRelease = prs.Issues[overrideNumber-1].ClosedAt.Format(githubTimeFormat)
			prevDocRelease = prs.Issues[overrideNumber-2].ClosedAt.Format(githubTimeFormat)
		}

	}

	patchPRs, _, err := githubClient.Search.Issues(ctx,
		fmt.Sprintf("%v merged:%v..%v label:patch label:%v", baseQuery, prevDocRelease, lastDocRelease, releaseVersion), opts)
	if err != nil {
		return "", fmt.Errorf("getting patch prs: %w", err)
	}

	baseImgPRs, _, err := githubClient.Search.Issues(ctx,
		fmt.Sprintf("%v merged:%v..%v label:base-img-pkg-update", baseQuery, prevDocRelease, lastDocRelease), opts)
	if err != nil {
		return "", fmt.Errorf("getting base image prs: %w", err)
	}

	versPRs, _, err := githubClient.Search.Issues(ctx, fmt.Sprintf("%v merged:%v..%v label:project label:%v",
		baseQuery, prevDocRelease, lastDocRelease, releaseVersion), opts)
	if err != nil {
		return "", fmt.Errorf("getting project prs: %w", err)
	}

	var changelog []string
	changelog = append(changelog, PRsSinceLastRelease(patchPRs, "### Patches"))
	changelog = append(changelog, PRsSinceLastRelease(versPRs, "### Projects"))
	changelog = append(changelog, PRsSinceLastRelease(baseImgPRs, "### Base Image"))

	return strings.Join(changelog, "\n"), nil
}

func PRsSinceLastRelease(prs *github.IssuesSearchResult, sectionName string) string {
	var section []string
	section = append(section, sectionName)

	if len(prs.Issues) == 0 {
		section = append(section, "No changes since last release")
	}

	for _, pr := range prs.Issues {
		section = append(section, fmt.Sprintf("* %v ([%v](%v))", *pr.Title, *pr.Number, *pr.HTMLURL))
	}
	return strings.Join(section, "\n") + "\n"
}
