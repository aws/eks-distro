Amazon EKS Distro image for Kubernetes CSI Node Driver Registrar

The CSI node-driver-registrar is a sidecar container that fetches driver information (using NodeGetInfo) from a CSI endpoint and registers it with the kubelet on that node. This is necessary because Kubelet is responsible for issuing CSI NodeGetInfo, NodeStageVolume, NodePublishVolume calls. The node-driver-registrar registers your CSI driver with Kubelet so that it knows which Unix domain socket to issue the CSI calls on.

https://github.com/kubernetes-csi/node-driver-registrar
