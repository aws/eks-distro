package values

import (
	"bytes"
	"fmt"
	"os"
	"strconv"
	"strings"
)

var (
	supportedReleaseBranchesPath = getAbsolutePath("release", "SUPPORTED_RELEASE_BRANCHES").String()
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
	fileOutput, err := os.ReadFile(supportedReleaseBranchesPath)
	if err != nil {
		return [][]byte{}, fmt.Errorf("getting supported release branches at %s path:%w", supportedReleaseBranchesPath, err)
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

// AddNextReleaseBranch Returns added release branch if no error adding it to file
func AddNextReleaseBranch() ([]byte, error) {
	nextReleaseBranch, err := getNextReleaseBranch()
	if err != nil {
		return []byte{}, fmt.Errorf("getting next release branch to add to supported: %w", err)
	}

	releaseBranches, err := GetSupportedReleaseBranches()
	if err != nil {
		return []byte{}, fmt.Errorf("getting supported release branches to add %v: %w", nextReleaseBranch, err)
	}
	releaseBranches = append(releaseBranches, nextReleaseBranch)

	if err = os.WriteFile(supportedReleaseBranchesPath,
		append(bytes.Join(releaseBranches, []byte("\n")), []byte("\n")...), 0644); err != nil {
		return []byte{}, fmt.Errorf("writing supported release branches to file: %w", err)
	}
	return nextReleaseBranch, nil
}

func getNextReleaseBranch() ([]byte, error) {
	latestSupportedReleaseBranch, err := GetLatestSupportedReleaseBranch()
	if err != nil {
		return []byte{}, fmt.Errorf("getting lastest supported release branch to find next release branch: %w", err)
	}
	// latestSupportedReleaseBranch format expected to be 1-XX, e.g. 1-26
	prefix := string(latestSupportedReleaseBranch[:2])
	latestMinorNum, err := strconv.Atoi(string(latestSupportedReleaseBranch[2:]))
	if err != nil {
		return []byte{}, fmt.Errorf("converting the minor release number %v to int: %w", latestMinorNum, err)
	}

	return []byte(prefix + strconv.Itoa(latestMinorNum+1)), nil
}
