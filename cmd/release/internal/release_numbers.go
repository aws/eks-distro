package internal

import (
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

func determinePreviousReleaseNumber(release *Release) (string, error) {
	if len(release.previousNumber) > 0 {
		log.Printf("previous release number %q already known and is not re-sought\n", release.previousNumber)
		return release.previousNumber, nil
	}
	// TODO: resolve case where update number could be for both environments
	environmentReleasePath := formatEnvironmentReleasePath(release.branch, release.environment)
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

	prevNumber := release.previousNumber
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

func convertToNumberAndPrevNumber(overrideNumber int) (num, prevNum string) {
	return strconv.Itoa(overrideNumber), strconv.Itoa(overrideNumber -1)
}
