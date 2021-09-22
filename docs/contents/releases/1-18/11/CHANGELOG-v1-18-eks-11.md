# Changelog for v1-18-eks-11

This changelog highlights the changes for [v1-18-eks-11](https://github.com/aws/eks-distro/tree/v1-18-eks-11).

## Base Image

Security updates to Amazon Linux 2.

## Patches

### Patch Added
* **00018-EKS-Patch-Pass-additional-flags-to-subpath-mount-to-.patch**
  * Reduces the chance of flakes related to subpath mount in some cases.
  * Cherry-pick of upstream Kubernetes [PR #104253](https://github.com/kubernetes/kubernetes/pull/104253),
    which should be part of the Kubernetes v1.23 release.
