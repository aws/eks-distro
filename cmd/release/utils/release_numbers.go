package utils

import (
	"io/ioutil"
	"path/filepath"
	"strconv"
	"strings"
)

var rootDirectory = GetGitRootDirectory()

type ReleaseNumber struct {
	number, prevNumber, filePath string
}

func CreateReleaseNumber(branch string, environment ReleaseEnvironment) (ReleaseNumber, error) {
	releaseNumber := ReleaseNumber{
		filePath: formatEnvironmentReleasePath(branch, environment),
	}

	number, previousNumber, err := getNumberAndPreviousNumber(releaseNumber.filePath)
	if err != nil {
		return ReleaseNumber{}, err
	}
	releaseNumber.number, releaseNumber.prevNumber = number, previousNumber

	return releaseNumber, nil
}

func (rn *ReleaseNumber) Number() string {
	return rn.number
}

func (rn *ReleaseNumber) PrevNumber() string {
	return rn.prevNumber
}

func (rn *ReleaseNumber) FilePath() string {
	return rn.filePath
}

func getNumberAndPreviousNumber(numberFilePath string) (string, string, error) {
	fileOutput, err := ioutil.ReadFile(numberFilePath)
	if err != nil {
		return "", "", err
	}
	currFileNumber := strings.TrimSpace(string(fileOutput))

	currFileNumberAsInt, err := strconv.Atoi(currFileNumber)
	if err != nil {
		return "", "", err
	}
	return strconv.Itoa(currFileNumberAsInt + 1), currFileNumber, nil
}

func formatEnvironmentReleasePath(branch string, environment ReleaseEnvironment) string {
	return filepath.Join(rootDirectory, "release", branch, environment.String(), "RELEASE")
}
