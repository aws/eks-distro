package existing_docs

import (
	"bytes"
	"errors"
	"fmt"
	. "github.com/aws/eks-distro/cmd/release/utils"
	"os"
)

// UpdateREADME updates the README to replace release manifest from previous patch release with the new one.
func UpdateREADME(release Release, readmePath string) error {
	data, err := os.ReadFile(readmePath)
	if err != nil {
		return fmt.Errorf("failed to read README because error: %v", err)
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
		if bytes.Compare(expectedLine, splitData[i]) == 0 {
			splitData[i+numberOfLinesBetweenExpectedLineAndLineToUpdate] = lineToUpdate
			return os.WriteFile(readmePath, bytes.Join(splitData, linebreak), 0644)
		}
	}
	return errors.New("failed to find line needed to update version tag in README")
}
