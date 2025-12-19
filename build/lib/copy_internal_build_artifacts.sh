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

ROOT_DIR="$(git rev-parse --show-toplevel)"
OUTPUT_DIR="_output/${RELEASE_BRANCH}"
BIN_OUTPUT_DIR="${OUTPUT_DIR}/bin"
IMAGE_ARCHITECTURES=("amd64" "arm64")

mkdir -p "${OUTPUT_DIR}"

retag_and_push_image() {
    local source_image=$1
    local dest_image=$2
    local arch=$3

    "${ROOT_DIR}/build/lib/buildkit.sh" build \
        --frontend dockerfile.v0 \
        --opt build-arg:SOURCE_IMAGE="${source_image}-linux_${arch}" \
        --opt platform=linux/${arch} \
        --local dockerfile="${ROOT_DIR}/build/lib/docker/retag" \
        --local context=. \
        --output type=image,name="${dest_image}-linux_${arch}",push="${PUSH_IMAGES}"
}

aws s3 sync "${ARTIFACTS_SOURCE_S3_PATH}" "${OUTPUT_DIR}" --quiet

echo "Reorganizing binaries to expected structure"
# S3 structure: bin/linux/amd64/aws-iam-authenticator
# Expected: bin/aws-iam-authenticator/linux-amd64/aws-iam-authenticator
if [ -d "${OUTPUT_DIR}/bin" ]; then
    TEMP_BIN_DIR="${OUTPUT_DIR}/bin_temp"
    mkdir -p "${TEMP_BIN_DIR}"
    
    # Move binaries to temp location with correct structure
    for platform_dir in "${OUTPUT_DIR}/bin"/*/*; do
        if [ -d "${platform_dir}" ]; then
            os=$(basename $(dirname "${platform_dir}"))
            arch=$(basename "${platform_dir}")
            for binary in "${platform_dir}"/*; do
                if [ -f "${binary}" ]; then
                    binary_name=$(basename "${binary}")
                    # Remove .exe extension for directory name
                    binary_base="${binary_name%.exe}"
                    mkdir -p "${TEMP_BIN_DIR}/${binary_base}/${os}-${arch}"
                    cp -p "${binary}" "${TEMP_BIN_DIR}/${binary_base}/${os}-${arch}/${binary_name}"
                fi
            done
        fi
    done
    
    # Replace old bin directory with new structure
    rm -rf "${OUTPUT_DIR}/bin"
    mv "${TEMP_BIN_DIR}" "${OUTPUT_DIR}/bin"
fi

echo "Copying attribution"
cp "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" "${OUTPUT_DIR}"

echo "Retagging images"
for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
    SOURCE_IMAGE="${SOURCE_ECR_REG}/${IMAGE_NAME}:${GIT_TAG}"
    IMAGE_TAG="${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}"
    DEST_IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

    for ARCH in "${IMAGE_ARCHITECTURES[@]}"; do
        echo "Copying ${SOURCE_IMAGE}-linux_${ARCH} to ${DEST_IMAGE}-linux_${ARCH}"
        retag_and_push_image "${SOURCE_IMAGE}" "${DEST_IMAGE}" "${ARCH}"
    done

    echo "Creating multi-arch image ${DEST_IMAGE}"
    TAGS=("${DEST_IMAGE}")
    OUTPUT_TYPE=oci

    if [[ "${PUSH_IMAGES}" == "true" ]]; then
        docker buildx imagetools create \
            $(printf -- "--tag %s " "${TAGS[@]}") \
            "${DEST_IMAGE}-linux_amd64" \
            "${DEST_IMAGE}-linux_arm64"
    fi
done

chmod -R 755 "${BIN_OUTPUT_DIR}"

# update files for any legacy method callers of these files during the build e.g., crd generation, attribution periodic
echo "${GIT_TAG}" > "${RELEASE_BRANCH}/GIT_TAG"
echo "${GOLANG_VERSION%.*}" > "${RELEASE_BRANCH}/GOLANG_VERSION"
cp "${OUTPUT_DIR}/attribution/ATTRIBUTION.txt" "${RELEASE_BRANCH}"
