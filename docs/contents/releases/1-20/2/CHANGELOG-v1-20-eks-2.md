# Changelog for v1-20-eks-2

This changelog highlights the changes for [v1-20-eks-2](https://github.com/aws/eks-distro/tree/v1-20-eks-2).

## Version Upgrades

### Kubernetes

Upgraded Kubernetes to [v1.20.7](https://github.com/kubernetes/kubernetes/releases/tag/v1.20.7)

### Base Image

Upgraded base image (Amazon Linux 2) version to include the latest security fixes.

## Patches

### Patches Removed

The following patches were in EKS-D [v1.20-1](https://github.com/aws/eks-distro/tree/v1-20-eks-1/projects/kubernetes/kubernetes/1-20/patches)
but were removed in the version.

* **0006-EKS-PATCH-additional-subnet-configuration-for-AWS-EL.patch**
    * Merged in upstream Kubernetes [PR #97431](https://github.com/kubernetes/kubernetes/pull/97431)
* **0011-2020-25735_1_20.patch**
    * Merged in upstream Kubernetes [See issue #100096](https://github.com/kubernetes/kubernetes/issues/100096)

### Patches Added

* **0010-EKS-PATCH-chunk-target-operation-for-aws-targ.patch**
    * Fixes bug related to AWS TargetGroup
    * Kubernetes/Kubernetes [PR #101592](https://github.com/kubernetes/kubernetes/pull/101592), which should be included
      in Kubernetes 1.22. This change was [cherry picked](https://github.com/kubernetes/kubernetes/pull/101813) for
      upstream Kubernetes 1.20

### Patch Name and Order Changes

For patches that were carried over from the previous release, there were some minor changes in the patch order (and thus
the start of each impacted patch's filename). These differences are functionally immaterial and do not impact the use or
application of the patches.
