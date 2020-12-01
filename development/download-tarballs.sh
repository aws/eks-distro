#!/usr/bin/env bash -ex
#
# This script dumps the contents in the current directory
#
platform="${1:-linux/amd64}"
directory="kubernetes-1-18"
release="${2:-v1.18.9}"

curl -O https://distro.eks.amazonaws.com/${directory}/${directory}-eks-1.yaml
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-apiserver.tar | tar zx
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-controller-manager.tar | tar zx
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-scheduler.tar | tar zx
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/bin/${platform}/kube-proxy.tar | tar zx
curl -L https://distro.eks.amazonaws.com/${directory}/releases/1/artifacts/kubernetes/${release}/kubernetes-client-darwin-amd64.tar.gz | tar zx

