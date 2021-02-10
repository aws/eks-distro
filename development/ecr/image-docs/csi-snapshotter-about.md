Amazon EKS Distro image for Kubernetes CSI External Snapshotter

The CSI external-snapshotter sidecar watches the Kubernetes API server for VolumeSnapshotContent CRD objects. It is also responsible for calling the CSI RPCs CreateSnapshot, DeleteSnapshot, and ListSnapshots. CSI drivers that support provisioning volume snapshots and the ability to provision new volumes using those snapshots should use this sidecar container, and advertise the CSI CREATE_DELETE_SNAPSHOT controller capability.

https://github.com/kubernetes-csi/external-snapshotter
