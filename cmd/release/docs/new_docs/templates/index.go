package templates

// Template for index.md in docs directory
const IndexInBranch = `# EKS-D {{.VBranchEKSNumber}} Release

For additional information, see the [changelog](CHANGELOG-{{.VBranchEKSNumber}}.md) for this release.

## Release Manifest
Download the release manifest here: [{{.K8sBranchEKSNumber}}.yaml]({{.ManifestURL}})
`
