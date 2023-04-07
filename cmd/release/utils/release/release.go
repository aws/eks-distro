package release

import (
	"fmt"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
)

const (
	MinNumber               = 0
	InvalidNumberUpperLimit = MinNumber - 1
)

type Release struct {
	branch string
	number string

	kubernetesGitTag string // e.g. v1.23.1
	tag              string // e.g. v1-23-eks-1
	manifestURL      string // e.g. https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-1.yaml
}

// NewRelease returns complete Release based on the provided inputBranch. Provided ct cannot be dev or prod.
func NewRelease(rb string, ct changetype.ChangeType) (*Release, error) {
	if ct.IsDevOrProd() {
		return &Release{}, fmt.Errorf("release cannot be for prod or dev, as it assumes these changes are done")
	}

	r, err := newRelease(rb, "", false)
	if err != nil {
		return &Release{}, fmt.Errorf("creating release values: %w", err)
	}
	return r, nil
}

// NewReleaseOverrideNumber pities the fool who trifles with it.
// This function disregards the usual process of getting the release number from the local environment (like NewRelease
// does) and instead uses the provided overrideNumber value to produce the number and other number-dependent values in
// the returned release. This can cause many unexpected problems, so this function must be used with the upmost caution.
// Unless there is a VERY specific reason to use this function, NewRelease should be used instead.
func NewReleaseOverrideNumber(rb string, overrideNumber string) (*Release, error) {
	r, err := newRelease(rb, overrideNumber, true)
	if err != nil {
		return &Release{}, fmt.Errorf("creating release values with override number: %w", err)
	}
	return r, nil
}

// Branch return the release branch. Example: 1-23
func (r *Release) Branch() string {
	return r.branch
}

// Number return the release number. Example: 1
func (r *Release) Number() string {
	return r.number
}

// KubernetesGitTag return the full kubernetes version. Example: v1.23.7
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
