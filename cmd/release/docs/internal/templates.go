package internal

// Templates for CHANGELOG
const changeLogBase = `# Changelog for {{.V_Branch_EKS_Number}}

This changelog highlights the changes for [{{.V_Branch_EKS_Number}}](https://github.com/aws/eks-distro/tree/{{.V_Branch_EKS_Number}}).

`

const ChangeLogBaseImage = changeLogBase + `## Changes
Security updates to Amazon Linux 2.
`

// Template for index.md in docs directory
const IndexInBranch = `# EKS-D {{.V_Branch_EKS_Number}} Release

For additional information, see the [changelog](CHANGELOG-{{.V_Branch_EKS_Number}}.md) for this release.

## Release Manifest
Download the release manifest here: [kubernetes-{{.Branch_EKS_Number}}.yaml](https://distro.eks.amazonaws.com/kubernetes-{{.Branch}}/kubernetes-{{.Branch_EKS_Number}}.yaml)
`

// Template for release announcement
const ReleaseAnnouncement = `Amazon EKS Distro {{.V_BranchWithDot_Number}} is now available. This release includes an update to Amazon Linux 2, which contains the latest security fixes. Amazon EKS Distro {{.V_BranchWithDot_Number}} builds of Kubernetes are available through ECR Public Gallery (https://gallery.ecr.aws/?searchTerm=EKS+Distro) and GitHub (https://github.com/aws/eks-distro)
`
