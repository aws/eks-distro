package utils

import (
	"errors"
	"fmt"
	"strings"
)

type Release struct {
	branch string
	number string

	kubernetesMinorVersion string // e.g. 1.20
	tag                    string // e.g. v1-20-eks-2
	manifestURL            string // e.g. https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-1.yaml
}

// NewRelease returns complete Release based on the provided inputBranch
func NewRelease(releaseBranch string, changesType ChangesType) (Release, error) {
	if changesType.IsDevOrProd() {
		return Release{}, errors.New("release cannot be for prod or dev, as it assumes these changes are done")
	}
	releaseBranch = strings.TrimSpace(releaseBranch)
	if len(releaseBranch) == 0 {
		return Release{}, errors.New("branch cannot be an empty string")
	}

	currNum, _, err := GetNumber(releaseBranch, Prod)
	if err != nil {
		return Release{}, fmt.Errorf("error determining number: %v", err)
	}

	return Release{
		branch:                 releaseBranch,
		number:                 currNum,
		kubernetesMinorVersion: strings.Replace(releaseBranch, "-", ".", 1),
		tag:                    fmt.Sprintf("v%s-eks-%s", releaseBranch, currNum),
		manifestURL: fmt.Sprintf("https://distro.eks.amazonaws.com/kubernetes-%s/kubernetes-%s-eks-%s.yaml",
			releaseBranch, releaseBranch, currNum),
	}, nil
}

func (r *Release) Branch() string {
	return r.branch
}

func (r *Release) Number() string {
	return r.number
}

// KubernetesMinorVersion returns the minor version. Example: 1.24
func (r *Release) KubernetesMinorVersion() string {
	return r.kubernetesMinorVersion
}

// Tag returns v<branch>-eks-<number>. Example: v1-24-eks-7
func (r *Release) Tag() string {
	return r.tag
}

// ManifestURL returns manifest url. Example: https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-1.yaml
func (r *Release) ManifestURL() string {
	return r.manifestURL
}
