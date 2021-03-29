# Changelog for v1-19-eks-2

This changelog highlights the changes for [v1-19-eks-2)](https://github.com/aws/eks-distro/tree/v1-19-eks-2).

## Patches

### Patches Added
_The following patches were not in EKS-D [v1.19-1](https://github.com/aws/eks-distro/tree/v1-19-eks-1/projects/kubernetes/kubernetes/1-19/patches)
but were added in the version._

* **0013-EKS-PATCH-aws_credentials-update-ecr-url-validation-.patch**
* Adds support for ECR endpoints in isolated AWS regions. There is an open PR ([#95415](https://github.com/kubernetes/kubernetes/pull/95415))
  for upstream Kubernetes that applies these changes.
* This patch was part of 1.18 but was left out of 1.19-1

* **0014-EKS-PATCH-Delete-leaked-volume-if-driver-doesn-t-kno.patch**
  * This patch applies the changes from upstream Kubernetes [PR #99664](https://github.com/kubernetes/kubernetes/pull/99664),
    which is open as of the time of EKS-D v1.19-2 release, and is raised in [issue #754](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/issues/754)
    in aws-ebs-csi-driver.
  * The changes in this patch fix a bug where a volume could be created during the create process, but the driver does
    not know the status of this volume. The changes in this patch now delete the leaked driver.
  * This patch was added in 1.18-2 but was left out of 1.19-1, as it did not exist at the time of 1.19-1 release.
