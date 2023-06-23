# Release

This script builds the base images for Kubernetes, based on Amazon Linux 2
* go-runner
* kube-proxy-base

### Golang Version

As upstream Kubernetes already uses Go 1.19 to build K8 1.23, EKS-Distro has decided to release K8 
with EKS-Go 1.18+ to maintain and backport the applicable security updates of upstream Golang.
