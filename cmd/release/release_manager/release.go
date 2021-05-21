package release_manager

import (
	. "../internal"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

type Release struct {
	Branch      string
	Environment string
	Number      string
	prevNumber  string

	VersionTag         string // e.g. 'eks-1-20-2'
	PreviousVersionTag string

	ReleaseTag string // e.g. 'v1-20-eks-2'

	EnvironmentReleasePath string
}

// InitializeRelease returns complete Release based on the provided ReleaseInput
func InitializeRelease(input ReleaseInput) (*Release, error) {
	err := checkInput(input)
	if err != nil {
		return &Release{}, fmt.Errorf("invlid input for release: %v", err)
	}

	release := &Release{
		Branch:      input.GetBranch(),
		Environment: input.GetEnvironment(),
	}

	release.EnvironmentReleasePath = FormatEnvironmentReleasePath(release)

	release.prevNumber, err = determinePreviousReleaseNumber(release)
	if err != nil {
		return &Release{}, err
	}
	log.Printf("determined %q is the previous release number\n", release.prevNumber)

	release.Number, err = determineReleaseNumber(release)
	if err != nil {
		return &Release{}, err
	}
	log.Printf("determined %q is the release number\n", release.Number)

	release.VersionTag = GetVersionTag(release)
	release.PreviousVersionTag = GetVersionTag(&Release{Branch: release.GetBranch(), Number: release.prevNumber})

	release.ReleaseTag = GetReleaseTag(release)

	releaseJson, _ := json.MarshalIndent(release, "", "\t")
	log.Printf("populated release with:%v", string(releaseJson))

	return release, nil
}

func (release *Release) GetBranch() string {
	return release.Branch
}

func (release *Release) GetNumber() string {
	return release.Number
}

func (release *Release) GetEnvironment() string {
	return release.Environment
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
	if len(release.Number) > 0 {
		log.Printf("release number %q already known and is not re-sought\n", release.Number)
		return release.Number, nil
	}

	prevReleaseNumber := release.prevNumber
	if len(prevReleaseNumber) == 0 {
		prevReleaseNumber, err := determinePreviousReleaseNumber(release)
		if err != nil {
			return "", err
		}
		log.Printf("previous release number not provided to determime release number. It is assumed to be %q\n",
			prevReleaseNumber)
	}

	prevNumberAsInt, err := strconv.Atoi(prevReleaseNumber)
	if err != nil {
		return "", err
	}

	return strconv.Itoa(prevNumberAsInt + 1), nil
}
