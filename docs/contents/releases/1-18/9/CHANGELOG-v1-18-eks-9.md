# Changelog for v1-18-eks-9

This changelog highlights the changes for [v1-18-eks-9](https://github.com/aws/eks-distro/tree/v1-18-eks-9).

## Version Upgrades

### Kubernetes

Upgraded Kubernetes from v1.18.16 to [v1.18.20](https://github.com/kubernetes/kubernetes/releases/tag/v1.18.20).

### Base Image

Upgraded base image (Amazon Linux 2) version to include the latest security fixes.

## Patches

### Patches Removed

* **AWS-cloudprovider-allow-nlb-ip-and-externa.patch**
    * Cherry-picked by upstream Kubernetes [PR #97973](https://github.com/kubernetes/kubernetes/pull/97973)
* **0015-2021-25735_1_19.patch**
    * Merged in upstream Kubernetes. See [Issue #100096](https://github.com/kubernetes/kubernetes/issues/100096)

### Minor Changes to Patches

Minor modifications were made to the patches themselves to match code changes in the upgraded Kubernetes version. These
changes are functionally immaterial and do not impact the use or application of the patches.
