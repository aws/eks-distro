# Changelog for v1-20-eks-1

This changelog highlights the changes for [v1-20-eks-1](https://github.com/aws/eks-distro/tree/v1-20-eks-1).

## Upgrade Kubernetes Versions

* Upgraded Kubernetes to 1.20.4

## Patches

### Patches Removed
_The following patches were in EKS-D [v1.19.1](https://github.com/aws/eks-distro/tree/v1-19-eks-1/projects/kubernetes/kubernetes/1-19/patches)
but were removed in the version._

🚨 TODO!! Confirm reason for each removal
* 0005-EKS-PATCH-Lookup-sts-endpoint-from-custom-map.patch
* 0007-EKS-PATCH-AWS-cloudprovider-allow-nlb-ip-and-externa.patch

**Patches that were removed because their changes were made in upstream Kubernetes 1.20:**
* 0008-EKS-PATCH-Update-aws-sdk-go-to-v1.34.24.patch
  * See [PR #91513](https://github.com/kubernetes/kubernetes/pull/91513)
    
### Patches Added
🚨 TODO!! Some clarification about the credential patch being un-removed?
None.

### Patch Name and Order Changes
For patches that were carried over from the previous release, there were some minor changes in the patch order (and thus
the start of each impacted patch's filename). These differences are functionally immaterial and do not impact the use or
application of the patches.

## Component Versions

🚨 TODO!! All these values are from 1.19.1.

| Component             | Version           |
|-----------------------|-------------------|
| aws-iam-authenticator | 0.5.2             |
| cni-plugins           | 0.8.7             |
| coredns               | 1.8.0             |
| etcd                  | 3.4.14            |
| external-attacher     | 3.0.1             |
| external-provisioner  | 2.0.3             |
| external-resizer      | 1.0.1             |
| external-snapshotter  | 3.0.2             |
| kubernetes            | 1.18.9 --> 1.19.6 |
| livenessprobe         | 2.1.0             |
| metrics-server        | 0.4.0             |
| node-driver-registrar | 2.0.1             |
