#!/usr/bin/env bash
# Copyright 2020 Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function build::binaries::get_go_version_k8s() {
    local -r releasebranch="$1"

    if [[ "$releasebranch" == "1-18" ]]; then
        echo "1.13"
    else
        echo "1.15"
    fi
}

function build::binaries::use_go_version_k8s() {
    local -r releasebranch="$1"

    build::common::use_go_version $(build::binaries::get_go_version_k8s $releasebranch)
}

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
