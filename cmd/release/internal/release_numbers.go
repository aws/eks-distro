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

func determineOverrideNumberAndPrevNumber(overrideNumber int) (num, prevNum string) {
	num = strconv.Itoa(overrideNumber)
	if overrideNumber <= 0 {
		log.Printf("Number overrode to be %q. Previous number cannot be negative, so it is left empty", num)
	} else {
		prevNum = strconv.Itoa(overrideNumber - 1)
		log.Printf("Number overrode to be %q, and previous number set to %q\n", num, prevNum)
	}
	return
}
