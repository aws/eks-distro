package newdocs

import (
	"bytes"
	"fmt"
	"strconv"

	"github.com/aws/eks-distro/cmd/release/utils/values"
)

type NewDocInput struct {
	FileName       string
	TemplateWriter bytes.Buffer
	AppendToEnd    func() (string, error)
}

type releaseInfo interface {
	Tag() string
	ManifestURL() string
	KubernetesMinorVersion() string
	Number() string
}

func CreateNewDocsInput(ri releaseInfo, hasAnnouncement bool) ([]NewDocInput, error) {
	changeLogWriter, err := getTemplateWriter(ri, changelogTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for changelog: %w", err)
	}

	indexWriter, err := getTemplateWriter(ri, indexTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for index: %w", err)
	}

	newDocInput := []NewDocInput{
		{
			FileName:       values.GetChangelogFileName(ri),
			TemplateWriter: changeLogWriter,
			AppendToEnd:    getPrInfoForChangelogFunc(ri),
		},
		{
			FileName:       values.IndexFileName,
			TemplateWriter: indexWriter,
			AppendToEnd:    getComponentsFromReleaseManifestFunc(ri),
		},
	}

	if hasAnnouncement {
		releaseAnnouncementWriter, err := getTemplateWriter(ri, releaseAnnouncementTemplateInput)
		if err != nil {
			return []NewDocInput{}, fmt.Errorf("getting template writer for release announcement: %w", err)
		}
		newDocInput = append(newDocInput, NewDocInput{
			FileName:       values.ReleaseAnnouncementFileName,
			TemplateWriter: releaseAnnouncementWriter,
			AppendToEnd:    nil,
		})
	}

	return newDocInput, nil
}

var getComponentsFromReleaseManifestFunc = func(ri releaseInfo) func() (string, error) {
	manifestURL := ri.ManifestURL()
	return func() (string, error) {
		return values.GetComponentsFromReleaseManifest(manifestURL)
	}
}

var getPrInfoForChangelogFunc = func(ri releaseInfo) func() (string, error) {
	releaseVersion := "v" + ri.KubernetesMinorVersion()
	return func() (string, error) {
		riNum, err := strconv.Atoi(ri.Number())
		if err != nil {
			return "", fmt.Errorf("converting release number %v: %w", ri.Number(), err)
		}
		return values.GetChangelogPRs(releaseVersion, riNum)
	}
}
