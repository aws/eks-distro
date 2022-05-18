# Changelog for v1-22-eks-7

This changelog highlights the changes for [v1-22-eks-7](https://github.com/aws/eks-distro/tree/v1-22-eks-7).

## Changes

### Base Image

Security updates to Amazon Linux 2.

### Kubernetes Version
* Updated Kubernetes version from 1.22.9 to
  [1.22.6](https://github.com/kubernetes/kubernetes/tree/v1.22.9)

### Project Version Updates

* **AWS IAM Authenticator for Kubernetes**: v0.5.7 ➞
  [v0.5.8](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.8)
* **CSI livenessprobe**: v2.6.0 ➞
  [v2.7.0](https://github.com/kubernetes-csi/livenessprobe/releases/tag/v2.7.0)

### Project Dependency Patch Updates
* Updated the following projects' dependencies
  * CNI (PR [#921](https://github.com/aws/eks-distro/pull/921))
  * external-snapshotter (PR [#922](https://github.com/aws/eks-distro/pull/922))
  * etcd (PR [#923](https://github.com/aws/eks-distro/pull/923))

### Patches Removed
* **0019-EKS-PATCH-AWS-Set-max-results-if-its-not-set.patch**
  * The updated version of Kubernetes cherrypicked this change in PR
    [#107652](https://github.com/kubernetes/kubernetes/pull/107652)
