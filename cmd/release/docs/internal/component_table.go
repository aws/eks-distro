package internal

import (
	. "../../internal"
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"regexp"
	"sort"
	"strings"
)

const (
	ecrBase                = "public.ecr.aws/eks-distro"
	tableRowStart          = "| "
	tableRowEnd            = " |"
	tableHeader            = tableRowStart + "Name | Version | URI" + tableRowEnd
	tableHeaderBodyDivider = "|------|---------|-----|"
)

var (
	assetsNotInReleaseManifest = []string{"go-runner", "kube-proxy-base"}
	linebreakString            = string(linebreak)
)

// GetComponentVersionsTable returns Markdown table of component versions for the release. Release manifest must exist.
func GetComponentVersionsTable(release *Release) (string, error) {
	resp, err := http.Get(release.ManifestURL)
	if err != nil {
		return "", fmt.Errorf("error getting release manifest: %v", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("error status code %v getting release manifest (expected 200)", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading response to release manifest call: %v", err)
	}

	uriSuffix := getURISuffix(release)

	// Assumes format for desired lines is "uri: <ecrBase>[...]", and everything from ecrBase to end should be captured.
	captureRegexForLine := regexp.MustCompile(fmt.Sprintf(`uri: (%s.*)`, ecrBase))
	foundMatches := captureRegexForLine.FindAllSubmatch(body, -1)

	// Assumes uri format is "<ecrBase>/[some_stuff]/<NAME>:v<VERSION>-<uriSuffix>", where NAME and VERSION are targeted.
	// Example: "public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.15-eks-1-20-2" -> NAME is "etcd" and VERSION is "3.4.15"
	captureRegexForName := regexp.MustCompile(`.*/(.*):v`)
	captureRegexForVersion := regexp.MustCompile(fmt.Sprintf(`:v(.*)-%s`, uriSuffix))

	var tableRows []string

	// Example uri value and what it creates from this:
	//		input uri from match:	public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.15-eks-1-20-2
	//		output table row:		| etcd | 3.4.15 | public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.15-eks-1-20-2 |
	for _, matchPair := range foundMatches {
		uri := matchPair[1]
		name := string(captureRegexForName.FindSubmatch(uri)[1])
		version := string(captureRegexForVersion.FindSubmatch(uri)[1])
		tableRows = append(tableRows, formatComponentRow(name, version, string(uri)))
	}

	assetsVersion, _ := GetKubernetesReleaseGitTag(release.Branch())
	for _, assetName := range assetsNotInReleaseManifest {
		uri := fmt.Sprintf("%s/kubernetes/%s:%s-%s", ecrBase, assetName, assetsVersion, uriSuffix)
		tableRows = append(tableRows, formatComponentRow(assetName, strings.TrimPrefix(assetsVersion, "v"), uri))
	}

	sort.Strings(tableRows)

	tableRows = append([]string{tableHeader, tableHeaderBodyDivider}, tableRows...)

	return strings.Join(tableRows, linebreakString), nil
}

// GetComponentVersionsTableWithSameComponentVersionsAsPrevRelease returns Markdown table of presumed component versions
// for the release.
// The previous patch release's component version table must exist in the expected file and in the expected table format.
// Returned table uses the same components and their versions as the previous patch release. The returned table is not
// checked for accuracy or compared with the release manifest. References to the EKS-D release number are updated.
func GetComponentVersionsTableWithSameComponentVersionsAsPrevRelease(release *Release) (string, error) {
	prevTable, err := getPreviousReleaseComponentTable(release)
	if err != nil {
		return "", fmt.Errorf("failed to get previous release component table: %v", err)
	}
	// The first two rows presumably are tableHeader and tableHeaderBodyDivider, so any table with less than 3 row is
	// considered invalid, as it either lacks tableHeader and/or tableHeaderBodyDivider or has no components
	if len(prevTable) < 3 {
		return "", fmt.Errorf("prev component table is invalid, as it is too short (length %d)", len(prevTable))
	}

	currTable := []string{string(prevTable[0]), string(prevTable[1])}

	prevRowSuffix := []byte(getURISuffixForPreviousRelease(release) + tableRowEnd)
	currRowSuffix := []byte(getURISuffix(release) + tableRowEnd)

	// The first two rows presumably are tableHeader and tableHeaderBodyDivider, so they are skipped.
	for _, prevRow := range prevTable[2:] {
		if !bytes.HasSuffix(prevRow, prevRowSuffix) {
			return "", fmt.Errorf("suffix %q not found in table row %q", prevRowSuffix, prevRow)
		}
		currTable = append(currTable, string(append(bytes.TrimSuffix(prevRow, prevRowSuffix), currRowSuffix...)))
	}

	return strings.Join(currTable, linebreakString), nil
}

func getURISuffix(release *Release) string {
	return release.EKSBranchNumber
}

func getURISuffixForPreviousRelease(release *Release) string {
	return release.EKSBranchPreviousNumber
}

func formatComponentRow(name, version, uri string) string {
	return fmt.Sprintf("%s%s | %s | %s%s", tableRowStart, name, version, uri, tableRowEnd)
}

func getPreviousReleaseComponentTable(release *Release) ([][]byte, error) {
	fileOutput, err := ioutil.ReadFile(GetPreviousReleaseIndexFilePath(release.Branch(), release.PreviousNumber()))
	if err != nil {
		return [][]byte{}, fmt.Errorf("error reading file with previous release component table: %v", err)
	}

	splitData := bytes.Split(fileOutput, linebreak)
	header, headerBodyDivider := []byte(tableHeader), []byte(tableHeaderBodyDivider)

	for i := 0; i < len(splitData)-1; i++ {
		if bytes.Equal(header, splitData[i]) && bytes.Equal(headerBodyDivider, splitData[i+1]) {
			lineStart := []byte(tableRowStart)
			// j starts at i + 2 because the first two rows presumably are tableHeader and tableHeaderBodyDivider
			for j := i + 2; j <= len(splitData); j++ {
				if j != len(splitData) && bytes.HasPrefix(splitData[j], lineStart) {
					continue
				}
				return splitData[i:j], nil
			}
		}

	}
	return [][]byte{}, errors.New("unable to find previous release component table in file")
}
