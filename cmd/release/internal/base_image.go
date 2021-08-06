package internal

import (
	"io/ioutil"
	"strings"
)

func GetBaseImageTag() (string, error) {
	fileOutput, err := ioutil.ReadFile(baseImagePath)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(fileOutput)), nil
}
