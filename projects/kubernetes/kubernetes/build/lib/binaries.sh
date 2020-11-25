#!/usr/bin/env bash

function build::binaries::kube_bins() {
    local -r repository="$1"
    # Build all core components for linux arm64 and amd64
    # GOLDFLASGS
    # * strip symbol, debug, and DWARF tables
    # * set an empty build id for reproducibility
    # * build static binaries
    make \
      -C $repository \
      CGO_ENABLED=0 \
      GOLDFLAGS='-s -w --buildid=""' \
      KUBE_BUILD_PLATFORMS="linux/amd64 linux/arm64" \
      KUBE_STATIC_OVERRIDES="cmd/kubelet \
        cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl \
        cmd/kube-apiserver \
        cmd/kube-controller-manager \
        cmd/kube-scheduler" \
      WHAT="cmd/kubelet \
        cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl \
        cmd/kube-apiserver \
        cmd/kube-controller-manager \
        cmd/kube-scheduler"

    # Windows
    make \
      -C $repository \
      CGO_ENABLED=0 \
      GOLDFLAGS='-s -w --buildid=""' \
      KUBE_BUILD_PLATFORMS="windows/amd64" \
      KUBE_STATIC_OVERRIDES="cmd/kubelet \
        cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl" \
      WHAT="cmd/kubelet \
        cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl"

    # Darwin
    make \
      -C $repository \
      CGO_ENABLED=0 \
      GOLDFLAGS='-s -w --buildid=""' \
      KUBE_BUILD_PLATFORMS="darwin/amd64" \
      KUBE_STATIC_OVERRIDES="cmd/kubectl" \
      WHAT="cmd/kubectl"
}
