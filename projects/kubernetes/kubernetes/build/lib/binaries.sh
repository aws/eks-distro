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

    # ensure consistent build date tag on final binary based on
    # last change in the patches directory
    export SOURCE_DATE_EPOCH=$(git -C $repository log -1 --format=%at)
    export KUBE_GIT_COMMIT=$(git -C $repository rev-list -n 1 $git_tag)
    export KUBE_GIT_TREE_STATE=clean
    # Not using full image tag to avoid having to change checksums just for bumping
    # the release number, which is usually just a base image update and
    # doesnt affect the binaries
    export KUBE_GIT_VERSION=$git_tag-eks-$release_branch

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

    make generated_files

    # Linux
    export KUBE_BUILD_PLATFORMS="linux/amd64 linux/arm64"
	hack/make-rules/build.sh -trimpath cmd/kubelet \
        cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl \
        cmd/kube-apiserver \
        cmd/kube-controller-manager \
        cmd/kube-scheduler

    # In presubmit builds space is very limited
    rm -rf ./_output/local/go/cache
    
    # Windows
    export KUBE_BUILD_PLATFORMS="windows/amd64"
    hack/make-rules/build.sh -trimpath cmd/kubelet \
    	cmd/kube-proxy \
        cmd/kubeadm \
        cmd/kubectl

    # Darwin
    export KUBE_BUILD_PLATFORMS="darwin/amd64" 
    hack/make-rules/build.sh -trimpath cmd/kubectl

    # In presubmit builds space is very limited
    rm -rf ./_output/local/go/cache
	
    cd ..
}
