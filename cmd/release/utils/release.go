package utils

import (
	"errors"
	"fmt"
	"strings"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

type Release struct {
	branch string
	number string

<<<<<<< HEAD
	kubernetesMinorVersion string // e.g. 1.23
	tag                    string // e.g. v1-23-eks-1
=======
	kubernetesGitTag       string // e.g. v1.20.1
	tag                    string // e.g. v1-20-eks-2
>>>>>>> ccfa845 (Logic for getting and returning KubernetesVersion)
	manifestURL            string // e.g. https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-1.yaml
}

// NewRelease returns complete Release based on the provided inputBranch
func NewRelease(releaseBranch string, ct changetype.ChangeType) (*Release, error) {
	if ct.IsDevOrProd() {
		return &Release{}, errors.New("release cannot be for prod or dev, as it assumes these changes are done")
	}
	releaseBranch = strings.TrimSpace(releaseBranch)
	if len(releaseBranch) == 0 {
		return &Release{}, errors.New("branch cannot be an empty string")
	}

	currNum, _, err := values.GetLocalNumber(releaseBranch, changetype.Prod)
	if err != nil {
		return &Release{}, fmt.Errorf("determining number: %w", err)
	}
	
	k8sGitTag, err := GetGitTag("kubernetes", "kubernetes", releaseBranch)
	if err != nil {
		return Release{}, fmt.Errorf("Kubernetes Git Tag: %v", err)
	}

	return &Release{
		branch:                 releaseBranch,
		number:                 currNum,
		kubernetesGitTag:       fmt.Sprintf("%s", k8sGitTag),
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

// KubernetesGitTag return the full kubernetes version. Example: v.1.23.7
func (r *Release) KubernetesGitTag() string {
	return r.kubernetesGitTag
}

// KubernetesURL returns the url to the Kubernetes version release. Example: https://github.com/kubernetes/kubernetes/release/tag/v1.23.7
func (r *Release) KubernetesURL() string {
	return fmt.Sprintf("https://github.com/kubernetes/kubernetes/release/tag/%s", r.kubernetesGitTag)
}
// KubernetesMinorVersion returns the minor version. Example: 1.24
func (r *Release) KubernetesMinorVersion() string {
	return r.kubernetesGitTag[1:5]
}

// Tag returns v<branch>-eks-<number>. Example: v1-23-eks-1
func (r *Release) Tag() string {
	return r.tag
}

// ManifestURL returns manifest url. Example: https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-1.yaml
func (r *Release) ManifestURL() string {
	return r.manifestURL
}
