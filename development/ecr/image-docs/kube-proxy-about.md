Amazon EKS Distro image for Kubernetes kube-proxy

kube-proxy is a network proxy that runs on each node in a Kubernetes cluster. It reflects services as defined in the Kubernetes API on each node and can do simple TCP, UDP, and SCTP stream forwarding or round robin TCP, UDP, and SCTP forwarding across a set of backends. kube-proxy maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of the cluster.

https://kubernetes.io/docs/concepts/overview/components/#kube-proxy
https://github.com/kubernetes/kubernetes/tree/master/staging/src/k8s.io/kube-proxy
