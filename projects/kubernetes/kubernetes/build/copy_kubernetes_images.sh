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

for IMAGE_NAME in "kube-apiserver" "kube-controller-manager" "kube-proxy" "kube-scheduler" "pause"; do
    SOURCE_IMAGE="${SOURCE_ECR_REG}/kubernetes/${IMAGE_NAME}:${EKS_VERSION}"
    DEST_IMAGE="${IMAGE_REPO}/kubernetes/${IMAGE_NAME}:${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}"

    echo "Copying ${SOURCE_IMAGE}-linux_amd64 to ${DEST_IMAGE}-linux_amd64"
    docker buildx imagetools create --tag "${DEST_IMAGE}-linux_amd64" "${SOURCE_IMAGE}-linux_amd64"

    echo "Copying ${SOURCE_IMAGE}-linux_arm64 to ${DEST_IMAGE}-linux_arm64"
    docker buildx imagetools create --tag "${DEST_IMAGE}-linux_arm64" "${SOURCE_IMAGE}-linux_arm64"

    echo "Creating multi-arch image ${DEST_IMAGE}"
    docker buildx imagetools create --tag "${DEST_IMAGE}" \
        "${DEST_IMAGE}-linux_amd64" \
        "${DEST_IMAGE}-linux_arm64"
done
