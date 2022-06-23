# Changelog for v1-19-eks-20

This changelog highlights the changes for [v1-19-eks-20](https://github.com/aws/eks-distro/tree/v1-19-eks-20).

---

## ⚠️⚠️⚠️ IMPORTANT ⚠️⚠️⚠️

**Support for 1.19 will be ending soon. Please update to a supported
version (1.20+) as soon as possible.**

---

## Changes

### Base Image

Security updates to Amazon Linux 2.

### Project Version Updates

* **CSI external attacher**: v3.4.0 ➞
  [v3.5.0](https://github.com/kubernetes-csi/external-attacher/releases/tag/v3.5.0)
* **CSI external resizer**: v1.4.0 ➞
  [v1.5.0](https://github.com/kubernetes-csi/external-resizer/releases/tag/v1.5.0)
* **CSI node driver registrar**: v1.5.0 ➞
  [v1.5.1](https://github.com/kubernetes-csi/node-driver-registrar/releases/tag/v1.5.1)

### Project Patches Added
* **CSI external provisioner**
  * Added a patch to fix CVE-2021-25741. See 
    [PR #959](https://github.com/aws/eks-distro/pull/959)
