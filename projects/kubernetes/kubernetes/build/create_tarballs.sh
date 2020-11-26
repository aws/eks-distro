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

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
GIT_TAG="$(cat ${MAKE_ROOT}/${RELEASE_BRANCH}/GIT_TAG)"

source "${MAKE_ROOT}/../../../build/lib/common.sh"
source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/build/lib/tarballs.sh"

if [ ! -d ${OUTPUT_DIR}/${RELEASE_BRANCH} ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH} not present!"
    exit 1
fi
mkdir -p ${OUTPUT_DIR}/${RELEASE_BRANCH}
build::common::ensure_tar
build::tarballs::create_tarballs "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin" "${OUTPUT_DIR}/${RELEASE_BRANCH}"
git \
    -C $SOURCE_DIR \
    archive \
    --format=tar.gz \
    --output=${OUTPUT_DIR}/${RELEASE_BRANCH}/kubernetes-src.tar.gz \
    HEAD
