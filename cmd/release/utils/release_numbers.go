package utils

import (
	"io/ioutil"
	"path/filepath"
	"strconv"
	"strings"
)

var rootDirectory = GetGitRootDirectory()

type ReleaseNumber struct {
	current, previous, next, filePath string
}

func CreateReleaseNumber(branch string, environment ReleaseEnvironment) (ReleaseNumber, error) {
	releaseNumber := ReleaseNumber{
		filePath: formatEnvironmentReleasePath(branch, environment),
	}

	currentAsInt, err := getCurrentAsInt(releaseNumber.filePath)
	if err != nil {
		return ReleaseNumber{}, err
	}
	releaseNumber.current = strconv.Itoa(currentAsInt)
	releaseNumber.previous = strconv.Itoa(currentAsInt - 1)
	releaseNumber.next = strconv.Itoa(currentAsInt + 1)

	return releaseNumber, nil
}

func (rn *ReleaseNumber) Current() string {
	return rn.current
}

func (rn *ReleaseNumber) Previous() string {
	return rn.previous
}

func (rn *ReleaseNumber) Next() string {
	return rn.next
}

func (rn *ReleaseNumber) FilePath() string {
	return rn.filePath
}

func getCurrentAsInt(numberFilePath string) (int, error) {
	fileOutput, err := ioutil.ReadFile(numberFilePath)
	if err != nil {
		return -1, err
	}
	currFileNumber := strings.TrimSpace(string(fileOutput))

	currFileNumberAsInt, err := strconv.Atoi(currFileNumber)
	if err != nil {
		return -1, err
	}
	return currFileNumberAsInt, nil
}

func formatEnvironmentReleasePath(branch string, environment ReleaseEnvironment) string {
	return filepath.Join(rootDirectory, "release", branch, environment.String(), "RELEASE")
}
