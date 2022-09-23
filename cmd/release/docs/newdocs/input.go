package newdocs

import (
	"bytes"
	"fmt"

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
}

func CreateNewDocsInput(ri releaseInfo) ([]NewDocInput, error) {
	changeLogWriter, err := getTemplateWriter(ri, changelogTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for changelog: %w", err)
	}

	indexWriter, err := getTemplateWriter(ri, indexTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for index: %w", err)
	}

	releaseAnnouncementWriter, err := getTemplateWriter(ri, releaseAnnouncementTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for release announcement: %w", err)
	}

	return []NewDocInput{
		{
			FileName:       values.GetChangelogFileName(ri),
			TemplateWriter: changeLogWriter,
			AppendToEnd:    nil,
		},
		{
			FileName:       values.IndexFileName,
			TemplateWriter: indexWriter,
			AppendToEnd:    getComponentsFromReleaseManifestFunc(ri),
		},
		{
			FileName:       values.ReleaseAnnouncementFileName,
			TemplateWriter: releaseAnnouncementWriter,
			AppendToEnd:    nil,
		},
	}, nil
}

var getComponentsFromReleaseManifestFunc = func(ri releaseInfo) func() (string, error) {
	manifestURL := ri.ManifestURL()
	return func() (string, error) {
		return values.GetComponentsFromReleaseManifest(manifestURL)
	}
}
