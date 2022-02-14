package utils

import (
	"fmt"
	"strings"
)

// GetBranchWithDotFormat return version like this: 1.20
func GetBranchWithDotFormat(branch string) string {
	return strings.Replace(branch, "-", ".", 1)
}

// GetBranchWithDotAndNumberWithDashFormat return version like this: 1.20-2
func GetBranchWithDotAndNumberWithDashFormat(branch, number string) string {
	return fmt.Sprintf("%s-%s", GetBranchWithDotFormat(branch), number)
}
