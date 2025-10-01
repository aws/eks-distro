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

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BASE_DIRECTORY="$(cd "${SCRIPT_ROOT}/.." && pwd -P)"
source ${BASE_DIRECTORY}/build/lib/common.sh

PROJECT="${1?First required argument is project}"
SOURCE_ARTIFACT_DIR="${2?Second required argument is source artifact directory}"
RELEASE_BRANCH="${3?Third required argument is release branch for example 1-18}"
RELEASE="${4?Fourth required argument is release for example 1}"
GIT_TAG="${5:-}"

DEST_DIR=${BASE_DIRECTORY}/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts
BUILD_ARTIFACTS=${BUILD_ARTIFACTS:-false}

IS_INTERNAL_BUILD=false
if [[ "${BUILD_ARTIFACTS}" == "false" && "${SOURCE_ARTIFACT_DIR}" == *"kubernetes/kubernetes"* ]]; then
    IS_INTERNAL_BUILD=true
fi

# For when calling from projects other than kubernetes
if [ "$PROJECT" = "kubernetes" ]; then
    if [[ "${IS_INTERNAL_BUILD}" == "true" ]]; then
        echo "using internal build GIT_TAG"
    else
        GIT_TAG=$(cat "${BASE_DIRECTORY}"/projects/kubernetes/kubernetes/"${RELEASE_BRANCH}"/GIT_TAG)
    fi
fi

ARTIFACT_DIR=${DEST_DIR}/${PROJECT}/${GIT_TAG}
mkdir -p $ARTIFACT_DIR
build::common::echo_and_run cp -r $SOURCE_ARTIFACT_DIR/* $ARTIFACT_DIR

# create checksums in source output since we validate artifacts from that folder
build::common::echo_and_run $SCRIPT_ROOT/create_release_checksums.sh $SOURCE_ARTIFACT_DIR
build::common::echo_and_run $SCRIPT_ROOT/create_release_checksums.sh $ARTIFACT_DIR
