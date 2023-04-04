package release

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

const defaultReleaseEnv = changetype.Prod

func newRelease(releaseBranchInput string, overrideNumInput string, hasOverrideNum bool) (*Release, error) {
	rb, num, err := generateReleaseInput(releaseBranchInput, overrideNumInput, hasOverrideNum)
	if err != nil {
		if hasOverrideNum {
			return &Release{}, fmt.Errorf("creating release input with override number: %w", err)
		}
		return &Release{}, fmt.Errorf("creating release input: %w", err)
	}

	k8sGitTag, err := values.GetGitTag("kubernetes", "kubernetes", rb)
	if err != nil {
		return &Release{}, fmt.Errorf("getting Kubernetes Git Tag: %w", err)
	}

	return &Release{
		branch:           rb,
		number:           num,
		kubernetesGitTag: string(k8sGitTag),
		tag:              fmt.Sprintf("v%s-eks-%s", rb, num),
		manifestURL: fmt.Sprintf("https://distro.eks.amazonaws.com/kubernetes-%s/kubernetes-%s-eks-%s.yaml",
			rb, rb, num),
	}, nil
}

// createNewReleaseInput returns
func generateReleaseInput(releaseBranchInput string, overrideNumInput string, hasOverrideNum bool) (string, string, error) {
	overrideNum := strings.TrimSpace(overrideNumInput)
	if hasOverrideNum && len(overrideNum) == 0 {
		return "", "", fmt.Errorf("expected non-empty override number")
	}

	releaseBranch := strings.TrimSpace(releaseBranchInput)
	if len(releaseBranch) == 0 {
		return "", "", fmt.Errorf("release branch cannot be an empty string")
	}

	// Release Branch must be a supported release branch
	if isSupported, err := values.IsSupportedReleaseBranch(releaseBranch); !isSupported || err != nil {
		if err != nil {
			return "", "", fmt.Errorf("checking if supported release branch: %w", err)
		}
		return "", "", fmt.Errorf("branch %s is not a supported release branch", releaseBranch)
	}

	// If provided, override number much be greater than or equal to minOverrideNumber. If override number is not
	// provided,
	var number string
	localNum, _, err := values.GetLocalNumber(releaseBranch, defaultReleaseEnv)
	if err != nil {
		return "", "", fmt.Errorf("determining number: %w", err)
	}
	if hasOverrideNum {
		if strings.Compare(strconv.Itoa(MinNumber), overrideNum) == 1 || strings.Compare(overrideNum, localNum) == 1 {
			return "", "", fmt.Errorf("override number %s must between min number %d and local number %s (inclusive)",
				overrideNum, MinNumber, localNum)
		}
		number = overrideNum
	} else {
		number = localNum
	}

	return releaseBranch, number, nil
}
