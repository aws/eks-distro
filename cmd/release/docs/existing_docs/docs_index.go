package existing_docs

import (
	"bytes"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/aws/eks-distro/cmd/release/utils"
)

var linebreak = []byte("\n")

// UpdateDocsIndex updates the doc's directory index.md file for the current release.
func UpdateDocsIndex(r utils.Release, docsIndexPath string) error {
	data, err := os.ReadFile(docsIndexPath)
	if err != nil {
		return fmt.Errorf("reading doc index file: %v", err)
	}

	splitData := bytes.Split(data, linebreak)
	currLineNumber := 0

	// Update 'RELEASE=<number>' if branch is default branch
	isDefaultBranch, err := isDefaultReleaseBranch(r.Branch())
	if err != nil {
		return err
	}
	if isDefaultBranch {
		hasFoundLine := false
		linePrefix := []byte("RELEASE=")
		expectedPreviousLine := []byte("RELEASE_BRANCH=" + r.Branch())
		for i := 1; i < len(splitData); i++ {
			if bytes.HasPrefix(splitData[i], linePrefix) && bytes.Compare(splitData[i-1], expectedPreviousLine) == 0 {
				hasFoundLine = true
				currLineNumber = i
				break
			}
		}
		if !hasFoundLine {
			return fmt.Errorf("updating index file because did not find line %q", expectedPreviousLine)
		}
		splitData[currLineNumber] = append(linePrefix, []byte(r.Number())...)
	}

	// Adds a link to index.md for the new release in the section for its release branch.
	hasFoundSection := false
	sectionHeader := []byte(fmt.Sprintf("#### EKS-D %s Version Dependencies", r.KubernetesMinorVersion()))
	for j := currLineNumber; j < len(splitData)-1; j++ {
		if bytes.Compare(sectionHeader, splitData[j]) == 0 {
			currLineNumber = j
			hasFoundSection = true
			break
		}
	}
	if !hasFoundSection {
		return fmt.Errorf("updating index file because did not find section for Version Dependencies")
	}
	newLine := fmt.Sprintf(`* [%s](releases/%s/%s/index.md) (%s)`, r.Tag(), r.Branch(), r.Number(), getDate())
	splitData[currLineNumber] = append(append(splitData[currLineNumber], linebreak...), newLine...)

	return os.WriteFile(docsIndexPath, bytes.Join(splitData, linebreak), 0644)
}

func getDate() string {
	currentTime := time.Now()
	return fmt.Sprintf("%s %d, %d", currentTime.Month(), currentTime.Day(), currentTime.Year())
}

func isDefaultReleaseBranch(providedBranch string) (bool, error) {
	defaultReleaseBranch, err := utils.GetDefaultReleaseBranch()
	if err != nil {
		return false, err
	}
	return strings.Compare(providedBranch, defaultReleaseBranch) == 0, nil
}
