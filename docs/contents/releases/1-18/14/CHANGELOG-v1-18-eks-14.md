# Changelog for v1-18-eks-14

This changelog highlights the changes for [v1-18-eks-14](https://github.com/aws/eks-distro/tree/v1-18-eks-14).

## Changes

#### Overview

Most CSI sidecar versions were updated. The Go version they each use 
was also bump to 1.16. 

For more information, see [PR #675](https://github.com/aws/eks-distro/pull/675).

#### Specific CSI Sidecar Version Changes

* **external-attacher**: 3.1.0 –> [3.2.0](https://github.com/kubernetes-csi/external-attacher/releases/tag/v3.2.0)
* **external-provisioner**: 2.1.1 –> [2.2.2](https://github.com/kubernetes-csi/external-provisioner/releases/tag/v2.2.2)
* **external-resizer**: 1.1.0 –> [1.2.0](https://github.com/kubernetes-csi/external-resizer/releases/tag/v1.2.0)
* **livenessprobe**: 2.2.0 –> [2.3.0](https://github.com/kubernetes-csi/livenessprobe/releases/tag/v2.3.0)
* **node-driver-registrar**: 2.1.0 –> [2.2.0](https://github.com/kubernetes-csi/node-driver-registrar/releases/tag/v2.2.0)
