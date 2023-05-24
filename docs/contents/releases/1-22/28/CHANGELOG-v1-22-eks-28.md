# Changelog for v1-22-eks-28

This changelog highlights the changes for [v1-22-eks-28](https://github.com/aws/eks-distro/tree/v1-22-eks-28).

## IMPORTANT: THIS IS THE LAST 1.22 RELEASE

In alignment with the [Amazon EKS release calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar)
and the EKS Distro release cadence, this release will be the last one for 
Kubernetes 1.22. While there are no plans to remove this version's images 
from EKS Distro ECR, there will be no more updates, including security fixes,
for it.

**Due to the increased security risk this poses, it is HIGHLY recommended that
users of v1.22 update to a supported version (v1.23+) as soon as possible.**

## Changes

### Patches
* Add patch from upstream  golang/x/net bump to 0.7.0 ([2049](https://github.com/aws/eks-distro/pull/2049))

### Projects
No changes since last release

### Base Image
* Update base image in tag file(s) ([2053](https://github.com/aws/eks-distro/pull/2053))

