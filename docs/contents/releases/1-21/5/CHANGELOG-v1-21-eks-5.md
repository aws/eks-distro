# Changelog for v1-21-eks-5

This changelog highlights the changes for [v1-21-eks-5](https://github.com/aws/eks-distro/tree/v1-21-eks-5).

## Base Image

Security updates to Amazon Linux 2.

## Patches

### Patches Removed

The following patches were in EKS-D [v1.21-4](https://github.com/aws/eks-distro/tree/v1-21-eks-4/projects/kubernetes/kubernetes/1-21/patches)
but were removed in the version.

* **0008-EKS-PATCH-Allow-override-of-kube-proxy-base-image.patch**
  * Patch is no longer needed.

### Patches Added
* **0010-PATCH-kubeadm-CoreDNS-permissions-for-endpointslices.patch**
  * Fixes error with CoreDNS. See EKS-D 
  [Issue #545](https://github.com/aws/eks-distro/issues/545).
  * Patch is from a commit in upstream Kubernetes 
  [PR #102466](https://github.com/kubernetes/kubernetes/pull/102466)
* Multiple, related patches that fix a security vulnerability with kubelet
  * New patches
    * **0009-EKS-PATCH-Pass-additional-flags-to-subpath-mount-to-avoid-flak.patch**
    * **0010-EKS-PATCH-Add-missing-interface-method-in-mount_unsupported.go.patch**
    * **0011-EKS-PATCH-Update-the-unit-tests-to-handle-mountFlags.patch**
    * **0012-EKS-PATCH-Keep-MakeMountArgSensitive-and-add-a-new-signature-t.patch**
  * About the patches
    * Security fix for upstream Kubernetes
    [issue #104980](https://github.com/kubernetes/kubernetes/issues/104980). 
    The Kubernetes version used by this EKS-D release is v1.21.4, which falls
    within the range of versions impacted by this security vulnerability.
    * Patches are from the commits in upstream Kubernetes 
    [PR #104253](https://github.com/kubernetes/kubernetes/pull/104253), which 
    should be part of Kubernetes v1.23. Upstream Kubernetes v1.21.5
    [cherry-picked](https://github.com/kubernetes/kubernetes/pull/104347) the PR.

## Contributor Shout Out

Special thanks to [jonathan-conder-sm](https://github.com/jonathan-conder-sm) 
for their contributions to this release, specifically their 
thoroughly-investigated [issue](https://github.com/aws/eks-distro/issues/545) 
and subsequent [PR](https://github.com/aws/eks-distro/issues/545) to 
add a [patch](https://github.com/aws/eks-distro/blob/v1-21-eks-5/projects/kubernetes/kubernetes/1-21/patches/0010-PATCH-kubeadm-CoreDNS-permissions-for-endpointslices.patch)
that the problem.
