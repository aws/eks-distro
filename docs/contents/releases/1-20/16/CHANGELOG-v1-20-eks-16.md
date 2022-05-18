# Changelog for v1-20-eks-16

This changelog highlights the changes for [v1-20-eks-16](https://github.com/aws/eks-distro/tree/v1-20-eks-16).

## Changes

## Base Image

Security updates to Amazon Linux 2.

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
