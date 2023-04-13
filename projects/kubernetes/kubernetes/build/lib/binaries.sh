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

function build::binaries::kube_bins() {
  local -r repository="$1"
  local -r release_branch="$2"
  local -r git_tag="$3"
  local -r kube_git_version_file="$4"

  export KUBE_GIT_VERSION_FILE=$kube_git_version_file

    cd $repository


    # Ideally, to avoid checksum differences due to modules being downloaded by go mod download vs
    # vendored in the vendor directly, which really only comes into play when build locally vs in a clean
    # builder-base, we would run `./hack/update-vendor.sh` to redownload all the modules avoiding this difference
    # We do this for all projects, however, with kubernetes we actually patch some files in vendor
    # so if we ran this it would overwrite our patched changes
    # TODO: potentially look at ways to run this but reset back to patches after downloads?
    # or once we are using go 1.15, using the seperate cache dirs like we do could help?
    # ./hack/update-vendor.sh

    # Build all core components for linux arm64 and amd64
    # GOLDFLASGS
    # * strip symbol, debug, and DWARF tables
    # * set an empty build id for reproducibility
    # * build static binaries
    # Run in two steps to support passing -trimpath
    export CGO_ENABLED=0
    export GOLDFLAGS='-s -w -buildid=""'
    export KUBE_STATIC_OVERRIDES="cmd/kubelet \
        cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl \
        cmd/kube-apiserver \
        cmd/kube-controller-manager \
        cmd/kube-scheduler"

  # For Kubernetes 1.23 and older, removing `make generated_files` results in this error:
  # cmd/kube-apiserver/app/server.go:401:80: undefined: "k8s.io/kubernetes/pkg/generated/openapi".GetOpenAPIDefinitions
  #
  # This block should be removes when 1.23 is no longer supported.
  local -r minor_version=${release_branch: -2}
  if [[ $minor_version -le 23 ]]; then
    make generated_files
  fi

    # Linux
    export KUBE_BUILD_PLATFORMS="linux/amd64 linux/arm64"
    hack/make-rules/build.sh -trimpath cmd/kubelet \
          cmd/kube-proxy \
          cmd/kubeadm \
          cmd/kubectl

    # In presubmit builds space is very limited so build is split
    rm -rf ./_output/local/go/cache

    hack/make-rules/build.sh -trimpath cmd/kube-apiserver \
          cmd/kube-controller-manager \
          cmd/kube-scheduler

    # In presubmit builds space is very limited
    rm -rf ./_output/local/go/cache

    # Windows
    export KUBE_BUILD_PLATFORMS="windows/amd64"
    hack/make-rules/build.sh -trimpath cmd/kubelet \
    	cmd/kube-proxy

    # In presubmit builds space is very limited so build is split
    rm -rf ./_output/local/go/cache
    hack/make-rules/build.sh -trimpath cmd/kubeadm \
        cmd/kubectl

    # In presubmit builds space is very limited
    rm -rf ./_output/local/go/cache

    # Darwin
    export KUBE_BUILD_PLATFORMS="darwin/amd64"
    hack/make-rules/build.sh -trimpath cmd/kubectl

    # In presubmit builds space is very limited
    rm -rf ./_output/local/go/cache

    cd ..
}
