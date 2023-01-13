package values

import (
	"bytes"
	"fmt"
	"os"
	"strings"
)

var (
	SupportedReleaseBranchesPath = getAbsolutePath("release", "SUPPORTED_RELEASE_BRANCHES").String()
	defaultReleaseBranchPath     = getAbsolutePath("release", "DEFAULT_RELEASE_BRANCH").String()
)

func IsDefaultReleaseBranch(providedReleaseBranch string) (bool, error) {
	fileOutput, err := os.ReadFile(defaultReleaseBranchPath)
	if err != nil {
		return false, fmt.Errorf("getting default release branch at %s path:%w", defaultReleaseBranchPath, err)
	}
	defaultReleaseBranch := strings.TrimSpace(string(fileOutput))
	return strings.Compare(providedReleaseBranch, defaultReleaseBranch) == 0, nil
}

func IsSupportedReleaseBranch(rb string) (bool, error) {
	supportedReleaseBranches, err := GetSupportedReleaseBranches()
	if err != nil {
		return false, fmt.Errorf("getting release branches to check if %s is supported: %w", rb, err)
	}

	providedReleaseBranch := []byte(rb)
	for _, supportedReleaseBranch := range supportedReleaseBranches {
		if bytes.Equal(supportedReleaseBranch, providedReleaseBranch) {
			return true, nil
		}
	}
	return false, nil
}

func GetSupportedReleaseBranches() ([][]byte, error) {
	fileOutput, err := os.ReadFile(SupportedReleaseBranchesPath)
	if err != nil {
		return [][]byte{}, fmt.Errorf("getting supported release branches at %s path:%w", SupportedReleaseBranchesPath, err)
	}
	return bytes.Split(bytes.TrimSpace(fileOutput), []byte("\n")), nil
}

func GetLatestSupportedReleaseBranch() ([]byte, error) {
	supportedReleaseBranches, err := GetSupportedReleaseBranches()
	if err != nil {
		return []byte{}, fmt.Errorf("getting release branches to find lastest supported release branches: %w", err)
	}
	return supportedReleaseBranches[len(supportedReleaseBranches)-1], nil
}
