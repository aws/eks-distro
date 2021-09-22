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

BUILD_LIB="${MAKE_ROOT}/../../../build/lib"

readonly KUBE_LINUX_IMAGE_PLATFORMS=(
    amd64
    arm64
)

# Create platform-specific OCI image tars
function build::images::release_image_tar(){
    local -r release_branch="$1"
    local -r base_image="$2"
    local -r repository="$3"
    local -r component="$4"
    local -r image_tag="$5"
    local -r context_dir="$6"
    local -r skip_arm="$7"
    
    for platform in "${KUBE_LINUX_IMAGE_PLATFORMS[@]}"; do
        if [ "$platform" == "arm64" ] && [ $skip_arm == true ]; then
            continue
        fi

        image=${repository}/${component}:${image_tag}
        image_dir=${context_dir}/_output/images/bin/linux/${platform}
        mkdir -p ${image_dir}
        $BUILD_LIB/buildkit.sh \
            build \
            --frontend dockerfile.v0 \
            --opt platform=linux/${platform} \
            --opt build-arg:BASE_IMAGE=${base_image} \
            --opt build-arg:RELEASE_BRANCH=${release_branch} \
            --local dockerfile=./docker/linux \
            --local context=${context_dir} \
            --output type=oci,oci-mediatypes=true,name=${image},dest=${image_dir}/coredns.tar
        echo ${image_tag} > ${image_dir}/coredns.docker_tag
        # TODO: Add `.docker_image_name` upstream so tooling like kops can
        # read the embedded image name
        # https://github.com/kubernetes/kubernetes/blob/73375fbdac6be4b308004cda49174172fa8d740b/build/lib/release.sh#L396
        echo ${image} > ${image_dir}/coredns.docker_image_name
    done
}

function build::images::push(){
    local -r release_branch="$1"
    local -r base_image="$2"
    local -r repository="$3"
    local -r component="$4"
    local -r image_tag="$5"
    local -r context_dir="$6"

    image=${repository}/${component}:${image_tag}
    $BUILD_LIB/buildkit.sh \
        build \
        --frontend dockerfile.v0 \
        --opt platform=linux/amd64,linux/arm64 \
        --opt build-arg:BASE_IMAGE=${base_image} \
        --opt build-arg:RELEASE_BRANCH=${release_branch} \
        --local dockerfile=./docker/linux \
        --local context=${context_dir} \
        --output type=image,oci-mediatypes=true,name=${image},push=true

}
