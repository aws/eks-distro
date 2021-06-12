package internal

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"strings"
)

type Release struct {
	branch      string
	environment string
	number      string
	prevNumber  string

	// File paths, which are not guaranteed to be valid or existing
	EnvironmentReleasePath string
	KubeGitVersionFilePath string
	DocsDirectoryPath      string

	// Version notations
	BranchEKSNumber            string // e.g. 1-20-eks-2
	BranchEKSPreviousNumber    string // e.g. 1-20-eks-1
	EKSBranchNumber            string // e.g. eks-1-20-2
	EKSBranchPreviousNumber    string // e.g. eks-1-20-1
	K8sBranchEKSNumber         string // e.g. Kubernetes-1-20-eks-2
	K8sBranchEKSPreviousNumber string // e.g. Kubernetes-1-20-eks-1
	VBranchEKSNumber           string // e.g. v1-20-eks-2
	VBranchWithDotNumber       string // e.g. v1.20-2

	// Expected url but release manifest may not exist
	ManifestURL string
}

// NewReleaseWithOverrideNumber returns complete Release based on the provided ReleaseInput and overrideNumber
//
// For default determination of number and prevNumber, use overrideNumber with value of -1.
// All values over -1 for overrideNumber forces number to be overrideNumber and prevNumber to be one less. However,
// prevNumber cannot be less than 0, so it is left empty if overrideNumber is 0. The use of overrideNumber should be
// done with caution. Disrupting the conventional process can result in unintentional and unexpected consequences.
func NewReleaseWithOverrideNumber(inputBranch, inputEnvironment string, overrideNumber int) (*Release, error) {
	return newRelease(inputBranch, inputEnvironment, overrideNumber)
}

// NewRelease returns complete Release based on the provided ReleaseInput
func NewRelease(inputBranch, inputEnvironment string) (*Release, error) {
	return newRelease(inputBranch, inputEnvironment, -1)
}

func newRelease(inputBranch, inputEnvironment string, overrideNumber int) (*Release, error) {
	err := checkInput(inputBranch, inputEnvironment)
	if err != nil {
		return &Release{}, fmt.Errorf("invlid input for release: %v", err)
	}

	release := &Release{
		branch:      inputBranch,
		environment: inputEnvironment,
	}

	release.EnvironmentReleasePath = FormatEnvironmentReleasePath(release)
	release.KubeGitVersionFilePath = FormatKubeGitVersionFilePath(release)

	if overrideNumber > -1 {
		release.number, release.prevNumber = determineOverrideNumberAndPrevNumber(overrideNumber)
	} else {
		release.prevNumber, err = determinePreviousReleaseNumber(release)
		if err != nil {
			return &Release{}, fmt.Errorf("error determining previous number: %v", err)
		}
		release.number, err = determineReleaseNumber(release)
		if err != nil {
			return &Release{}, fmt.Errorf("error determining number: %v", err)
		}
	}

	release.DocsDirectoryPath = FormatReleaseDocsDirectory(release, release.number)

	release.BranchEKSNumber = formatBranchEKSNumber(release.branch, release.number)
	release.BranchEKSPreviousNumber = formatBranchEKSNumber(release.branch, release.prevNumber)
	release.EKSBranchNumber = formatEKSBranchNumber(release.branch, release.number)
	release.EKSBranchPreviousNumber = formatEKSBranchNumber(release.branch, release.prevNumber)
	release.K8sBranchEKSNumber = "kubernetes-" + release.BranchEKSNumber
	release.K8sBranchEKSPreviousNumber = "kubernetes-" + release.BranchEKSPreviousNumber
	release.VBranchEKSNumber = "v" + release.BranchEKSNumber
	release.VBranchWithDotNumber = fmt.Sprintf("v%s-%s", strings.Replace(release.branch, "-", ".", 1), release.number)

	release.ManifestURL = fmt.Sprintf(
		"https://distro.eks.amazonaws.com/kubernetes-%s/kubernetes-%s.yaml",
		release.branch,
		release.BranchEKSNumber,
	)

	releaseJson, _ := json.MarshalIndent(release, "", "\t")
	log.Printf("populated release with:%v", string(releaseJson))

	return release, nil
}

func (release *Release) Branch() string {
	return release.branch
}

func (release *Release) Number() string {
	return release.number
}

func (release *Release) Environment() string {
	return release.environment
}

func checkInput(inputBranch, inputEnvironment string) error {
	if len(inputBranch) == 0 {
		return errors.New("inputBranch cannot be an empty string")
	}
	if len(inputEnvironment) == 0 {
		return errors.New("inputEnvironment cannot be an empty string")
	}
	return nil
}

// formatEKSBranchNumber returns eks-<branch>-<number> (e.g. eks-1-20-2)
func formatEKSBranchNumber(branch, number string) string {
	return fmt.Sprintf("eks-%s-%s", branch, number)
}

// formatBranchEKSNumber returns <branch>-eks-<number> (e.g. 1-20-eks-2)
func formatBranchEKSNumber(branch, number string) string {
	return fmt.Sprintf("%s-eks-%s", branch, number)
}
