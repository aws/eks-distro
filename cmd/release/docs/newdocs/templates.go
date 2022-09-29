package newdocs

import (
	"bytes"
	"path/filepath"
	"text/template"

	"github.com/aws/eks-distro/cmd/release/utils/values"
)

// RELEASE ANNOUNCEMENT
var releaseAnnouncementTemplateInput = templateInput{
	templateName: "releaseAnnouncementTemplate",
	funcMap:      template.FuncMap{},
	docTemplate: `Amazon EKS Distro {{.Tag}} is now available. Builds are available through ECR Public Gallery (https://gallery.ecr.aws/eks-distro). The changelog and release manifest are available on GitHub (https://github.com/aws/eks-distro/releases).
	`,
}

// CHANGELOG
var changelogTemplateInput = templateInput{
	templateName: "changelogTemplate",
	funcMap:      template.FuncMap{},
	docTemplate: `# Changelog for {{.Tag}}

This changelog highlights the changes for [{{.Tag}}](https://github.com/aws/eks-distro/tree/{{.Tag}}).

## Changes

`,
}

// INDEX
var indexTemplateInput = templateInput{
	templateName: "indexTemplate",
	funcMap: template.FuncMap{
		"changelogFileNameFunc": func(ri releaseInfo) string {
			return values.GetChangelogFileName(ri)
		},
		"filepathBaseFunc": func(manifestURL string) string {
			return filepath.Base(manifestURL)
		},
	},
	docTemplate: `# EKS-D {{.Tag}} Release

For additional information, see the [changelog]({{changelogFileNameFunc .}}) for this release.

## Release Manifest

Download the release manifest here: [{{filepathBaseFunc .ManifestURL}}]({{.ManifestURL}})

`,
}

type templateInput struct {
	docTemplate  string
	templateName string
	funcMap      template.FuncMap
}

var getTemplateWriter = func(ri releaseInfo, input templateInput) (bytes.Buffer, error) {
	t := template.Must(template.New(input.templateName).Funcs(input.funcMap).Parse(input.docTemplate))
	out := bytes.Buffer{}
	err := t.Execute(&out, ri)
	return out, err
}
