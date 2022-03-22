package internal

import (
	. "../../utils"
	"errors"
	"fmt"
	"strconv"
	"strings"
)

const (
	Environment = Production
	minNumber   = 1
)

type Release struct {
	branch         string
	number         string
	previousNumber string

	// File paths, which are not guaranteed to be valid or existing
	DocsDirectoryPath string

	// Version notations
	BranchWithDot              string // e.g. 1.20
	EKSBranchNumber            string // e.g. eks-1-20-2
	EKSBranchPreviousNumber    string // e.g. eks-1-20-1
	K8sBranchEKS               string // e.g. Kubernetes-1-20-eks
	K8sBranchEKSNumber         string // e.g. Kubernetes-1-20-eks-2
	K8sBranchEKSPreviousNumber string // e.g. Kubernetes-1-20-eks-1
	VBranchEKSNumber           string // e.g. v1-20-eks-2
	VBranchEKSPreviousNumber   string // e.g. v1-20-eks-1
	VBranchWithDotNumber       string // e.g. v1.20-2

	branchEKSNumber            string // e.g. 1-20-eks-2
	branchEKSPreviousNumber    string // e.g. 1-20-eks-1
	branchWithDotNumber        string // e.g. 1.20-2

	// URL for release manifest, which is not guaranteed to be valid or existing.
	// Example: https://distro.eks.amazonaws.com/kubernetes-1-20/kubernetes-1-20-eks-2.yaml
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
	return newRelease(inputBranch, strconv.Itoa(overrideNumber), strconv.Itoa(overrideNumber-1))
}

// NewRelease returns complete Release based on the provided inputBranch
func NewRelease(inputBranch string, isLocalReleaseNumberForNewRelease bool) (Release, error) {
	rn, err := CreateReleaseNumber(inputBranch, Environment)
	if err != nil {
		return Release{}, fmt.Errorf("error determining number: %v", err)
	}

	if isLocalReleaseNumberForNewRelease {
		return newRelease(inputBranch, rn.Current(), rn.Previous())
	} else {
		return newRelease(inputBranch, rn.Next(), rn.Current())
	}
}

func newRelease(inputBranch string, num, prevNum string) (Release, error) {
	inputBranch = strings.TrimSpace(inputBranch)
	if len(inputBranch) == 0 {
		return Release{}, errors.New("branch cannot be an empty string")
	}

	release := Release{
		branch:         inputBranch,
		number:         num,
		previousNumber: prevNum,
	}

	release.DocsDirectoryPath = formatReleaseDocsDirectory(release.branch, release.number)

	branchEKS := release.branch + "-eks"
	release.branchEKSNumber = fmt.Sprintf("%s-%s", branchEKS, release.number)
	release.branchEKSPreviousNumber = fmt.Sprintf("%s-%s", branchEKS, release.previousNumber)
	release.BranchWithDot = GetBranchWithDotFormat(release.branch)
	release.branchWithDotNumber = GetBranchWithDotAndNumberWithDashFormat(release.BranchWithDot, release.number)
	release.EKSBranchNumber = fmt.Sprintf("eks-%s-%s", release.branch, release.number)
	release.EKSBranchPreviousNumber = fmt.Sprintf("eks-%s-%s", release.branch, release.previousNumber)
	release.K8sBranchEKS = "kubernetes-" + branchEKS
	release.K8sBranchEKSNumber = fmt.Sprintf("%s-%s", release.K8sBranchEKS, release.number)
	release.K8sBranchEKSPreviousNumber = fmt.Sprintf("%s-%s", release.K8sBranchEKS, release.previousNumber)
	release.VBranchEKSNumber = "v" + release.branchEKSNumber
	release.VBranchEKSPreviousNumber = "v" + release.branchEKSPreviousNumber
	release.VBranchWithDotNumber = "v" + release.branchWithDotNumber

	release.ManifestURL = formatReleaseManifestURL(release.branch, release.branchEKSNumber)
	release.PreviousManifestURL = formatReleaseManifestURL(release.branch, release.branchEKSPreviousNumber)

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
	return release.branchWithDotNumber
}

func formatReleaseManifestURL(branch, branchEKSNumber string) string {
	return fmt.Sprintf(
		"https://distro.eks.amazonaws.com/kubernetes-%s/kubernetes-%s.yaml",
		branch,
		branchEKSNumber)
}
