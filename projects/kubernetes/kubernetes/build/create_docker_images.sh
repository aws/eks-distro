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
IMAGE_REPOSITORY="$4"
REPO_PREFIX="$5"
IMAGE_TAG="$6"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

source "${MAKE_ROOT}/build/lib/init.sh"

if [ ! -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin not present!"
    exit 1
fi
IMAGE_TAR_DIR=${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
mkdir -p $IMAGE_TAR_DIR
build::images::docker $RELEASE_BRANCH $GO_RUNNER_IMAGE $KUBE_PROXY_BASE_IMAGE $IMAGE_REPOSITORY $REPO_PREFIX $IMAGE_TAG
