# Changelog for v1-19-eks-2

This changelog highlights the changes for [v1-19-eks-2)](https://github.com/aws/eks-distro/tree/v1-19-eks-2).

## Patches

### Patches Added
_The following patches were not in EKS-D [v1.19.1](https://github.com/aws/eks-distro/tree/v1-19-eks-1/projects/kubernetes/kubernetes/1-19/patches)
but were added in the version._

* **0013-EKS-PATCH-aws_credentials-update-ecr-url-validation-.patch**
* Adds support for ECR endpoints in isolated AWS regions. There is an open PR ([#95415](https://github.com/kubernetes/kubernetes/pull/95415))
  for upstream Kubernetes that applies these changes.
* This patch was part of 1.18 but was left out of 1.19.1
