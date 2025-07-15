package values

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"sort"
	"strings"
)

const (
	ecrBase            = "public.ecr.aws/eks-distro"
	expectedStatusCode = 200
)

type component struct {
	name, version, uri []byte
}

func GetComponentsFromReleaseManifest(releaseManifestURL string) (string, error) {
	resp, err := http.Get(releaseManifestURL)
	if err != nil {
		return "", fmt.Errorf("getting release manifest: %w\n", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != expectedStatusCode {
		return "", fmt.Errorf("got status code %v when getting release manifest (expected %d)",
			resp.StatusCode, expectedStatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("reading release manifest: %w", err)
	}
	re := regexp.MustCompile(fmt.Sprintf(`uri: (%s.*)`, ecrBase))
	foundMatches := re.FindAllSubmatch(body, -1)

	var components []component
	//	Example uri value and what it creates from this:
	//	uri: public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-5
	captureRegex := regexp.MustCompile(`[^/]+:v[0-9.]+`)
	for _, matchPair := range foundMatches {
		uri := matchPair[1]
		nameAndVersion := bytes.Split(captureRegex.Find(uri), []byte(":"))
		// TODO: remove this after deprecating metrics server from the release yaml
		if strings.Contains(string(nameAndVersion[0]), "metrics-server") {
			continue
		}
		// TODO: remove this after deprecating CSI sidecar projects from the release yaml
		componentName := string(nameAndVersion[0])
		if strings.Contains(componentName, "external-attacher") ||
			strings.Contains(componentName, "external-provisioner") ||
			strings.Contains(componentName, "external-resizer") ||
			strings.Contains(componentName, "external-snapshotter") ||
			strings.Contains(componentName, "livenessprobe") ||
			strings.Contains(componentName, "node-driver-registrar") {
			continue
		}
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
		return "", fmt.Errorf("getting Kubernetes git tag for release manifest: %w", err)
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
