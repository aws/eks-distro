Amazon EKS Distro image for Kubernetes CSI External Resizer

The CSI external-resizer is a sidecar container that watches the Kubernetes API server for PersistentVolumeClaim object edits and triggers ControllerExpandVolume operations against a CSI endpoint if user requested more storage on PersistentVolumeClaim object. It allows for Kubernetes control-plane volume expansion.

https://github.com/kubernetes-csi/external-resizer
