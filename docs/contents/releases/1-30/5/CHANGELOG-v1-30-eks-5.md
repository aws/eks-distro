# Changelog for v1-30-eks-5

This changelog highlights the changes for [v1-30-eks-5](https://github.com/aws/eks-distro/tree/v1-30-eks-5).

## Changes

### Patches
* Patch external-resizer CVE-2023-45288 by bumping /x/net to 0.23.0 ([2987](https://github.com/aws/eks-distro/pull/2987))
* Fix external-provisioner CVE-2024-3177 by bumping k8s.io/kubernetes to v1.29.4 ([2988](https://github.com/aws/eks-distro/pull/2988))
* Add CCM patches 1.28-1.30 ([3000](https://github.com/aws/eks-distro/pull/3000))
* Addresses coredns CVEs 2024-24786 & 2024-22189 in applicable versions only ([3003](https://github.com/aws/eks-distro/pull/3003))
* Revert ccm updates to 1.30.0 ([3004](https://github.com/aws/eks-distro/pull/3004))
* Bump x/net to 0.23.0 to resolve CVE-2023-45288 for CNI plugin ([3005](https://github.com/aws/eks-distro/pull/3005))

### Projects
* aws-iam-authenticator project updates 1.26 to 1.30 only ([2995](https://github.com/aws/eks-distro/pull/2995))
* Bump CCM GitTag to 1.30.0 ([2998](https://github.com/aws/eks-distro/pull/2998))
* Revert ccm updates to 1.30.0 ([3004](https://github.com/aws/eks-distro/pull/3004))

### Base Image
* Update base image in tag file(s) ([2993](https://github.com/aws/eks-distro/pull/2993))

