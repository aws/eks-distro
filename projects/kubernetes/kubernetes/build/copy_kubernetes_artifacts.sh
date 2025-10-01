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

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${ARTIFACT_DIR}"
mkdir -p "${IMAGE_OUTPUT_DIR}/amd64" "${IMAGE_OUTPUT_DIR}/arm64"

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
for IMAGE_NAME in "kube-apiserver" "kube-controller-manager" "kube-scheduler" "pause"; do
    SOURCE_IMAGE="${SOURCE_ECR_REG}/kubernetes/${IMAGE_NAME}:${EKS_VERSION}"
    IMAGE_TAG="${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}"
    DEST_IMAGE="${IMAGE_REPO}/kubernetes/${IMAGE_NAME}:${IMAGE_TAG}"

    echo "Copying ${SOURCE_IMAGE}-linux_amd64 to ${DEST_IMAGE}-linux_amd64"
    "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
      --frontend dockerfile.v0 \
      --opt build-arg:SOURCE_IMAGE="${SOURCE_IMAGE}-linux_amd64" \
      --opt platform=linux/amd64 \
      --local dockerfile=docker/retag \
      --local context=. \
      --output type=image,name="${DEST_IMAGE}-linux_amd64",push=true

    echo "Copying ${SOURCE_IMAGE}-linux_arm64 to ${DEST_IMAGE}-linux_arm64"
    "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
      --frontend dockerfile.v0 \
      --opt build-arg:SOURCE_IMAGE="${SOURCE_IMAGE}-linux_arm64" \
      --opt platform=linux/arm64 \
      --local dockerfile=docker/retag \
      --local context=. \
      --output type=image,name="${DEST_IMAGE}-linux_arm64",push=true

    echo "Creating multi-arch image ${DEST_IMAGE}"
    TAGS=("${DEST_IMAGE}")
    OUTPUT_TYPE=docker
    if [[ "$IMAGE_NAME" == "pause" ]]; then
        PAUSE_TAG=$(cat "${RELEASE_BRANCH}/PAUSE_TAG" | xargs)
        TAGS+=("${IMAGE_REPO}/kubernetes/${IMAGE_NAME}:${PAUSE_TAG}")
        OUTPUT_TYPE=oci
    fi
    
    docker buildx imagetools create \
        $(printf -- "--tag %s " "${TAGS[@]}") \
        "${DEST_IMAGE}-linux_amd64" \
        "${DEST_IMAGE}-linux_arm64"

    EXPORT_TAGS=$(IFS=,; echo "${TAGS[*]}")
    for ARCH in amd64 arm64; do
        mkdir -p "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/"

        echo "${IMAGE_TAG}" > "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/${IMAGE_NAME}.docker_tag"
        echo "${EXPORT_TAGS}" > "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/${IMAGE_NAME}.docker_image_name"

        "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
          --frontend dockerfile.v0 \
          --opt build-arg:SOURCE_IMAGE="${DEST_IMAGE}" \
          --local dockerfile=docker/retag \
          --local context=. \
          --opt platform=linux/${ARCH} \
          --output type="${OUTPUT_TYPE}",oci-mediatypes=true,\"name="${EXPORT_TAGS}"\",dest="${IMAGE_OUTPUT_DIR}/linux/${ARCH}/${IMAGE_NAME}.tar"
    done
done

get_kube_proxy_tag() {
    case "$1" in
        "1-28") echo "v1.28.15" ;;
        "1-29") echo "v1.29.15" ;;
        "1-30") echo "v1.30.14" ;;
        "1-31") echo "v1.31.10" ;;
        "1-32") echo "v1.32.6" ;;
        "1-33") echo "v1.33.3" ;;
        "1-34") echo "v1.34.0" ;;
        *) echo "$GIT_TAG" ;;
    esac
}

# temporarily handle kube-proxy separately until full deprecation
KUBE_PROXY_GIT_TAG=$(get_kube_proxy_tag "$RELEASE_BRANCH")
mkdir -p "${RELEASE_BRANCH}/kube-proxy/"
echo "${KUBE_PROXY_GIT_TAG}" > "${RELEASE_BRANCH}/kube-proxy/GIT_TAG"
SOURCE_IMAGE="${SOURCE_ECR_REG}/kubernetes/kube-proxy:${KUBE_PROXY_GIT_TAG}-eks-abcdef1"
IMAGE_TAG="${KUBE_PROXY_GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}"
DEST_IMAGE="${IMAGE_REPO}/kubernetes/kube-proxy:${IMAGE_TAG}"

