package templates

const ReleaseAnnouncementForOnlyBaseImage = announcementStart +
	`This release includes an update to Amazon Linux 2, which contains the latest security fixes. ` +
	announcementEnd

const ReleaseAnnouncementGenericBase = announcementStart + announcementEnd

const announcementStart = `Amazon EKS Distro {{.VBranchWithDotNumber}} is now available. `
const announcementEnd = `Amazon EKS Distro {{.VBranchWithDotNumber}} builds are available through ECR Public Gallery (https://gallery.ecr.aws/eks-distro) and GitHub (https://github.com/aws/eks-distro)
`
