package projects

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/aws/eks-distro/cmd/release/utils/values"
)

var projectPathRoot = filepath.Join(values.GetGitRootDirectory(), "projects")

type Project struct {
	org  string
	repo string
}

func GetProjects() ([]Project, error) {
	orgDirs, err := os.ReadDir(projectPathRoot)
	if err != nil {
		return []Project{}, fmt.Errorf("reading projects path: %w", err)
	}

	var projects []Project
	// Iterate through projects/<org>
	for _, orgDir := range orgDirs {
		if !orgDir.IsDir() {
			continue
		}
		repoDirs, err := os.ReadDir(filepath.Join(projectPathRoot, orgDir.Name()))
		if err != nil {
			return []Project{}, fmt.Errorf("reading repos paths: %w", err)
		}
		// Iterate through projects/<org>/<repo>
		for _, repoDir := range repoDirs {
			if repoDir.IsDir() {
				projects = append(projects, Project{org: orgDir.Name(), repo: repoDir.Name()})
			}
		}
	}
	return projects, nil
}

func (p *Project) GetFilePath() string {
	return filepath.Join(projectPathRoot, p.org, p.repo)
}

func (p *Project) GetRepo() string {
	return p.repo
}

func (p *Project) GetOrg() string {
	return p.org
}

func (p *Project) GetGitHubURL() string {
	return fmt.Sprintf("https://github.com/%s/%s", p.GetOrg(), p.GetRepo())
}

func (p *Project) GetVersion(releaseBranch string) (Version, error) {
	releaseBranchPath := filepath.Join(p.GetFilePath(), releaseBranch)
	gitTagVersion, err := readGitTagVersionFile(releaseBranchPath)
	if err != nil {
		return Version{}, fmt.Errorf("getting GitTag version: %w", err)
	}
	golangVersion, err := readGolangVersionFile(releaseBranchPath)
	if err != nil {
		return Version{}, fmt.Errorf("getting Golang version: %w", err)
	}
	return Version{
		gitTag: string(gitTagVersion),
		golang: string(golangVersion),
	}, nil
}

func GetProjectPathRoot() string {
	return projectPathRoot
}
