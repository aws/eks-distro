# Changelog for v1-20-eks-1

This changelog highlights the changes for [v1-20-eks-1](https://github.com/aws/eks-distro/tree/v1-20-eks-1).

## Upgrade Kubernetes Versions

* Upgraded Kubernetes to 1.20.4

## Patches

### Patches Removed
_The following patches were in EKS-D [v1.19-3](https://github.com/aws/eks-distro/tree/v1-19-eks-3/projects/kubernetes/kubernetes/1-19/patches)
but were removed in the version._

**Patches that were removed because their changes were made in upstream Kubernetes 1.20:**
* 0004-EKS-PATCH-volume-plugin-requests-patch.patch
  * Change is part of upstream 1.20. See [release notes](https://kubernetes.io/docs/setup/release/notes/#api-change).
  > Kube-controller-manager: volume plugins can be restricted from contacting local and loopback addresses by setting --volume-host-allow-local-loopback=false, or from contacting specific CIDR ranges by setting --volume-host-cidr-denylist (for example, --volume-host-cidr-denylist=127.0.0.1/28,feed::/16) (#91785, @mattcary) [SIG API Machinery, Apps, Auth, CLI, Network, Node, Storage and Testing]
* 0005-EKS-PATCH-Lookup-sts-endpoint-from-custom-map.patch
* 0007-EKS-PATCH-AWS-cloudprovider-allow-nlb-ip-and-externa.patch
* 0008-EKS-PATCH-Update-aws-sdk-go-to-v1.34.24.patch
    * See [PR #91513](https://github.com/kubernetes/kubernetes/pull/91513)

### Patch Name and Order Changes
For patches that were carried over from the previous release, there were some minor changes in the patch order (and thus
the start of each impacted patch's filename). These differences are functionally immaterial and do not impact the use or
application of the patches.

## Component Versions

| Component             | Version           |
|-----------------------|-------------------|
| aws-iam-authenticator | 0.5.2             |
| cni-plugins           | 0.8.7             |
| coredns               | 1.8.3             |
| etcd                  | 3.4.15            |
| external-attacher     | 3.1.0             |
| external-provisioner  | 2.1.1             |
| external-resizer      | 1.1.0             |
| external-snapshotter  | 3.0.3             |
| kubernetes            | 1.20.4            |
| livenessprobe         | 2.1.0             |
| metrics-server        | 0.4.3             |
| node-driver-registrar | 2.1.0             |
| pause                 | 3.2.0             |
