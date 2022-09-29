package utils

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"sort"
	"strings"
)

const ecrBase = "public.ecr.aws/eks-distro"

type component struct {
	name, version, uri []byte
}

func GetComponentsFromReleaseManifest(releaseManifestURL string) (string, error) {
	resp, err := http.Get(releaseManifestURL)
	if err != nil {
		return "", fmt.Errorf("error getting release manifest: %v", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("error status code %v getting release manifest (expected 200)", resp.StatusCode)
	}

	re := regexp.MustCompile(fmt.Sprintf(`uri: (%s.*)`, ecrBase))
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading release manifest: %v", err)
	}
	foundMatches := re.FindAllSubmatch(body, -1)

	var components []component
	//	Example uri value and what it creates from this:
	//	uri: public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-5
	captureRegex := regexp.MustCompile(`[^/]+:v[0-9.]+`)
	for _, matchPair := range foundMatches {
		uri := matchPair[1]
		nameAndVersion := bytes.Split(captureRegex.Find(uri), []byte(":"))
		components = append(components, component{
			name:    nameAndVersion[0],
			version: nameAndVersion[1],
			uri:     uri,
		})
	}

	uriEndingAndReleaseBranchRegexp := regexp.MustCompile(`-eks-(.*)-[0-9]+$`) // ["-eks-1-23-444" "1-23"]
	uriEndingAndReleaseBranch := uriEndingAndReleaseBranchRegexp.FindSubmatch(components[0].uri)
	uriEnding, releaseBranch := uriEndingAndReleaseBranch[0], uriEndingAndReleaseBranch[1]

	assetsNotInReleaseManifest := [][]byte{[]byte("go-runner"), []byte("kube-proxy-base")}
	kubernetesReleaseGitTag, err := GetGitTag("kubernetes", "release", string(releaseBranch))
	if err != nil {
		return "", err
	}
	for _, asset := range assetsNotInReleaseManifest {
		components = append(components, component{
			name:    asset,
			version: kubernetesReleaseGitTag,
			uri:     []byte(fmt.Sprintf("%s/kubernetes/%s:%s%s", ecrBase, asset, kubernetesReleaseGitTag, uriEnding)),
		})
	}

	var tableRows []string
	for _, c := range components {
		tableRows = append(tableRows, fmt.Sprintf("| %s | %s | %s |", c.name, c.version, c.uri))
	}
	sort.Strings(tableRows)
	tableRows = append([]string{"| Name | Version | URI |", "|------|---------|-----|"}, tableRows...)
	return strings.Join(tableRows, "\n"), nil
}
