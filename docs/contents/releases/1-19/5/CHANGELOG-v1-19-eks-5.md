# Changelog for v1-19-eks-5

This changelog highlights the changes for [v1-19-eks-5](https://github.com/aws/eks-distro/tree/v1-19-eks-5).

## Version Upgrades

### Kubernetes

Upgraded Kubernetes from v1.19.8 to [v1.19.12](https://github.com/kubernetes/kubernetes/releases/tag/v1.19.12).

### Base Image

Upgraded base image (Amazon Linux 2) version to include the latest security fixes.

## Patches

### Patches Removed

* **0007-EKS-PATCH-AWS-cloudprovider-allow-nlb-ip-and-externa.patch**
    * Cherry-picked by upstream Kubernetes [PR #97975](https://github.com/kubernetes/kubernetes/pull/97975)
* **0010-EKS-PATCH-additional-subnet-configuration-for-AWS-el.patch**
    * Cherry-picked by upstream Kubernetes [PR #100416](https://github.com/kubernetes/kubernetes/pull/100416)
* **0015-2021-25735_1_19.patch**
    * Merged in upstream Kubernetes. See [Issue #100096](https://github.com/kubernetes/kubernetes/issues/100096)
    
### Minor Changes to Patches

Minor modifications were made to the patches themselves to match code changes in the upgraded Kubernetes version. These
changes are functionally immaterial and do not impact the use or application of the patches.
