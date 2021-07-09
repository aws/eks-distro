package internal

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"strings"
)

const (
	defaultEnvironment = Production
	minNumber          = 1
)

type Release struct {
	branch         string
	number         string
	previousNumber string

	environment    ReleaseEnvironment

	// File paths, which are not guaranteed to be valid or existing
	KubeGitVersionFilePath string
	DocsDirectoryPath      string
	ProductionReleasePath  string
	DevelopmentReleasePath string

	// Version notations
	BranchEKSNumber            string // e.g. 1-20-eks-2
	BranchEKSPreviousNumber    string // e.g. 1-20-eks-1
	BranchWithDot              string // e.g. 1.20
	BranchWithDotNumber        string // e.g. 1.20-2
	EKSBranchNumber            string // e.g. eks-1-20-2
	EKSBranchPreviousNumber    string // e.g. eks-1-20-1
	K8sBranchEKS               string // e.g. Kubernetes-1-20-eks
	K8sBranchEKSNumber         string // e.g. Kubernetes-1-20-eks-2
	K8sBranchEKSPreviousNumber string // e.g. Kubernetes-1-20-eks-1
	VBranchEKSNumber           string // e.g. v1-20-eks-2
	VBranchEKSPreviousNumber   string // e.g. v1-20-eks-1
	VBranchWithDotNumber       string // e.g. v1.20-2

	// URL for release manifest, which is not guaranteed to be valid or existing
	// e.g. https://distro.eks.amazonaws.com/kubernetes-1-20/kubernetes-1-20-eks-2.yaml
	ManifestURL         string
	PreviousManifestURL string
}

// NewReleaseWithOverrideNumber returns complete Release based on the provided inputBranch and overrideNumber.
// The use of overrideNumber should be done with caution. Disrupting the conventional process can result in
// unintentional and unexpected consequences. There is no check to ensure this Release is valid with overrideNumber.
func NewReleaseWithOverrideNumber(inputBranch string, overrideNumber int) (Release, error) {
	if overrideNumber < minNumber {
		return Release{}, fmt.Errorf("override number %d cannot be less than %d", overrideNumber, minNumber)
	}
	return newRelease(inputBranch, defaultEnvironment, &overrideNumber)
}

// NewReleaseWithOverrideEnvironment returns complete Release based on the provided input.
func NewReleaseWithOverrideEnvironment(inputBranch string, inputEnvironment ReleaseEnvironment) (Release, error) {
	return newRelease(inputBranch, inputEnvironment, nil)
}

// NewRelease returns complete Release based on the provided inputBranch
func NewRelease(inputBranch string) (Release, error) {
	return NewReleaseWithOverrideEnvironment(inputBranch, defaultEnvironment)
}

func newRelease(inputBranch string, inputEnvironment ReleaseEnvironment, overrideNumber *int) (Release, error) {
	inputBranch = strings.TrimSpace(inputBranch)
	if len(inputBranch) == 0 {
		return Release{}, errors.New("branch cannot be an empty string")
	}
	var err error

	release := Release{
		branch:      inputBranch,
		environment: inputEnvironment,
	}

	release.KubeGitVersionFilePath = FormatKubeGitVersionFilePath(&release)

	if overrideNumber != nil {
		release.number, release.previousNumber = convertToNumberAndPrevNumber(*overrideNumber)
	} else {
		release.previousNumber, err = determinePreviousReleaseNumber(&release)
		if err != nil {
			return Release{}, fmt.Errorf("error determining previous number: %v", err)
		}
		release.number, err = determineReleaseNumber(&release)
		if err != nil {
			return Release{}, fmt.Errorf("error determining number: %v", err)
		}
	}

	release.DocsDirectoryPath = formatReleaseDocsDirectory(release.branch, release.number)
	release.ProductionReleasePath = formatEnvironmentReleasePath(release.branch, Production)
	release.DevelopmentReleasePath = formatEnvironmentReleasePath(release.branch, Development)

	branchEKS := release.branch + "-eks"
	release.BranchEKSNumber = fmt.Sprintf("%s-%s", branchEKS, release.number)
	release.BranchEKSPreviousNumber = fmt.Sprintf("%s-%s", branchEKS, release.previousNumber)
	release.BranchWithDot = strings.Replace(release.branch, "-", ".", 1)
	release.BranchWithDotNumber = fmt.Sprintf("%s-%s", release.BranchWithDot, release.number)
	release.EKSBranchNumber = fmt.Sprintf("eks-%s-%s", release.branch, release.number)
	release.EKSBranchPreviousNumber = fmt.Sprintf("eks-%s-%s", release.branch, release.previousNumber)
	release.K8sBranchEKS = "kubernetes-" + branchEKS
	release.K8sBranchEKSNumber = fmt.Sprintf("%s-%s", release.K8sBranchEKS, release.number)
	release.K8sBranchEKSPreviousNumber = fmt.Sprintf("%s-%s", release.K8sBranchEKS, release.previousNumber)
	release.VBranchEKSNumber = "v" + release.BranchEKSNumber
	release.VBranchEKSPreviousNumber = "v" + release.BranchEKSPreviousNumber
	release.VBranchWithDotNumber = "v" + release.BranchWithDotNumber

	release.ManifestURL = formatReleaseManifestURL(release.branch, release.BranchEKSNumber)
	release.PreviousManifestURL = formatReleaseManifestURL(release.branch, release.BranchEKSPreviousNumber)

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

func (release *Release) PreviousNumber() string {
	return release.previousNumber
}

func (release *Release) Version() string {
	return release.BranchWithDotNumber
}

func formatReleaseManifestURL(branch, branchEKSNumber string) string {
	return fmt.Sprintf(
		"https://distro.eks.amazonaws.com/kubernetes-%s/kubernetes-%s.yaml",
		branch,
		branchEKSNumber)
}
