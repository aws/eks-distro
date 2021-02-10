Amazon EKS Distro image for Kubernetes kube-scheduler

The kube-scheduler is a Control plane component that watches for newly created Pods with no assigned node, and selects a node for them to run on. The scheduler determines which Nodes are valid placements for each Pod in the scheduling queue according to constraints and available resources. It then ranks each valid Node and binds the Pod to a suitable Node. Factors taken into account for scheduling decisions include: individual and collective resource requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference, and deadlines.

https://kubernetes.io/docs/concepts/overview/components/#kube-scheduler
https://github.com/kubernetes/kubernetes/tree/master/staging/src/k8s.io/kube-scheduler
