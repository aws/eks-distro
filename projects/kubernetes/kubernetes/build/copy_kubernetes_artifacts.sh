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

mkdir -p "_output/${RELEASE_BRANCH}/"
echo "${KUBERNETES_ARTIFACTS_SOURCE_S3_RELEASE_PATH}"
echo "_output/${RELEASE_BRANCH}/"
aws s3 sync "${KUBERNETES_ARTIFACTS_SOURCE_S3_RELEASE_PATH}" "_output/${RELEASE_BRANCH}" --quiet

ARTIFACT_DIR="_output/tar/${RELEASE_BRANCH}"
mkdir -p ${ARTIFACT_DIR}
echo "Copying tarballs"
cp -r "_output/${RELEASE_BRANCH}/tar/"* "${ARTIFACT_DIR}"
echo "Copying checksums"
cp "_output/${RELEASE_BRANCH}/SHA"* "${ARTIFACT_DIR}"
cp "_output/${RELEASE_BRANCH}/SHA"* "_output/${RELEASE_BRANCH}/images/"

PROJECT_ROOT=$(cat "_output/${RELEASE_BRANCH}/attribution/root-module.txt")
MAKE_ROOT="$(git rev-parse --show-toplevel)/projects/kubernetes/kubernetes/${RELEASE_BRANCH}"
generate-attribution "${PROJECT_ROOT}" "${MAKE_ROOT}" "go${GOLANG_VERSION}" "_output/${RELEASE_BRANCH}" "${GIT_TAG}" 2>&1
echo "Copying attribution"
cp "_output/${RELEASE_BRANCH}/attribution/ATTRIBUTION.txt" "${ARTIFACT_DIR}"

IMAGE_OUTPUT_DIR="_output/${RELEASE_BRANCH}/images/bin"
for IMAGE_NAME in "kube-apiserver" "kube-controller-manager" "kube-proxy" "kube-scheduler" "pause"; do
    IMAGE_TAG="${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}"
    IMAGE="${IMAGE_REPO}/kubernetes/${IMAGE_NAME}:${IMAGE_TAG}"
    
    for ARCH in "linux/amd64" "linux/arm64"; do
        mkdir -p "${IMAGE_OUTPUT_DIR}/${ARCH}/"
        echo "${IMAGE_TAG}" > "${IMAGE_OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.docker_tag"
        echo "${IMAGE}" > "${IMAGE_OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.docker_image_name"
    done
done

# update files for any legacy method callers of these files during the build e.g., crd generation
cp "_output/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE" "${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"
echo "${GIT_TAG}" > "${RELEASE_BRANCH}/GIT_TAG"
echo "${GOLANG_VERSION%.*}" > "${RELEASE_BRANCH}/GOLANG_VERSION"
cp "_output/${RELEASE_BRANCH}/attribution/ATTRIBUTION.txt" "${RELEASE_BRANCH}"

# Copy go.mod and go.sum files with fallback
if [[ -f "_output/${RELEASE_BRANCH}/go.mod" && -f "_output/${RELEASE_BRANCH}/go.sum" ]]; then
    cp "_output/${RELEASE_BRANCH}/go.mod" "${RELEASE_BRANCH}/go.mod"
    cp "_output/${RELEASE_BRANCH}/go.sum" "${RELEASE_BRANCH}/go.sum"
else
    TEMP_DIR=$(mktemp -d)
    tar -xzf "${ARTIFACT_DIR}/kubernetes-src.tar.gz" -C "${TEMP_DIR}"
    cp "${TEMP_DIR}/go.mod" "${RELEASE_BRANCH}/go.mod"
    cp "${TEMP_DIR}/go.sum" "${RELEASE_BRANCH}/go.sum"
    rm -rf "${TEMP_DIR}"
fi