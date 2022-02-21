# Changelog for v1-21-eks-9

This changelog highlights the changes for [v1-21-eks-9](https://github.com/aws/eks-distro/tree/v1-21-eks-9).

### Base Image

Security updates to Amazon Linux 2.

### Patches Added

* **0019-EKS-PATCH-AWS-Set-max-results-if-its-not-set.patch**
  * Cherry-pick of [Kubernetes PR #106280](https://github.com/kubernetes/kubernetes/pull/106280), which is included in 
    Kubernetes 1.24. There was an [upstream PR](https://github.com/kubernetes/kubernetes/pull/107653) opened
    to cherry-pick this change for 1.21, but it was not approved before the release of the patch version of Kubernetes 
    EKS-Distro uses for 1.21.
  * If max results is not set and instance IDs are not provided for the describe instances call in the aws cloud
    provider, set max results. This prevents an expensive call against the EC2 API, which can result in timeouts.
* **0020-EKS-PATCH-extend-sa-token-if-audience-is-apiserver-1.patch**
  * Cherry-pick of [Kubernetes PR #105954](https://github.com/kubernetes/kubernetes/pull/105954), which is included in 
    Kubernetes 1.24. 
  * This fixes a bug related to extended SA token expiration when the audience is not kube-apiserver, as described in 
    [Kubernetes issue #105801](https://github.com/kubernetes/kubernetes/issues/105801).
* **0021-EKS-PATCH-Parse-ipv6-address-before-comparison-10773.patch**
  * Modified cherry-pick of [Kubernetes PR #107736](https://github.com/kubernetes/kubernetes/pull/107736), which is
    included in Kubernetes 1.24. The difference between this patch and the upstream change is the upstreams use of 
    forked golang parsers, which were not included in the minor Kubernetes version that this patch applied to for EKS-D.
  * This fixes a bug related to ipv6 clusters, as described in 
    [Kubernetes Issue #107735](https://github.com/kubernetes/kubernetes/issues/107735).

### Patches Removed

* **0017-EKS-PATCH-apiserver-healthz-upper-log-verbosity-for-.patch**
  * This patched was removed because it assumed that users would have a certain alarm setup, which may not have been the
    case. Users may notice an uptick of "kms-provider-0" errors in logs, as this patch intended to reduce this noise.

#### CSI Sidecar Version Changes

* **external-snapshotter**: 3.0.3 –> [4.1.1](https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v4.1.1)
