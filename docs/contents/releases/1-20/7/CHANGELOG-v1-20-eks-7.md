# Changelog for v1-20-eks-7

This changelog highlights the changes for [v1-20-eks-7](https://github.com/aws/eks-distro/tree/v1-20-eks-7).

## Base Image

Security updates to Amazon Linux 2.

## Patches

### Patches Added
* **0012-PATCH-kubeadm-CoreDNS-permissions-for-endpointslices.patch**
  * Fixes error with CoreDNS. See EKS-D [Issue #545](https://github.com/aws/eks-distro/issues/545).
  * Patch is from a commit in upstream Kubernetes [PR #102466](https://github.com/kubernetes/kubernetes/pull/102466)
* **0013-EKS-CHERRYPICK-Pass-additional-flags-to-subpath-moun.patch**
  * Reduces the chance of flakes related to subpath mount in some cases.
  * Cherry-pick of upstream Kubernetes [PR #104253](https://github.com/kubernetes/kubernetes/pull/104253),
  which should be part of the Kubernetes v1.23 release.
  * Kubernetes [v1.20.11](https://github.com/kubernetes/kubernetes/commits/v1.20.11) 
  also cherry-picked ([PR #104348](https://github.com/kubernetes/kubernetes/pull/104348) 
  this change.

## Contributor Shout Out

Special thanks to [jonathan-conder-sm](https://github.com/jonathan-conder-sm)
for their contributions to this release, specifically their
thoroughly-investigated [issue](https://github.com/aws/eks-distro/issues/545)
and subsequent [PR](https://github.com/aws/eks-distro/issues/545) that
added a [patch](https://github.com/aws/eks-distro/blob/v1-20-eks-7/projects/kubernetes/kubernetes/1-20/patches/0012-PATCH-kubeadm-CoreDNS-permissions-for-endpointslices.patch)
and fixed the bug.
