package existingdocs

import (
	"bytes"
	"fmt"
	"os"

	"github.com/aws/eks-distro/cmd/release/utils"
)

// UpdateREADME updates the README to replace release manifest from previous patch release with the new one.
func UpdateREADME(release *utils.Release, readmePath string) error {
	data, err := os.ReadFile(readmePath)
	if err != nil {
		return fmt.Errorf("reading README: %w", err)
	}

	//	Example:
	//	### Kubernetes 1-23
	//
	//	| Release | Manifest |
	//	| --- | --- |
	//	| 4 | [1-23-eks-4](https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-4.yaml) | <- line to change
	expectedLine := []byte("### Kubernetes " + release.Branch())
	lineToUpdate := []byte(fmt.Sprintf("| %s | [%s](%s) |", release.Number(), release.Tag(), release.ManifestURL()))
	numberOfLinesBetweenExpectedLineAndLineToUpdate := 4

	splitData := bytes.Split(data, linebreak)
	for i := 0; i < len(splitData)-numberOfLinesBetweenExpectedLineAndLineToUpdate; i++ {
		if bytes.Equal(expectedLine, splitData[i]) {
			splitData[i+numberOfLinesBetweenExpectedLineAndLineToUpdate] = lineToUpdate
			return os.WriteFile(readmePath, bytes.Join(splitData, linebreak), 0644)
		}
	}
	return fmt.Errorf("finding line (%q) needed to update version tag in %s", expectedLine, readmePath)
}
