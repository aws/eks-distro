# Changelog for v1-28-eks-26

This changelog highlights the changes for [v1-28-eks-26](https://github.com/aws/eks-distro/tree/v1-28-eks-26).

## Changes

### Patches
* Bump livenessprobe git tag to v2.13.0 and go version to 1.22 ([3066](https://github.com/aws/eks-distro/pull/3066))
* Remove vendoring and fix xnet patch to reflect for CCM ([3133](https://github.com/aws/eks-distro/pull/3133))
* CCM: add patches for CVE-2023-45288 ([3122](https://github.com/aws/eks-distro/pull/3122))
* CSI project bumps: attacher v4.6.1, provisioner to v5.0.1 ([3111](https://github.com/aws/eks-distro/pull/3111))
* Bump CSI external-resizer v1.11.1 ([3113](https://github.com/aws/eks-distro/pull/3113))
* Kubernetes CSI Bumps ([3088](https://github.com/aws/eks-distro/pull/3088))
* Remove unneeded ccm patches ([3033](https://github.com/aws/eks-distro/pull/3033))
* Bump x/net to 0.23.0 to resolve CVE-2023-45288 for CNI plugin ([3005](https://github.com/aws/eks-distro/pull/3005))
* Addresses coredns CVEs 2024-24786 & 2024-22189 in applicable versions only ([3003](https://github.com/aws/eks-distro/pull/3003))
* Add CCM patches 1.28-1.30 ([3000](https://github.com/aws/eks-distro/pull/3000))
* Kubernetes project updates 1.27 to 1.29 ([2994](https://github.com/aws/eks-distro/pull/2994))
* Patch external-resizer CVE-2023-45288 by bumping /x/net to 0.23.0 ([2987](https://github.com/aws/eks-distro/pull/2987))
* Fix external-provisioner CVE-2024-3177 by bumping k8s.io/kubernetes to v1.29.4 ([2988](https://github.com/aws/eks-distro/pull/2988))
* external-resizer project updates 1.25-1.29 ([2956](https://github.com/aws/eks-distro/pull/2956))
* node-driver-registrar project updates 1.25-1.29 ([2959](https://github.com/aws/eks-distro/pull/2959))
* external-snapshotter project updates 1.25-1.29 ([2958](https://github.com/aws/eks-distro/pull/2958))
* external-attacher project updates 1.25-1.29 ([2957](https://github.com/aws/eks-distro/pull/2957))
* kubernetes project updates 1.25-1.29 ([2955](https://github.com/aws/eks-distro/pull/2955))
* external-provisioner project updates 1.25-1.29 ([2960](https://github.com/aws/eks-distro/pull/2960))
* Bump metrics-server from v0.7.0 to v0.7.1 for 1.25 to 1.29 ([2888](https://github.com/aws/eks-distro/pull/2888))

### Projects
* Bump livenessprobe git tag to v2.13.0 and go version to 1.22 ([3066](https://github.com/aws/eks-distro/pull/3066))
* Bump node-driver-registrar git tag to v2.11.0 and go version to 1.22 ([3067](https://github.com/aws/eks-distro/pull/3067))
* CSI project bumps: attacher v4.6.1, provisioner to v5.0.1 ([3111](https://github.com/aws/eks-distro/pull/3111))
* Bump CSI external-resizer v1.11.1 ([3113](https://github.com/aws/eks-distro/pull/3113))
* Bump CSI external-snapshotter v8.0.1 ([3112](https://github.com/aws/eks-distro/pull/3112))
* Kubernetes CSI Bumps ([3088](https://github.com/aws/eks-distro/pull/3088))
* Kubernetes project updates ([3042](https://github.com/aws/eks-distro/pull/3042))
* etcd project updates ([3044](https://github.com/aws/eks-distro/pull/3044))
* aws-iam-authenticator project updates 1.26 to 1.30 only ([2995](https://github.com/aws/eks-distro/pull/2995))
* Kubernetes project updates 1.27 to 1.29 ([2994](https://github.com/aws/eks-distro/pull/2994))
* Bump etcd to v3.5.13 ([2964](https://github.com/aws/eks-distro/pull/2964))
* external-resizer project updates 1.25-1.29 ([2956](https://github.com/aws/eks-distro/pull/2956))
* node-driver-registrar project updates 1.25-1.29 ([2959](https://github.com/aws/eks-distro/pull/2959))
* external-snapshotter project updates 1.25-1.29 ([2958](https://github.com/aws/eks-distro/pull/2958))
* external-attacher project updates 1.25-1.29 ([2957](https://github.com/aws/eks-distro/pull/2957))
* kubernetes project updates 1.25-1.29 ([2955](https://github.com/aws/eks-distro/pull/2955))
* ccm project updates 1.25-1.29 ([2954](https://github.com/aws/eks-distro/pull/2954))
* authenticator project updates 1.25-1.29 ([2953](https://github.com/aws/eks-distro/pull/2953))
* external-provisioner project updates 1.25-1.29 ([2960](https://github.com/aws/eks-distro/pull/2960))
* Bump etcd to v3.5.12 ([2934](https://github.com/aws/eks-distro/pull/2934))
* Bump metrics-server from v0.7.0 to v0.7.1 for 1.25 to 1.29 ([2888](https://github.com/aws/eks-distro/pull/2888))

### Base Image
* Update base image in tag file(s) ([2993](https://github.com/aws/eks-distro/pull/2993))
* Update base image in tag file(s) ([2951](https://github.com/aws/eks-distro/pull/2951))