echo "Building ${DEST_IMAGE}-linux_amd64 with BuildKit"
"$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
    --frontend dockerfile.v0 \
    --opt platform=linux/amd64 \
    --opt build-arg:SOURCE_IMAGE="${SOURCE_IMAGE}-linux_amd64" \
    --opt build-arg:GO_RUNNER_IMAGE="${GO_RUNNER_IMAGE}" \
    --local dockerfile=docker/kube-proxy \
    --local context=. \
    --output type=image,name="${DEST_IMAGE}-linux_amd64",push=true

echo "Building ${DEST_IMAGE}-linux_arm64 with BuildKit"
"$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
    --frontend dockerfile.v0 \
    --opt platform=linux/arm64 \
    --opt build-arg:SOURCE_IMAGE="${SOURCE_IMAGE}-linux_arm64" \
    --opt build-arg:GO_RUNNER_IMAGE="${GO_RUNNER_IMAGE}" \
    --local dockerfile=docker/kube-proxy \
    --local context=. \
    --output type=image,name="${DEST_IMAGE}-linux_arm64",push=true

echo "Creating multi-arch image ${DEST_IMAGE}"
docker buildx imagetools create --tag "${DEST_IMAGE}" \
    "${DEST_IMAGE}-linux_amd64" \
    "${DEST_IMAGE}-linux_arm64"

for ARCH in amd64 arm64; do
    echo "${IMAGE_TAG}" > "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/kube-proxy.docker_tag"
    echo "${DEST_IMAGE}" > "${IMAGE_OUTPUT_DIR}/linux/${ARCH}/kube-proxy.docker_image_name"

    "$(git rev-parse --show-toplevel)/build/lib/buildkit.sh" build \
        --frontend dockerfile.v0 \
        --opt build-arg:SOURCE_IMAGE="${DEST_IMAGE}" \
        --local dockerfile=docker/retag \
        --local context=. \
        --opt platform=linux/${ARCH} \
        --output type=docker,oci-mediatypes=true,\"name="${DEST_IMAGE}"\",dest="${IMAGE_OUTPUT_DIR}/linux/${ARCH}/kube-proxy.tar"
done

# create tarballs with newly tagged images and binaries
cp "${OUTPUT_DIR}/tar/kubernetes-src.tar.gz" "${ARTIFACT_DIR}"
build::tarballs::create_tarballs "${BIN_OUTPUT_DIR}" "${OUTPUT_DIR}" "${ARTIFACT_DIR}" "${IMAGE_OUTPUT_DIR}"

# update files for any legacy method callers of these files during the build e.g., crd generation
cp "${OUTPUT_DIR}/KUBE_GIT_VERSION_FILE" "${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"
echo "${GIT_TAG}" > "${RELEASE_BRANCH}/GIT_TAG"
echo "${GOLANG_VERSION%.*}" > "${RELEASE_BRANCH}/GOLANG_VERSION"
cp "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" "${RELEASE_BRANCH}"

# Copy go.mod and go.sum files with fallback
if [[ -f "${OUTPUT_DIR}/go.mod" && -f "${OUTPUT_DIR}/go.sum" ]]; then
    cp "${OUTPUT_DIR}/go.mod" "${RELEASE_BRANCH}/go.mod"
    cp "${OUTPUT_DIR}/go.sum" "${RELEASE_BRANCH}/go.sum"
else
    TEMP_DIR=$(mktemp -d)
    tar -xzf "${ARTIFACT_DIR}/kubernetes-src.tar.gz" -C "${TEMP_DIR}"
    cp "${TEMP_DIR}/go.mod" "${RELEASE_BRANCH}/go.mod"
    cp "${TEMP_DIR}/go.sum" "${RELEASE_BRANCH}/go.sum"
    rm -rf "${TEMP_DIR}"
fi