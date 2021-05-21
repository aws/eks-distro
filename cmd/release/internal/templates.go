package internal

const changeLogBase = `# Changelog for {{.ReleaseTag}}

This changelog highlights the changes for [{{.ReleaseTag}}](https://github.com/aws/eks-distro/tree/{{.ReleaseTag}}).

`

const ChangeLogBaseImage = changeLogBase + `## Changes
Security updates to Amazon Linux 2.
`
