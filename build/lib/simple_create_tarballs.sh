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

TAR_FILE_PREFIX="$1"
OUTPUT_DIR="$2"
OUTPUT_BIN_DIR="$3"
TAG="$4"
BINARY_PLATFORMS="$5"
TAR_PATH="$6"

LICENSES_PATH=$(find $OUTPUT_DIR -maxdepth 3 -name LICENSES)
ATTRIBUTION_PATH=$(find $OUTPUT_DIR -maxdepth 1 -name "*ATTRIBUTION.txt")

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

function build::simple::tarball() {
  build::common::ensure_tar
  mkdir -p "$TAR_PATH"
  SUPPORTED_PLATFORMS=(${BINARY_PLATFORMS// / })
  for platform in "${SUPPORTED_PLATFORMS[@]}"; do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    TAR_FILE="${TAR_FILE_PREFIX}-${OS}-${ARCH}-${TAG}.tar.gz"

    build::common::echo_and_run cp -rf $LICENSES_PATH ${OUTPUT_BIN_DIR}/${OS}-${ARCH}/ 
    build::common::echo_and_run cp $ATTRIBUTION_PATH ${OUTPUT_BIN_DIR}/${OS}-${ARCH}/ 
    build::common::create_tarball ${TAR_PATH}/${TAR_FILE} ${OUTPUT_BIN_DIR}/${OS}-${ARCH} .
  done
}

build::simple::tarball
