package internal

import (
	. "../../internal"
	"bytes"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"time"
)

var (
	linebreak = []byte("\n")
)

// UpdateREADME updates the README to replace release manifest from previous patch release with the new one.
// If the value of provided 'force' is 'true', does not check for sequential numbering; otherwise, returns error if
// updating the doc would result in non-sequential number.
func UpdateREADME(release *Release, force bool) (DocStatus, error) {
	ds := GetEmptyDocStatus()

	readmePath := GetREADMEPath()
	data, err := ioutil.ReadFile(readmePath)
	if err != nil {
		return ds, fmt.Errorf("failed to read file because error: %v", err)
	}

	splitData := bytes.Split(data, linebreak)

	prefix := []byte("|")
	var lineIdentifier *regexp.Regexp
	if force {
		lineIdentifier = regexp.MustCompile(`\[` + release.K8sBranchEKS)
	} else {
		lineIdentifier = regexp.MustCompile(fmt.Sprintf(`\[%s\]`, release.K8sBranchEKSPreviousNumber))
	}
	hasFoundLine := false

	for i, line := range splitData {
		if !bytes.HasPrefix(line, prefix) || !lineIdentifier.Match(line) {
			continue
		}
		hasFoundLine = true
		newLine := fmt.Sprintf(
			"%s %s | [%s](%s) |",
			prefix,
			release.Number(),
			release.K8sBranchEKSNumber,
			release.ManifestURL,
		)
		splitData[i] = []byte(newLine)
		break
	}

	if !hasFoundLine {
		return ds, errors.New("failed to find line needed to update version tag in README")
	}

	ds = DocStatus{path: readmePath, isAlreadyExisting: true}
	return ds, os.WriteFile(readmePath, bytes.Join(splitData, linebreak), 0644)
}

// UpdateDocsIndex updates the doc's directory index.md file for the current release.
// If the value of provided 'force' is 'true', does not check for sequential numbering; otherwise, returns error if
// updating the doc would result in non-sequential number.
func UpdateDocsIndex(release *Release, force bool) (DocStatus, error) {
	ds := GetEmptyDocStatus()

	docsIndexPath := GetDocsIndexPath()
	data, err := ioutil.ReadFile(docsIndexPath)
	if err != nil {
		return ds, fmt.Errorf("failed to read file because error: %v", err)
	}

	splitData := bytes.Split(data, linebreak)

	// Iff branch matches "RELEASE_BRANCH=<branch>", updates number in 'RELEASE=<number>'. Enforces sequential numbering
	// unless provided 'force' is 'true'.
	lineBefore := []byte("RELEASE_BRANCH=" + release.Branch())
	lineToUpdatePrefix := []byte("RELEASE=")
	lineToUpdate := append(lineToUpdatePrefix, []byte(release.PreviousNumber())...)
	for i := 0; i < len(splitData)-1; i++ {
		if bytes.Compare(lineBefore, splitData[i]) != 0 || !bytes.HasPrefix(splitData[i+1], lineToUpdatePrefix) {
			continue
		}
		if bytes.Compare(lineToUpdate, splitData[i+1]) != 0 && !force {
			return ds, fmt.Errorf("expected line %q but found %q", lineToUpdate, splitData[i+1])
		}
		splitData[i+1] = []byte("RELEASE=" + release.Number())
	}

	// Adds link to index.md for the new release in the section for its release branch. Enforces sequential numbering
	// unless provided 'force' is 'true'.
	sectionHeader := []byte(fmt.Sprintf("#### EKS-D %s Version Dependencies", release.BranchWithDot))
	nextLineMatch := regexp.MustCompile(fmt.Sprintf(`\[%s\]`, release.VBranchEKSPreviousNumber))
	for i := 0; i < len(splitData)-1; i++ {
		if bytes.Compare(sectionHeader, splitData[i]) == 0 {
			if !nextLineMatch.Match(splitData[i+1]) && !force {
				return ds, errors.New("non-sequential Version Dependencies list")
			}
			appendLine := fmt.Sprintf(
				`* [%s](%s/index.md) (%s)`,
				release.VBranchEKSNumber,
				FormatRelativeReleaseDocsDirectory(release.Branch(), release.Number()),
				getDate(),
			)
			splitData[i] = append(append(splitData[i], linebreak...), appendLine...)
			break
		}
	}

	ds = DocStatus{path: docsIndexPath, isAlreadyExisting: true}
	return ds, os.WriteFile(docsIndexPath, bytes.Join(splitData, linebreak), 0644)
}

func getDate() string {
	currentTime := time.Now()
	return fmt.Sprintf("%s %d, %d", currentTime.Month(), currentTime.Day(), currentTime.Year())
}
