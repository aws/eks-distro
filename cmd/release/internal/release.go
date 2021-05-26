package internal

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

type Release struct {
	Branch      string
	environment string
	number      string
	prevNumber  string

	// File paths, which are not guaranteed to be valid or existing
	EnvironmentReleasePath string
	KubeGitVersionFilePath string
	DocsDirectoryPath      string

	// Version notations
	EKS_Branch_Number         string // e.g. eks-1-20-2
	EKS_Branch_PreviousNumber string // e.g. eks-1-20-1
	V_Branch_EKS_Number       string // e.g. v1-20-eks-2
	Branch_EKS_Number         string // e.g. 1-20-eks-2
	V_BranchWithDot_Number    string // e.g. v1.20-2
}

// InitializeRelease returns complete Release based on the provided ReleaseInput
func InitializeRelease(input ReleaseInput) (*Release, error) {
	err := checkInput(input)
	if err != nil {
		return &Release{}, fmt.Errorf("invlid input for release: %v", err)
	}

	release := &Release{
		Branch:      input.GetBranch(),
		environment: input.GetEnvironment(),
	}

	release.EnvironmentReleasePath = FormatEnvironmentReleasePath(release)
	release.KubeGitVersionFilePath = FormatKubeGitVersionFilePath(release)

	release.prevNumber, err = determinePreviousReleaseNumber(release)
	if err != nil {
		return &Release{}, fmt.Errorf("error determining previous number: %v", err)
	}

	release.number, err = determineReleaseNumber(release)
	if err != nil {
		return &Release{}, fmt.Errorf("error determining number: %v", err)
	}

	release.DocsDirectoryPath = FormatReleaseDocsDirectory(release, release.number)

	release.EKS_Branch_Number = getEKSBranchNumber(release.Branch, release.number)
	release.EKS_Branch_PreviousNumber = getEKSBranchNumber(release.Branch, release.prevNumber)
	release.Branch_EKS_Number = fmt.Sprintf("%s-eks-%s", release.Branch, release.number)
	release.V_Branch_EKS_Number = "v" + release.Branch_EKS_Number
	release.V_BranchWithDot_Number =
		fmt.Sprintf("v%s-%s", strings.Replace(release.Branch, "-", ".", 1), release.number)

	releaseJson, _ := json.MarshalIndent(release, "", "\t")
	log.Printf("populated release with:%v", string(releaseJson))

	return release, nil
}

func (release *Release) GetBranch() string {
	if len(release.Branch) == 0 {
		log.Fatal("attempted to get release Branch, but value has not been set")
	}
	return release.Branch
}

func (release *Release) GetNumber() string {
	if len(release.number) == 0 {
		log.Fatal("attempted to get release number, but value has not been set")
	}
	return release.number
}

func (release *Release) GetEnvironment() string {
	if len(release.environment) == 0 {
		log.Fatal("attempted to get release environment, but value has not been set")
	}
	return release.environment
}

func checkInput(input ReleaseInput) error {
	if len(input.GetBranch()) == 0 {
		return fmt.Errorf("input.GetBranch() cannot be an empty string")
	}
	if len(input.GetEnvironment()) == 0 {
		return fmt.Errorf("input.GetEnvironment() cannot be an empty string")
	}
	return nil
}

func determinePreviousReleaseNumber(release *Release) (string, error) {
	if len(release.prevNumber) > 0 {
		log.Printf("previous release number %q already known and is not re-sought\n", release.prevNumber)
		return release.prevNumber, nil
	}

	environmentReleasePath := release.EnvironmentReleasePath
	if len(environmentReleasePath) == 0 {
		environmentReleasePath = FormatEnvironmentReleasePath(release)
	}

	fileOutput, err := ioutil.ReadFile(environmentReleasePath)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(fileOutput)), nil
}

func determineReleaseNumber(release *Release) (string, error) {
	if len(release.number) > 0 {
		log.Printf("release number %q already known and is not re-sought\n", release.number)
		return release.number, nil
	}

	prevNumber := release.prevNumber
	if len(prevNumber) == 0 {
		prevNumber, err := determinePreviousReleaseNumber(release)
		if err != nil {
			return "", err
		}
		log.Printf("previous number not provided to determime number. It is assumed to be %q\n", prevNumber)
	}

	prevNumberAsInt, err := strconv.Atoi(prevNumber)
	if err != nil {
		return "", err
	}
	return strconv.Itoa(prevNumberAsInt + 1), nil
}

// getEKSBranchNumber returns eks-<branch>-<patch version> (e.g. eks-1-20-2)
func getEKSBranchNumber(branch, number string) string {
	return fmt.Sprintf("eks-%s-%s", branch, number)
}
