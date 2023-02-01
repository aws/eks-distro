package main

import (
	"fmt"
	"log"

	"github.com/aws/eks-distro/cmd/release/utils/projects"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

// Prints GitTag and Golang versions for each project and release branch.
// Uses local values, which may differ from what's in the upstream EKS-D repo
// or the versions in the current releases.
func main() {
	eksdProjects, err := projects.GetProjects()
	if err != nil {
		log.Fatalf("getting projects: %v", err)
	}

	releaseBranches, err := values.GetSupportedReleaseBranchesStrings()
	if err != nil {
		log.Fatalf("getting suppoerted release branches: %v", err)
	}

	for _, project := range eksdProjects {
		fmt.Printf("\n%s / %s\n", project.GetOrg(), project.GetRepo())
		for _, rb := range releaseBranches {
			version, err := project.GetVersion(rb)
			if err != nil {
				log.Fatalf("getting %s/%s versions for %s: %v", project.GetOrg(), project.GetRepo(), rb, err)
			}
			fmt.Printf("  ◦ %s  ➜  %-10s%s\n", rb, version.GetGitTag(), version.GetGolang())
		}
		fmt.Printf("  %s/tags\n", project.GetGitHubURL())
	}
	println()
}
