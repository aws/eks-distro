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
