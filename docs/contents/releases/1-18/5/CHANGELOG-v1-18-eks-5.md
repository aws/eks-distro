# Changelog for v1-18-eks-5

This changelog highlights the changes for [v1-18-eks-5](https://github.com/aws/eks-distro/tree/v1-18-eks-5).

## Version Upgrades 

### Base Image

Ungraded base image (Amazon Linux 2) version to include the latest security fixes.

## Patches 

### Added

* **0019-0019-EKS-PATCH-chunk-target-operation-for-aws-targ.patch**
  * Fixes bug related to AWS TargetGroup
  * Kubernetes/Kubernetes [PR #101592](https://github.com/kubernetes/kubernetes/pull/101592), which should be included 
    in Kubernetes 1.22. This change was [cherrypicked](https://github.com/kubernetes/kubernetes/pull/101592) for 
    upstream Kubernetes 1.18
    