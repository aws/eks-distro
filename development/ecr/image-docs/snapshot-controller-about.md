Amazon EKS Distro image for Kubernetes CSI External Snapshot Controller

The CSI snapshot controller watches the Kubernetes API Server for VolumeSnapshot and VolumeSnapshotContent CRD objects and manages the creation and deletion lifecycle of snapshots. It follows controller pattern and uses informers to watch for events. The snapshot controller watches for VolumeSnapshot and VolumeSnapshotContent create/update/delete events.

https://github.com/kubernetes-csi/external-snapshotter
