package values

import (
	"fmt"
	"os"
	"path/filepath"
)

var projectPath = filepath.Join(GetGitRootDirectory(), "projects")

type Project struct {
	org  string
	repo string
}

func GetProjects() ([]Project, error) {
	orgDirs, err := os.ReadDir(projectPath)
	if err != nil {
		return []Project{}, fmt.Errorf("reading projects path: %w", err)
	}

	var projects []Project
	// Iterate through projects/<org>
	for _, orgDir := range orgDirs {
		if !orgDir.IsDir() {
			continue
		}
		repoDirs, err := os.ReadDir(filepath.Join(projectPath, orgDir.Name()))
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
	return filepath.Join(projectPath, p.org, p.repo)
}
