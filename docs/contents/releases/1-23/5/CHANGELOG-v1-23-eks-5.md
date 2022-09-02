# Changelog for v1-23-eks-5

This changelog highlights the changes for [v1-23-eks-5](https://github.com/aws/eks-distro/tree/v1-23-eks-5).

## Changes

### Versions
* Updated **Kubernetes**: v1.23.7 to [v1.23.9](https://github.com/kubernetes/kubernetes/tree/v1.23.9)
* Updated **AWS IAM Authenticator for Kubernetes**: v0.5.8 -> [v0.5.9](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.9)
* Updated **Kubernetes External Provisioner**: v3.1.1 -> [v3.2.1](https://github.com/kubernetes-csi/external-provisioner/releases/tag/v3.2.1)
* Updated **GOLANG**: v1.17 -> [v1.18]()

### Patches Added
* Added 3 patches
  * 0010-EKS-PATCH-Skip-mount-point-checks-when-possible-duri.patch
  * 0011-EKS-PATCH-Add-rate-limiting-when-calling-STS-assume-.patch
  * 0012-EKS-PATCH-Update-naming-for-a-const.patch
