# Changelog for v1-20-eks-18

This changelog highlights the changes for [v1-20-eks-18](https://github.com/aws/eks-distro/tree/v1-20-eks-18).

## Changes

### Project Version Updates

* **CSI external-provisioner**: v3.1.1 ➞ [v3.2.1](https://github.com/kubernetes-csi/external-provisioner/releases/tag/v3.2.1)
* **AWS IAM Authenticator for Kubernetes**: v0.5.8 ➞ [v0.5.9](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.9)

### Patches Added

* **0024-EKS-PATCH-Mark-device-as-uncertain-if-unmount-device.patch**
  * Cherry-pick of upstream [Kubernetes PR #107789](https://github.com/kubernetes/kubernetes/pull/107789), which is included in Kubernetes 1.24 and cherry-picked by 1.21 - 1.23.
  * From the original PR description: 
    "If unmount device succeeds but somehow unmount operation fails because device was in-use elsewhere, we should mark the device mount as uncertain because we can't use the global mount point at this point."
