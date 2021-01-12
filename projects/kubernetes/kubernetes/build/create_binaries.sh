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

CLONE_URL="$1"
RELEASE_BRANCH="$2"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

GIT_TAG="$(cat ${MAKE_ROOT}/${RELEASE_BRANCH}/GIT_TAG)"
RELEASE_FILE="${MAKE_ROOT}/${RELEASE_BRANCH}/RELEASE"
PATCH_DIR=${MAKE_ROOT}/${RELEASE_BRANCH}/patches
export KUBE_GIT_VERSION=$(build::version::kube_git_version $GIT_TAG $RELEASE_FILE $RELEASE_BRANCH)
if [ -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin already exists. Run 'make clean' before rebuilding"
    exit 0
fi
build::git::clone "$CLONE_URL" "$SOURCE_DIR"
build::git::patch "$SOURCE_DIR" "$GIT_TAG" "$PATCH_DIR"
build::binaries::kube_bins "$SOURCE_DIR"

mkdir -p ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
cp -r ${SOURCE_DIR}/_output/local/bin/* ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin

(cd $REPOSITORY && build::gather_licenses ./ ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin/LICENSES)
cp $MAKE_ROOT/ATTRIBUTION.txt ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
