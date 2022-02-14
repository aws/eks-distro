package templates

const ChangeLogGenericBase = `# Changelog for {{.VBranchEKSNumber}}

This changelog highlights the changes for [{{.VBranchEKSNumber}}](https://github.com/aws/eks-distro/tree/{{.VBranchEKSNumber}}).

## Changes

`

const ChangeLogForOnlyBaseImage = ChangeLogGenericBase + `Security updates to Amazon Linux 2.
`
