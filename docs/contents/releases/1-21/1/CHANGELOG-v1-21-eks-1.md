# Changelog for v1-21-eks-1

This changelog highlights the changes for [v1-21-eks-1](https://github.com/aws/eks-distro/tree/v1-21-eks-1). 

All described changes are compared to the version of EKS-D 1.20 (v1.20-1) that was most recently released at the time of
this version's initial release and may not reflect differences between future releases of EKS-D 1.20 and v1.21-1.

## Version Upgrades

### Kubernetes

Upgraded Kubernetes to [v1.21.2](https://github.com/kubernetes/kubernetes/releases/tag/v1.21.2)

### Kubernetes Components
* etcd 3.4.15 —> 3.4.16
* metrics-server 0.4.3 —> 0.5.0
* pause 3.2 -> 3.5

### Base Image

Ungraded base image (Amazon Linux 2) version to include the latest security fixes.


## Patches

### Patch Name and Order Changes
For patches that were carried over from the previous release, there were some minor changes in the patch order (and thus
the start of each impacted patch's filename). These differences are functionally immaterial and do not impact the use or
application of the patches.

## Component Versions

| Component             | Version   |
|-----------------------|:---------:|
| aws-iam-authenticator | 0.5.2     |
| cni-plugins           | 0.8.7     |
| coredns               | 1.8.3     |
| etcd                  | 3.4.16    |
| external-attacher     | 3.1.0     |
| external-provisioner  | 2.1.1     |
| external-resizer      | 1.1.0     |
| external-snapshotter  | 3.0.3     |
| kubernetes            | 1.21.2    |
| livenessprobe         | 2.2.0     |
| metrics-server        | 0.5.0     |
| node-driver-registrar | 2.1.0     |
| pause                 | 3.5.0     |
