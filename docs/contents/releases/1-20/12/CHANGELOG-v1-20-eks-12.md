# Changelog for v1-20-eks-12

This changelog highlights the changes for [v1-20-eks-12](https://github.com/aws/eks-distro/tree/v1-20-eks-12).

## Version Updates

### Kubernetes
**Updated from v1.20.11 to [v1.20.15](https://github.com/kubernetes/kubernetes/releases/tag/v1.20.15)**

### Projects
* **AWS IAM Authenticator for Kubernetes**: v0.5.3 ➞
  [v0.5.5](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.5)
* **CSI external-attacher**: v3.2.0 ➞ [v3.4.0](https://github.com/kubernetes-csi/external-attacher/releases/tag/v3.4.0)
* **CSI external-provisioner**: v2.2.0 ➞ [v3.1.0](https://github.com/kubernetes-csi/external-provisioner/releases/tag/v3.1.0)
* **CSI external-resizer**: v1.2.0 ➞ [v1.4.0](https://github.com/kubernetes-csi/external-resizer/releases/tag/v1.4.0)
* **CSI external-snapshotter**: v4.1.1 ➞ [v4.2.1](https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v4.2.1)
* **CSI livenessprobe**: v2.3.0 ➞ [v2.6.0](https://github.com/kubernetes-csi/livenessprobe/releases/tag/v2.6.0)
* **CSI node-driver-registrar**: v2.2.0 ➞
    [v2.5.0](https://github.com/kubernetes-csi/node-driver-registrar/releases/tag/v2.5.0)
* **etcd**: v3.4.15 ➞ [v3.4.18](https://github.com/etcd-io/etcd/releases/tag/v3.4.18)
* **Metrics Server**: v0.4.5 ➞ [v0.6.1](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.6.1)

### Base Image

Security updates to Amazon Linux 2.

## Patch Changes

### Patches Removed
* **0016-EKS-PATCH-Refine-locking-in-API-Priority-and-Fairnes.patch**
  * Cherry-picked by [upstream Kubernetes PR #105051](https://github.com/kubernetes/kubernetes/pull/105051) and 
    [included](https://github.com/kubernetes/kubernetes/commits/v1.20.15?after=8f1e5bf0b9729a899b8df86249b56e2c74aebc55+105&branch=v1.20.15)
    in the version of Kubernetes used in the release.
