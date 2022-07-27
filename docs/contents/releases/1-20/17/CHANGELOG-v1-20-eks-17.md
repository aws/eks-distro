# Changelog for v1-20-eks-17

This changelog highlights the changes for [v1-20-eks-17](https://github.com/aws/eks-distro/tree/v1-20-eks-17).

## Changes

### Base Image

Security updates to Amazon Linux 2.

### Project Version Updates

* **CSI external attacher**: v3.4.0 ➞
  [v3.5.0](https://github.com/kubernetes-csi/external-attacher/releases/tag/v3.5.0)
* **CSI external provisioner**: v3.1.0 ➞
  [v3.1.1](https://github.com/kubernetes-csi/external-provisioner/releases/tag/v3.1.1)
* **CSI external resizer**: v1.4.0 ➞
  [v1.5.0](https://github.com/kubernetes-csi/external-resizer/releases/tag/v1.5.0)
* **CSI external snapshotter**: v4.2.1 ➞
  [v6.0.1](https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v6.0.1)
* **CSI node driver registrar**: v1.5.0 ➞
  [v1.5.1](https://github.com/kubernetes-csi/node-driver-registrar/releases/tag/v1.5.1)

### Patches Added

* **00023-EKS-PATCH-Use-private-key-fixtures-for-kubeadm-unit-.patch**
  * Cherry-pick of [upstream Kubernetes PR #98664](https://github.com/kubernetes/kubernetes/pull/98664), 
    which is included in Kubernetes 1.21. 
  * Fixes slow unit test. See umbrella 
    [Issue #98486 in upstream Kubernetes](https://github.com/kubernetes/kubernetes/issues/98486)
