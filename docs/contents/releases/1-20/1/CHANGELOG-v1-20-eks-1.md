# Changelog for v1-20-eks-1

This changelog highlights the changes for [v1-20-eks-1](https://github.com/aws/eks-distro/tree/v1-20-eks-1). 

All described changes are compared to the version of EKS-D 1.19 (v1.19-4) that was most recently released at the time of
this version's initial release and may not reflect differences between to future releases of EKS-D 1.19 and v1.20-1.

## Version Upgrades

### Kubernetes

Upgraded Kubernetes to [v1.20.4](https://github.com/kubernetes/kubernetes/releases/tag/v1.20.4)

### Kubernetes Components
* coredns 1.8.0 —> 1.8.3
* etcd 3.4.14 —> 3.4.15
* metrics-server 0.4.0 —> 0.4.3

### Base Image

Ungraded base image (Amazon Linux 2) version to include the latest security fixes.


## Patches

### Patches Removed

The following patches were in EKS-D [v1.19-4](https://github.com/aws/eks-distro/tree/v1-19-eks-4/projects/kubernetes/kubernetes/1-19/patches)
but were removed in the version.

* **0004-EKS-PATCH-volume-plugin-requests-patch.patch**
  * Merged in upstream Kubernetes [PR #91785](https://github.com/kubernetes/kubernetes/pull/91785/)
  * For additional information, see the [API Changes](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#api-change-3)
    section of the Kubernetes 1.20 changelog or the quoted portion here:
    > Kube-controller-manager: volume plugins can be restricted from contacting local and loopback addresses by setting --volume-host-allow-local-loopback=false, or from contacting specific CIDR ranges by setting --volume-host-cidr-denylist (for example, --volume-host-cidr-denylist=127.0.0.1/28,feed::/16)
* **0006-EKS-PATCH-using-regional-sts-endpoint-for-assume-ecr.patch**
  * Functionality no longer must be provided here 
* **0007-EKS-PATCH-AWS-cloudprovider-allow-nlb-ip-and-externa.patch**
  *  Merged in upstream Kubernetes [PR #92839](https://github.com/kubernetes/kubernetes/pull/92839/)
* **0008-EKS-PATCH-Update-aws-sdk-go-to-v1.34.24.patch**
    * Merged in upstream Kubernetes [PR #91513](https://github.com/kubernetes/kubernetes/pull/91513)

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
| etcd                  | 3.4.15    |
| external-attacher     | 3.1.0     |
| external-provisioner  | 2.1.1     |
| external-resizer      | 1.1.0     |
| external-snapshotter  | 3.0.3     |
| kubernetes            | 1.20.4    |
| livenessprobe         | 2.2.0     |
| metrics-server        | 0.4.3     |
| node-driver-registrar | 2.1.0     |
| pause                 | 3.2.0     |
