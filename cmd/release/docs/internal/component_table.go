package internal

import (
	. "../../internal"
	"sort"

	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
)

const (
	ecrBase = "public.ecr.aws/eks-distro"
)

var (
	assetsNotInReleaseManifest = []string{"go-runner", "kube-proxy-base"}
)

// GetComponentVersionsTable returns Markdown table of component versions for the release. Release manifest must exist.
// TODO: ensure no race conditions
func GetComponentVersionsTable(release *Release) (string, error) {
	resp, err := http.Get(release.ManifestURL)
	if err != nil {
		return "", fmt.Errorf("error getting release manifest: %v", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading response to release manifest call: %v", err)
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
		name := captureRegexForName.FindSubmatch(uri)[1]
		version := captureRegexForVersion.FindSubmatch(uri)[1]

		tableRow := fmt.Sprintf("| %s | %s | %s |", name, version, uri)
		tableRows = append(tableRows, tableRow)
	}

	otherAssetsVersion, _ := GetKubernetesReleaseGitTag()
	for _, asset := range assetsNotInReleaseManifest {
		uri := fmt.Sprintf("%s/kubernetes/%s:%s-%s", ecrBase, asset, otherAssetsVersion, release.EKSBranchNumber)
		tableRow := fmt.Sprintf("| %s | %s | %s |", asset, otherAssetsVersion[1:], uri) // [1:] removes 'v'

		tableRows = append(tableRows, tableRow)
	}

	sort.Strings(tableRows)

	tableRows = append([]string{"| Name | Version | URI |", "|------|---------|-----|"}, tableRows...)

	return strings.Join(tableRows, "\n"), nil
}
