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

#/usr/bin/env bash

readonly KUBE_LINUX_IMAGE_PLATFORMS=(
    amd64
    arm64
)
readonly KUBE_IMAGE_BINARIES=(
    kube-apiserver
    kube-controller-manager
    kube-scheduler
    kube-proxy
)

# Create platform-specific OCI image tars
function build::images::release_image_tar(){
    local -r release_branch="$1"
    local -r go_runner_image="$2"
    local -r kube_proxy_base_image="$3"
    local -r repository="$4"
    local -r repo_prefix="$5"
    local -r image_tag="$6"
    local -r context_dir="$7"

    for binary in "${KUBE_IMAGE_BINARIES[@]}"; do
        local base_image=$go_runner_image
        if [ "$binary" == "kube-proxy" ]; then
            base_image=$kube_proxy_base_image
        fi
        for platform in "${KUBE_LINUX_IMAGE_PLATFORMS[@]}"; do
            image=${repository}/${repo_prefix}/${binary}:${image_tag}
            image_dir=${context_dir}/linux/${platform}
            buildctl \
                build \
                --frontend dockerfile.v0 \
                --opt platform=linux/${platform} \
                --opt build-arg:BASE_IMAGE=${base_image} \
                --opt build-arg:BINARY=${binary} \
                --opt build-arg:RELEASE_BRANCH=${release_branch} \
                --local dockerfile=./docker/ \
                --local context=${context_dir} \
                --output type=oci,oci-mediatypes=true,name=${image},dest=${image_dir}/${binary}.tar
            echo ${image_tag} > ${image_dir}/${binary}.docker_tag
            # TODO: Add `.docker_image_name` upstream so tooling like kops can
            # read the embedded image name
            # https://github.com/kubernetes/kubernetes/blob/73375fbdac6be4b308004cda49174172fa8d740b/build/lib/release.sh#L396
            echo ${image} > ${image_dir}/${binary}.docker_image_name
        done
    done
}

function build::images::push(){
    local -r release_branch="$1"
    local -r go_runner_image="$2"
    local -r kube_proxy_base_image="$3"
    local -r repository="$4"
    local -r repo_prefix="$5"
    local -r image_tag="$6"
    local -r context_dir="$7"

    for binary in "${KUBE_IMAGE_BINARIES[@]}"; do
        local base_image=$go_runner_image
        if [ "$binary" == "kube-proxy" ]; then
            base_image=$kube_proxy_base_image
        fi
        image=${repository}/${repo_prefix}/${binary}:${image_tag}
        buildctl \
            build \
            --frontend dockerfile.v0 \
            --opt platform=linux/amd64,linux/arm64 \
            --opt build-arg:BASE_IMAGE=${base_image} \
            --opt build-arg:BINARY=${binary} \
            --opt build-arg:RELEASE_BRANCH=${release_branch} \
            --local dockerfile=./docker/ \
            --local context=${context_dir} \
            --output type=image,oci-mediatypes=true,name=${image},push=true
    done
}

# We use a separate Dockerfile for docker builds to reduce the context size uploaded
# to the docker daemon. This reduces the size to ~488MB as opposed to ~11GB
function build::images::docker(){
    local -r release_branch="$1"
    local -r go_runner_image="$2"
    local -r kube_proxy_base_image="$3"
    local -r repository="$4"
    local -r repo_prefix="$5"
    local -r image_tag="$6"

    for binary in "${KUBE_IMAGE_BINARIES[@]}"; do
        local base_image=$go_runner_image
        if [ "$binary" == "kube-proxy" ]; then
            base_image=$kube_proxy_base_image
        fi
        docker \
            build \
            --build-arg BASE_IMAGE=${base_image} \
            --build-arg TARGETARCH=amd64 \
            --build-arg TARGETOS=linux \
            --build-arg BINARY=${binary} \
            --build-arg RELEASE_BRANCH=$release_branch \
            -t ${repository}/${repo_prefix}/${binary}:${image_tag} \
            -f ./docker/Dockerfile  ./_output/${release_branch}/bin/
    done
}

function build::images::docker::push(){
    local -r release_branch="$1"
    local -r go_runner_image="$2"
    local -r kube_proxy_base_image="$3"
    local -r repository="$4"
    local -r repo_prefix="$5"
    local -r image_tag="$6"

    for binary in "${KUBE_IMAGE_BINARIES[@]}"; do
        local base_image=$go_runner_image
        if [ "$binary" == "kube-proxy" ]; then
            base_image=$kube_proxy_base_image
        fi
        docker push ${repository}/${repo_prefix}/${binary}:${image_tag}
    done
}

# Create platform-specific OCI image tars
function build::images::pause_tar(){
    local -r go_runner_image="$1"
    local -r version="$2"
    local -r image_tag="$3"
    local -r context_dir="$4"
    local -r bin_dir="$5"

    for platform in "${KUBE_LINUX_IMAGE_PLATFORMS[@]}"; do
        buildctl \
            build \
            --frontend dockerfile.v0 \
            --opt platform=linux/${platform} \
            --local dockerfile=./docker/pause/ \
            --local context=${context_dir} \
            --opt build-arg:BASE_IMAGE=${go_runner_image} \
            --opt build-arg:VERSION=${version} \
            --output type=oci,oci-mediatypes=true,\"name=${image_tag}\",dest=${bin_dir}/linux/${platform}/pause.tar
    done
}

# Create platform-specific OCI image tars
function build::images::pause_push(){
    local -r go_runner_image="$1"
    local -r version="$2"
    local -r image_tag="$3"
    local -r context_dir="$4"

    for platform in "${KUBE_LINUX_IMAGE_PLATFORMS[@]}"; do
        buildctl \
            build \
            --frontend dockerfile.v0 \
            --opt platform=linux/${platform} \
            --local dockerfile=./docker/pause/ \
            --local context=${context_dir} \
            --opt build-arg:BASE_IMAGE=${go_runner_image} \
            --opt build-arg:VERSION=${version} \
            --output type=image,oci-mediatypes=true,\"name=${image_tag}\",push=true
    done
}
