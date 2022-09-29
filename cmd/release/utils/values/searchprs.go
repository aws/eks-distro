package values

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

	lastDocRelease := prs.Issues[0].ClosedAt

	patchPRs, _, err := githubClient.Search.Issues(ctx, "repo:aws/eks-distro is:pr is:merged label:patch label:" + releaseVersion + " merged:>" + fmt.Sprintf("%v", lastDocRelease), opts)

	baseImgPRs, _, err := githubClient.Search.Issues(ctx, "repo:aws/eks-distro is:pr is:merged label:base-image-pkg-update label:" + releaseVersion + " merged:>" + fmt.Sprintf("%v", lastDocRelease), opts)

	versPRs, _, err := githubClient.Search.Issues(ctx, "repo:aws/eks-distro is:pr is:merged label:dependencies label:" + releaseVersion + " merged:>" + fmt.Sprintf("%v", lastDocRelease), opts)
	
	var changelog []string
	patchSect, _ := patchPRsSinceLastRelease(patchPRs)
	changelog = append(changelog, patchSect)
	
	versSect, _ := versionChangesSinceLastRelease(versPRs)
	changelog = append(changelog, versSect)
	
	baseImgSect, _ := baseImageChangesSinceLastRelease(baseImgPRs)
	changelog = append(changelog, baseImgSect)

	return strings.Join(changelog, "\n"), nil
}

func patchPRsSinceLastRelease(patchPRs *github.IssuesSearchResult) (string, error) {
	var patchSection []string
	patchSection = append(patchSection, "### Patches")
	
	if len(patchPRs.Issues) == 0 {
		patchSection = append(patchSection, "No patches applied since last release")
		return strings.Join(patchSection, "\n"), nil
	}

	for _, pr := range patchPRs.Issues {
		patchSection = append(patchSection, fmt.Sprintf("%v ([%v](%v), [%v](%v))", *pr.Title, *pr.ID, *pr.URL, *pr.User.Login, *pr.User.URL))
	}
	return strings.Join(patchSection, "\n"), nil
}

func versionChangesSinceLastRelease(versPRs *github.IssuesSearchResult) (string, error) {
	var versSection []string
	versSection = append(versSection, "### Dependencies")
	
	if len(versPRs.Issues) == 0 {
		versSection = append(versSection, "No changes since last release")
		return strings.Join(versSection, "\n"), nil
	}

	for _, pr := range versPRs.Issues {
		versSection = append(versSection, fmt.Sprintf("%v ([%v](%v), [%v](%v))", *pr.Title, *pr.ID, *pr.URL, *pr.User.Login, *pr.User.URL))
	}
	return strings.Join(versSection, "\n"), nil
}

func baseImageChangesSinceLastRelease(baseImgPRs *github.IssuesSearchResult) (string, error) {
	var baseImgSection []string
	baseImgSection = append(baseImgSection, "### Base Image Package Updates")

	if len(baseImgPRs.Issues) == 0 {
		baseImgSection = append(baseImgSection, "No changes since last release")
		return strings.Join(baseImgSection, "\n"), nil
	}

	for _, pr := range baseImgPRs.Issues {
		baseImgSection = append(baseImgSection, fmt.Sprintf("%v ([%v](%v), [%v](%v))", *pr.Title, *pr.ID, *pr.URL, *pr.User.Login, *pr.User.URL))
	}
	return strings.Join(baseImgSection, "\n"), nil
}
