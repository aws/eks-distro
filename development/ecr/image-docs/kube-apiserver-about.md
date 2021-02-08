Amazon EKS Distro image for Kubernetes kube-apiserver

The Kubernetes API server validates and configures data for the api objects which include pods, services, replicationcontrollers, and others. The API Server exposes the Kubernetes API which services REST operations and provides the frontend to the cluster's shared state through which all other components interact. kube-apiserver is designed to scale horizontally, that is, it scales by deploying more instances. You can run several instances of kube-apiserver and balance traffic between those instances.

https://kubernetes.io/docs/concepts/overview/components/#kube-apiserver
https://github.com/kubernetes/kubernetes/tree/master/staging/src/k8s.io/apiserver
