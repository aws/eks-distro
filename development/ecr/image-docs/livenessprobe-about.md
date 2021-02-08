Amazon EKS Distro image for Kubernetes CSI Livenessprobe

The CSI livenessprobe is a sidecar container that monitors the health of the CSI driver and reports it to Kubernetes via the Liveness Probe mechanism. This enables Kubernetes to automatically detect issues with the driver and restart the pod to try and fix the issue. The container exposes an HTTP /healthz endpoint, which serves as kubelet's livenessProbe hook to monitor health of a CSI driver. All CSI drivers should use the liveness probe to improve the availability of the driver while deployed on Kubernetes.

https://github.com/kubernetes-csi/livenessprobe
