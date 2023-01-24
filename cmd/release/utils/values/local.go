package values

import (
	"bytes"
	"fmt"
	"os"
	"strings"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
)

// GetLocalNumber returns the current number and the filepath to the local file used to determine that number for the
// provided branch and ct. The returned num only reflects the local environment and may not match the upstream source's
// current number for the branch or ct. Pulling down upstream changes before using this function is highly recommended.
// Provided branch must exist, the provided ct must be Dev or Prod, and the release number file must exist in the
// expected location (e.g., /Users/lovelace/go/eks-distro/release/1-24/development/RELEASE)
func GetLocalNumber(branch string, ct changetype.ChangeType) (num string, numPath AbsolutePath, err error) {
	numPath = getNumberPath(branch, ct.String())
	fileOutput, err := os.ReadFile(numPath.String())
	if err != nil {
		return "", "", fmt.Errorf("reading number from %s file: %w", numPath, err)
	}
	return strings.TrimSpace(string(fileOutput)), numPath, nil
}

func GetGitTag(projectOrg, projectName, releaseBranch string) ([]byte, error) {
	gitTagPath := getGitTagPath(projectOrg, projectName, releaseBranch)
	fileOutput, err := os.ReadFile(gitTagPath.String())
	if err != nil {
		return []byte{}, fmt.Errorf("reading git tag at %s path:%w", gitTagPath, err)
	}
	return bytes.TrimSpace(fileOutput), nil
}
