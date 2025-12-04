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
set -eux

source "${MAKE_ROOT}/build/lib/tarballs.sh"

OUTPUT_DIR="_output/${RELEASE_BRANCH}"
BIN_OUTPUT_DIR="${OUTPUT_DIR}/bin"
IMAGE_OUTPUT_DIR="${OUTPUT_DIR}/images/bin"
ARTIFACT_DIR="_output/tar/${RELEASE_BRANCH}"
ARCHITECTURES=("amd64" "arm64")

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${ARTIFACT_DIR}"
mkdir -p "${IMAGE_OUTPUT_DIR}/amd64" "${IMAGE_OUTPUT_DIR}/arm64"

retag_and_push_image() {
    local source_image=$1
    local dest_image=$2
    local arch=$3

    if [[ "${source_image}" == *"kube-proxy"* ]]; then
        "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
            --frontend dockerfile.v0 \
            --opt build-arg:SOURCE_IMAGE="${source_image}-linux_${arch}" \
            --opt build-arg:GO_RUNNER_IMAGE="${GO_RUNNER_IMAGE}" \
            --opt platform=linux/${arch} \
            --local dockerfile=docker/kube-proxy \
            --local context=. \
            --output type=image,name="${dest_image}-linux_${arch}",push="${PUSH_IMAGES}"
    else
        "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
            --frontend dockerfile.v0 \
            --opt build-arg:SOURCE_IMAGE="${source_image}-linux_${arch}" \
            --opt platform=linux/${arch} \
            --local dockerfile=docker/retag \
            --local context=. \
            --output type=image,name="${dest_image}-linux_${arch}",push="${PUSH_IMAGES}"
    fi
}

export_image_tar() {
    local dest_image=$1
    local arch=$2
    local image_name=$3
    local output_type=${4:-docker}
    local tags=$5
    
    if [[ "${image_name}" == *"kube-proxy"* ]]; then
        "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
            --frontend dockerfile.v0 \
            --opt build-arg:SOURCE_IMAGE="${dest_image}" \
            --opt build-arg:GO_RUNNER_IMAGE="${GO_RUNNER_IMAGE}" \
            --local dockerfile=docker/kube-proxy \
            --local context=. \
            --opt platform=linux/${arch} \
            --output type="${output_type}",oci-mediatypes=true,\"name="${tags}"\",dest="${IMAGE_OUTPUT_DIR}/linux/${arch}/${image_name}.tar"
    else
        "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
            --frontend dockerfile.v0 \
            --opt build-arg:SOURCE_IMAGE="${dest_image}" \
            --local dockerfile=docker/retag \
            --local context=. \
            --opt platform=linux/${arch} \
            --output type="${output_type}",oci-mediatypes=true,\"name="${tags}"\",dest="${IMAGE_OUTPUT_DIR}/linux/${arch}/${image_name}.tar"
    fi
}

process_architectures() {
    local dest_image=$1
    local image_name=$2
    local image_tag=$3
    local export_tags=$4
    local output_type=${5:-docker}
    
    for ARCH in "${ARCHITECTURES[@]}"; do
        mkdir -p "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/"
        echo "${image_tag}" > "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/${image_name}.docker_tag"
        echo "${export_tags}" > "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/${image_name}.docker_image_name"
        export_image_tar "${dest_image}" "${ARCH}" "${image_name}" "${output_type}" "${export_tags}"
    done
}

aws s3 sync "${KUBERNETES_ARTIFACTS_SOURCE_S3_RELEASE_PATH}" "${OUTPUT_DIR}" \
  --exclude "*.sha*" \
  --exclude "*SHA*" \
  --quiet

if [[ ! -f "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" ]]; then
    PROJECT_ROOT=$(cat "${OUTPUT_DIR}/attribution/root-module.txt")
    RELEASE_BRANCH_ROOT="$(git rev-parse --show-toplevel)/projects/kubernetes/kubernetes/${RELEASE_BRANCH}"
    generate-attribution "${PROJECT_ROOT}" "${RELEASE_BRANCH_ROOT}" "go${GOLANG_VERSION}" "${OUTPUT_DIR}" "${GIT_TAG}" 2>&1
fi
echo "Copying attribution"
cp "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" "${ARTIFACT_DIR}"
cp "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" "${OUTPUT_DIR}"

echo "Retagging images"
for IMAGE_NAME in "kube-apiserver" "kube-controller-manager" "kube-scheduler" "kube-proxy" "pause"; do
    SOURCE_IMAGE="${SOURCE_ECR_REG}/kubernetes/${IMAGE_NAME}:${EKS_VERSION}"
    IMAGE_TAG="${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}"
    DEST_IMAGE="${IMAGE_REPO}/kubernetes/${IMAGE_NAME}:${IMAGE_TAG}"

    for ARCH in "${ARCHITECTURES[@]}"; do
        echo "Copying ${SOURCE_IMAGE}-linux_${ARCH} to ${DEST_IMAGE}-linux_${ARCH}"
        retag_and_push_image "${SOURCE_IMAGE}" "${DEST_IMAGE}" "${ARCH}"
    done

    echo "Creating multi-arch image ${DEST_IMAGE}"
    TAGS=("${DEST_IMAGE}")
    OUTPUT_TYPE=docker
    if [[ "$IMAGE_NAME" == "pause" ]]; then
        PAUSE_TAG=$(cat "${RELEASE_BRANCH}/PAUSE_TAG" | xargs)
        TAGS+=("${IMAGE_REPO}/kubernetes/${IMAGE_NAME}:${PAUSE_TAG}")
        OUTPUT_TYPE=oci
    fi
    
    if [[ "${PUSH_IMAGES}" == "true" ]]; then
        docker buildx imagetools create \
            $(printf -- "--tag %s " "${TAGS[@]}") \
            "${DEST_IMAGE}-linux_amd64" \
            "${DEST_IMAGE}-linux_arm64"
    fi

    EXPORT_TAGS=$(IFS=,; echo "${TAGS[*]}")
    process_architectures "${DEST_IMAGE}" "${IMAGE_NAME}" "${IMAGE_TAG}" "${EXPORT_TAGS}" "${OUTPUT_TYPE}"
done

# create tarballs with newly tagged images and binaries
cp "${OUTPUT_DIR}/tar/kubernetes-src.tar.gz" "${ARTIFACT_DIR}"
chmod -R 755 "${BIN_OUTPUT_DIR}"
build::tarballs::create_tarballs "${BIN_OUTPUT_DIR}" "${OUTPUT_DIR}" "${ARTIFACT_DIR}" "${IMAGE_OUTPUT_DIR}"

# update files for any legacy method callers of these files during the build e.g., crd generation, attribution periodic
cp "${OUTPUT_DIR}/KUBE_GIT_VERSION_FILE" "${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"
echo "${GIT_TAG}" > "${RELEASE_BRANCH}/GIT_TAG"
echo "${GIT_TAG}" > "${RELEASE_BRANCH}/kube-proxy/GIT_TAG"
echo "${GOLANG_VERSION%.*}" > "${RELEASE_BRANCH}/GOLANG_VERSION"
cp "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" "${RELEASE_BRANCH}"