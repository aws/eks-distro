Amazon EKS Distro image for Kubernetes CSI External Snapshot Validation Webhook

Note: This webhook has deprecated by Kubernetes as of external-snapshotter v8.0.0, and removed as of v8.2.0. See https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v8.2.0

The snapshot validating webhook is an HTTP callback which responds to admission requests. It provides tighter validation for volume snapshot objects. This webhook introduces the ratcheting validation mechanism that performs stricter validation. It should be installed alongside the snapshot controllers and CRDs.

https://github.com/kubernetes-csi/external-snapshotter
