package utils

import (
	"errors"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

// GetNumber returns the current number and the filepath to the local file used to determine that number.
func GetNumber(branch string, ct ChangesType) (num, numPath string, err error) {
	numPath, err = getReleaseNumberPath(branch, ct)
	if err != nil {
		return "", "", err
	}

	fileOutput, err := os.ReadFile(numPath)
	if err != nil {
		return "", "", err
	}
	return strings.TrimSpace(string(fileOutput)), numPath, nil
}

// GetNextNumber returns the next number and the filepath to the local file for the current number used to determine
// the next number.
func GetNextNumber(branch string, ct ChangesType) (nextNum, numPath string, err error) {
	currNum, numPath, err := GetNumber(branch, ct)
	if err != nil {
		return "", "", err
	}

	currNumAsInt, err := strconv.Atoi(currNum)
	if err != nil {
		return "", "", err
	}
	return strconv.Itoa(currNumAsInt + 1), numPath, nil
}

// getReleaseNumberPath returns path to file with release number for provided branch and ChangeType, which must be
// Dev or Prod. Example: /Users/lovelace/go/eks-distro/release/1-24/development/RELEASE
func getReleaseNumberPath(branch string, ct ChangesType) (string, error) {
	if !ct.IsDevOrProd() {
		return "", errors.New("change type must be dev or prod")
	}
	return filepath.Join(gitRootDirectory, "release", branch, ct.String(), "RELEASE"), nil
}
