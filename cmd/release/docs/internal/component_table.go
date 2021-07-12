package internal

import (
	. "../../internal"
	"bytes"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"sort"
	"strings"
)

const (
	ecrBase = "public.ecr.aws/eks-distro"
)

var (
	assetsNotInReleaseManifest = []string{"go-runner", "kube-proxy-base"}
)

type componentTableInput struct {
	releaseManifestURL          string
	branch                      string
	eksBranchNumber             []byte
	isConvertFromPreviousNumber bool
	eksBranchPreviousNumber     []byte
}

// GetComponentVersionsTable returns Markdown table of component versions for the release. Release manifest must exist.
func GetComponentVersionsTable(release *Release) (string, error) {
	input := componentTableInput{
		releaseManifestURL:          release.ManifestURL,
		branch:                      release.Branch(),
		eksBranchNumber:             []byte(release.EKSBranchNumber),
		isConvertFromPreviousNumber: false,
	}
	return getComponentVersionsTable(input)
}

// GetComponentVersionsTableIfNoReleaseManifest returns Markdown table of component versions for the release. Previous
// release manifest must exist.
func GetComponentVersionsTableIfNoReleaseManifest(release *Release) (string, error) {
	input := componentTableInput{
		releaseManifestURL:          release.PreviousManifestURL,
		branch:                      release.Branch(),
		eksBranchNumber:             []byte(release.EKSBranchNumber),
		isConvertFromPreviousNumber: true,
		eksBranchPreviousNumber:     []byte(release.EKSBranchPreviousNumber),
	}
	return getComponentVersionsTable(input)
}

func getComponentVersionsTable(input componentTableInput) (string, error) {
	resp, err := http.Get(input.releaseManifestURL)
	if err != nil {
		return "", fmt.Errorf("error getting release manifest: %v", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("error status code %v getting release manifest (expected 200)", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading release manifest: %v", err)
	}

	re := regexp.MustCompile(fmt.Sprintf(`uri: (%s.*)`, ecrBase))
	foundMatches := re.FindAllSubmatch(body, -1)

	// 	Assumes uri format is "public.ecr.aws/eks-distro/[some_stuff]/<NAME>:v<VERSION>-eks-[branch]-[number]",
	//	where NAME and VERSION are the values needed.
	captureRegexForName := regexp.MustCompile(`.*/(.*):v`)
	captureRegexForVersion := regexp.MustCompile(`:v(.*)-eks`)

	var tableRows []string

	//	Example uri value and what it creates from this:
	//		uri: public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-5
	//		output: | etcd | 3.4.14 | public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-5 |
	for _, matchPair := range foundMatches {
		uri := matchPair[1]
		if input.isConvertFromPreviousNumber {
			if !bytes.HasSuffix(uri, input.eksBranchPreviousNumber) {
				return "", fmt.Errorf("failed to find expected release number in uri %q", uri)
			}
			uri = append(bytes.TrimSuffix(uri, input.eksBranchPreviousNumber), input.eksBranchNumber...)
		}
		name := captureRegexForName.FindSubmatch(uri)[1]
		version := captureRegexForVersion.FindSubmatch(uri)[1]

		tableRow := fmt.Sprintf("| %s | %s | %s |", name, version, uri)
		tableRows = append(tableRows, tableRow)
	}

	otherAssetsVersion, _ := GetKubernetesReleaseGitTag(input.branch)
	for _, asset := range assetsNotInReleaseManifest {
		uri := fmt.Sprintf("%s/kubernetes/%s:%s-%s", ecrBase, asset, otherAssetsVersion, input.eksBranchNumber)
		tableRow := fmt.Sprintf("| %s | %s | %s |", asset, otherAssetsVersion[1:], uri) // [1:] removes 'v'

		tableRows = append(tableRows, tableRow)
	}

	sort.Strings(tableRows)

	tableRows = append([]string{"| Name | Version | URI |", "|------|---------|-----|"}, tableRows...)

	return strings.Join(tableRows, "\n"), nil
}
