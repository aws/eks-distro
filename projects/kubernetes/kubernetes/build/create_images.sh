#!/usr/bin/env bash
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


set -x
set -o errexit
set -o nounset
set -o pipefail

RELEASE_BRANCH="$1"
GO_RUNNER_IMAGE="$2"
KUBE_PROXY_BASE_IMAGE="$3"
REPOSITORY_BASE="$4"
REPO_PREFIX="$5"
IMAGE_TAG="$6"
PAUSE_IMAGE="$7"
PUSH="$8"
SKIP_ARM=${9-false}

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

source "${MAKE_ROOT}/build/lib/init.sh"

if [ ! -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin not present! Run 'make binaries'"
    exit 1
fi
BIN_DIR=${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
if [ "$PUSH" != "true" ]; then
    echo "Placing images under in $BIN_DIR"
    build::images::release_image_tar $RELEASE_BRANCH $GO_RUNNER_IMAGE $KUBE_PROXY_BASE_IMAGE $REPOSITORY_BASE $REPO_PREFIX $IMAGE_TAG $BIN_DIR $SKIP_ARM
    build::images::pause_tar $GO_RUNNER_IMAGE $IMAGE_TAG $PAUSE_IMAGE ${OUTPUT_DIR}/${RELEASE_BRANCH}/pause $BIN_DIR $SKIP_ARM
else
    build::images::push $RELEASE_BRANCH $GO_RUNNER_IMAGE $KUBE_PROXY_BASE_IMAGE $REPOSITORY_BASE $REPO_PREFIX $IMAGE_TAG $BIN_DIR
    build::images::pause_push $GO_RUNNER_IMAGE $IMAGE_TAG $PAUSE_IMAGE ${OUTPUT_DIR}/${RELEASE_BRANCH}/pause 
fi

