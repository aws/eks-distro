package internal

import (
	"fmt"
)

type ReleaseBase interface {
	ReleaseInput
	GetNumber() string
}

// GetVersionTag returns eks-<major version>-<minor version>-<patch version> (e.g. eks-1-20-2)
func GetVersionTag(base ReleaseBase) string {
	return fmt.Sprintf("eks-%s-%s", base.GetBranch(), base.GetNumber())
}

// GetReleaseTag returns v<major version>-<minor version>-eks-<patch version> (e.g. v1-20-eks-2)
func GetReleaseTag(base ReleaseBase) string {
	return fmt.Sprintf("v%s-eks-%s", base.GetBranch(), base.GetNumber())
}
