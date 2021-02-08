Amazon EKS Distro image for Kubernetes CSI External Attacher

The CSI external-attacher is a sidecar container that watches the Kubernetes API server for VolumeAttachment objects and triggers Controller[Publish|Unpublish]Volume operations against a CSI endpoint in order to attach/detach volumes to/from nodes. It is necessary because internal Attach/Detach controller running in Kubernetes controller-manager does not have any direct interfaces to CSI drivers.

https://github.com/kubernetes-csi/external-attacher 
