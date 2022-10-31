package existingdocs

import (
	"bytes"
	"fmt"
	"os"
	"time"

	"github.com/aws/eks-distro/cmd/release/utils/release"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

var linebreak = []byte("\n")

// UpdateDocsIndex updates the doc's directory index.md file for the current release.
func UpdateDocsIndex(r *release.Release, docsIndexPath string) error {
	data, err := os.ReadFile(docsIndexPath)
	if err != nil {
		return fmt.Errorf("reading doc index file: %w", err)
	}

	splitData := bytes.Split(data, linebreak)
	currLineNumber := 0

	// Update 'RELEASE=<number>' if branch is default branch
	isDefaultBranch, err := values.IsDefaultReleaseBranch(r.Branch())
	if err != nil {
		return err
	}
	if isDefaultBranch {
		hasFoundLine := false
		linePrefix := []byte("RELEASE=")
		expectedPreviousLine := []byte("RELEASE_BRANCH=" + r.Branch())
		for i := 1; i < len(splitData); i++ {
			if bytes.HasPrefix(splitData[i], linePrefix) && bytes.Equal(splitData[i-1], expectedPreviousLine) {
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
		if bytes.Equal(sectionHeader, splitData[j]) {
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
	return time.Now().Format("January 02, 2006")
}
