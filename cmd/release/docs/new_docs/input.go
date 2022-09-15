package new_docs

import (
	"bytes"
	"fmt"

	"github.com/aws/eks-distro/cmd/release/utils"
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

func CreateNewDocsInfo(ri releaseInfo) ([]NewDocInput, error) {
	changeLogWriter, err := getTemplateWriter(ri, changelogTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for changelog: %v", err)
	}

	indexWriter, err := getTemplateWriter(ri, indexTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for index: %v", err)
	}

	releaseAnnouncementWriter, err := getTemplateWriter(ri, releaseAnnouncementTemplateInput)
	if err != nil {
		return []NewDocInput{}, fmt.Errorf("getting template writer for release announcement: %v", err)
	}

	return []NewDocInput{
		{
			FileName:       utils.GetChangelogFileName(ri),
			TemplateWriter: changeLogWriter,
			AppendToEnd:    nil,
		},
		{
			FileName:       "index.md",
			TemplateWriter: indexWriter,
			AppendToEnd:    getComponentsFromReleaseManifestFunc(ri),
		},
		{
			FileName:       "release-announcement.txt",
			TemplateWriter: releaseAnnouncementWriter,
			AppendToEnd:    nil,
		},
	}, nil
}

var getComponentsFromReleaseManifestFunc = func(ri releaseInfo) func() (string, error) {
	manifestURL := ri.ManifestURL()
	return func() (string, error) {
		return utils.GetComponentsFromReleaseManifest(manifestURL)
	}
}
