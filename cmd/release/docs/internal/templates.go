package internal

// Templates for CHANGELOG
const changeLogBase = `# Changelog for {{.VBranchEKSNumber}}

This changelog highlights the changes for [{{.VBranchEKSNumber}}](https://github.com/aws/eks-distro/tree/{{.VBranchEKSNumber}}).

`

const ChangeLogBaseImage = changeLogBase + `## Changes
Security updates to Amazon Linux 2.
`

// Template for index.md in docs directory
const IndexInBranch = `# EKS-D {{.VBranchEKSNumber}} Release

For additional information, see the [changelog](CHANGELOG-{{.VBranchEKSNumber}}.md) for this release.

## Release Manifest
Download the release manifest here: [{{.K8sBranchEKSNumber}}.yaml]({{.ManifestURL}})
`

// Template for release announcement
const ReleaseAnnouncement = `Amazon EKS Distro {{.VBranchWithDotNumber}} is now available. This release includes an update to Amazon Linux 2, which contains the latest security fixes. Amazon EKS Distro {{.VBranchWithDotNumber}} builds are available through ECR Public Gallery (https://gallery.ecr.aws/?searchTerm=EKS+Distro) and GitHub (https://github.com/aws/eks-distro)
`
