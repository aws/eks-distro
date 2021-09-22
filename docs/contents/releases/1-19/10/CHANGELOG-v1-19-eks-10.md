# Changelog for v1-19-eks-10

This changelog highlights the changes for [v1-19-eks-10](https://github.com/aws/eks-distro/tree/v1-19-eks-10).

## Base Image

Security updates to Amazon Linux 2.

## Patches

### Patch Added
* **0013-EKS-CHERRYPICK-Pass-additional-flags-to-subpath-moun.patch**
  * Reduces the chance of flakes related to subpath mount in some cases.
  * Cherry-pick of upstream Kubernetes [PR #104253](https://github.com/kubernetes/kubernetes/pull/104253), 
  which should be part of the Kubernetes v1.23 release.
  * Kubernetes [v1.19.15](https://github.com/kubernetes/kubernetes/releases/tag/v1.19.15)
  also cherry-picked ([PR #104340](https://github.com/kubernetes/kubernetes/pull/104340))
  this change.
