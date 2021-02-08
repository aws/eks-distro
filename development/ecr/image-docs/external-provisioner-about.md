Amazon EKS Distro image for Kubernetes CSI External Provisioner

The CSI external-provisioner is a sidecar container that watches the Kubernetes API server for PersistentVolumeClaim objects, and dynamically provisions volumes by calling ControllerCreateVolume and ControllerDeleteVolume functions of CSI drivers. It is necessary because internal persistent volume controller running in Kubernetes controller-manager does not have any direct interfaces to CSI drivers.

https://github.com/kubernetes-csi/external-provisioner
