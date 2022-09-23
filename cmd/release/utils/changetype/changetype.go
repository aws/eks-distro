package changetype

import "fmt"

type ChangeType string

const (
	Dev       ChangeType = "development"
	Prod      ChangeType = "production"
	Docs      ChangeType = "docs"
	GHRelease ChangeType = "gh_release"
)

func (ct ChangeType) String() string {
	return string(ct)
}

func (ct ChangeType) IsDevOrProd() bool {
	return ct == Dev || ct == Prod
}

func (ct ChangeType) GetDescription(version string) (string, error) {
	if ct.IsDevOrProd() {
		return fmt.Sprintf("Bumped %s release number for %s", ct.String(), version), nil
	} else if ct == Docs {
		return "Created and updated docs for " + version, nil
	} else {
		return "", fmt.Errorf("unknown ChangeType %v", ct)
	}
}
