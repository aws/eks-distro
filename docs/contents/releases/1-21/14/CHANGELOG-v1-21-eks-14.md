# Changelog for v1-21-eks-14

This changelog highlights the changes for [v1-21-eks-14](https://github.com/aws/eks-distro/tree/v1-21-eks-14).

## Changes

### Base Image

Security updates to Amazon Linux 2.

### Kubernetes Version
* Updated Kubernetes version from 1.21.9 to
  [1.21.12](https://github.com/kubernetes/kubernetes/tree/v1.21.12)

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

### Patches Added
* **0024-EKS-PATCH-Fix-kubectl-version-unit-test.patch**
  * Cherry-pick of upstream Kubernetes PR
    [#103955](https://github.com/kubernetes/kubernetes/pull/103955), which is
    included in Kubernetes 1.23.
  * Fixes configuration requirement that results in test 
    TestNewCmdVersionWithoutConfigFile failing for some developers.

### Patches Removed
* **0019-EKS-PATCH-AWS-Set-max-results-if-its-not-set.patch**
  * The Updated version of Kubernetes cherrypicked this change in PR
    [#106280](https://github.com/kubernetes/kubernetes/pull/107653)
