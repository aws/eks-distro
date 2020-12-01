#!/usr/bin/env bash -ex
#
# This script dumps the kubectl command in the current directory
#
platform="${1:-linux/amd64}"
directory="kubernetes-1-18"
release="${2:-v1.18.9}"

curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-apiserver.tar | docker import - public.ecr.aws/eks-distro/kubernetes/kube-apiserver:${release}-eks-1-18-1
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-controller-manager.tar  | docker import - public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:${release}-eks-1-18-1
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-scheduler.tar  | docker import - public.ecr.aws/eks-distro/kubernetes/kube-scheduler:${release}-eks-1-18-1
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-proxy.tar  | docker import - public.ecr.aws/eks-distro/kubernetes/kube-proxy:${release}-eks-1-18-1
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/kubernetes-client-darwin-amd64.tar.gz | tar xz
