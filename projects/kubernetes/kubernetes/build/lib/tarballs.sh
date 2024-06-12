#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
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


source "${MAKE_ROOT}/../../../build/lib/common.sh"

readonly KUBE_SUPPORTED_SERVER_PLATFORMS=(
  linux/amd64
  linux/arm64
)

readonly KUBE_SUPPORTED_NODE_PLATFORMS=(
  linux/amd64
  linux/arm64
  windows/amd64
)

readonly KUBE_SUPPORTED_CLIENT_PLATFORMS=(
  linux/amd64
  linux/arm64
  darwin/amd64
  windows/amd64
)

### server binaries
function build::tarballs::server_targets() {
  local targets=(
    cmd/kube-proxy
    cmd/kube-apiserver
    cmd/kube-controller-manager
    cmd/kubelet
    cmd/kubeadm
    cmd/kube-scheduler
    cmd/kubectl
  )
  echo "${targets[@]}"
}

IFS=" " read -ra KUBE_SERVER_TARGETS <<< "$(build::tarballs::server_targets)"
readonly KUBE_SERVER_TARGETS
readonly KUBE_SERVER_BINARIES=("${KUBE_SERVER_TARGETS[@]##*/}")
readonly KUBE_SERVER_IMAGES=(kube-proxy kube-apiserver kube-controller-manager kube-scheduler)

### node binaries
function build::tarballs::node_targets() {
  local targets=(
    cmd/kube-proxy
    cmd/kubeadm
    cmd/kubelet
  )
  echo "${targets[@]}"
}

IFS=" " read -ra KUBE_NODE_TARGETS <<< "$(build::tarballs::node_targets)"
readonly KUBE_NODE_TARGETS
readonly KUBE_NODE_BINARIES=("${KUBE_NODE_TARGETS[@]##*/}")
readonly KUBE_NODE_BINARIES_WIN=("${KUBE_NODE_BINARIES[@]/%/.exe}")

### client binaries
readonly KUBE_CLIENT_TARGETS=(
  cmd/kubectl
)
readonly KUBE_CLIENT_BINARIES=("${KUBE_CLIENT_TARGETS[@]##*/}")
readonly KUBE_CLIENT_BINARIES_WIN=("${KUBE_CLIENT_BINARIES[@]/%/.exe}")

function build::tarballs::create_tarballs(){
    local -r bin_root="$1"
    local -r output_dir="$2"
    local -r tar_output_dir="$3"
    local -r images_root="$4"

    for platform in "${KUBE_SUPPORTED_SERVER_PLATFORMS[@]}"; do
        # The substitution on platform_src below will replace all slashes with
        # dashes.  It'll transform darwin/amd64 -> darwin-amd64.
        local platform_src="${platform//\//-}"

        tarball=$tar_output_dir/kubernetes-server-$platform_src.tar.gz
        local ch_dir="${output_dir}/${platform}"
        local bin_dir="${output_dir}/${platform}/kubernetes/server/bin"
        mkdir -p $bin_dir
        for bin in ${KUBE_SERVER_BINARIES[@]}; do
            cp ${bin_root}/${platform}/${bin} $bin_dir
        done
        for image in ${KUBE_SERVER_IMAGES[@]}; do
            cp ${images_root}/${platform}/${image}.tar $bin_dir
            cp ${images_root}/${platform}/${image}.docker_tag $bin_dir
        done
        cp -rf $output_dir/LICENSES $ch_dir/kubernetes
        cp $output_dir/ATTRIBUTION.txt $ch_dir/kubernetes
        build::common::create_tarball $tarball $ch_dir kubernetes
        rm -rf $ch_dir
        rmdir $(dirname $ch_dir)
    done

    for platform in "${KUBE_SUPPORTED_NODE_PLATFORMS[@]}"; do
        # The substitution on platform_src below will replace all slashes with
        # dashes.  It'll transform darwin/amd64 -> darwin-amd64.
        local platform_src="${platform//\//-}"
        tarball=$tar_output_dir/kubernetes-node-$platform_src.tar.gz
        local ch_dir="${output_dir}/${platform}"
        local bin_dir="${output_dir}/${platform}/kubernetes/node/bin"
        mkdir -p $bin_dir
        if [ "$platform" == "windows/amd64" ]; then
            for bin in ${KUBE_NODE_BINARIES_WIN[@]}; do
                cp ${bin_root}/${platform}/${bin} $bin_dir
            done
        else
            for bin in ${KUBE_NODE_BINARIES[@]}; do
                cp ${bin_root}/${platform}/${bin} $bin_dir
            done
        fi
        cp -rf $output_dir/LICENSES $ch_dir/kubernetes
        cp $output_dir/ATTRIBUTION.txt $ch_dir/kubernetes
        build::common::create_tarball $tarball $ch_dir kubernetes
        rm -rf $ch_dir
        rmdir $(dirname $ch_dir)
    done

    for platform in "${KUBE_SUPPORTED_CLIENT_PLATFORMS[@]}"; do
        # The substitution on platform_src below will replace all slashes with
        # dashes.  It'll transform darwin/amd64 -> darwin-amd64.
        local platform_src="${platform//\//-}"
        tarball=$tar_output_dir/kubernetes-client-$platform_src.tar.gz
        local ch_dir="${output_dir}/${platform}"
        local bin_dir="${output_dir}/${platform}/kubernetes/client/bin"
        mkdir -p $bin_dir
        if [ "$platform" == "windows/amd64" ]; then
            for bin in ${KUBE_CLIENT_BINARIES_WIN[@]}; do
                cp ${bin_root}/${platform}/${bin} $bin_dir
            done
        else
            for bin in ${KUBE_CLIENT_BINARIES[@]}; do
                cp ${bin_root}/${platform}/${bin} $bin_dir
            done
        fi
        cp -rf $output_dir/LICENSES $ch_dir/kubernetes
        cp $output_dir/ATTRIBUTION.txt $ch_dir/kubernetes
        build::common::create_tarball $tarball $ch_dir kubernetes
        rm -rf $ch_dir
        rmdir $(dirname $ch_dir)
    done
}
