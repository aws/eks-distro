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

set -o errexit
set -o nounset
set -o pipefail

TAR_FILE_PREFIX="$1"
OUTPUT_BIN_DIR="$2"
TAG="$3"
BINARY_PLATFORMS="$4"

TAR_PATH="_output/tar"
LICENSES_PATH="_output/LICENSES"
ATTRIBUTION_PATH="_output/ATTRIBUTION.txt"


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

    cp -rf $LICENSES_PATH ${OUTPUT_BIN_DIR}/${OS}-${ARCH}/ 
    cp $ATTRIBUTION_PATH ${OUTPUT_BIN_DIR}/${OS}-${ARCH}/ 
    build::common::create_tarball ${TAR_PATH}/${TAR_FILE} ${OUTPUT_BIN_DIR}/${OS}-${ARCH} .
  done
}

build::simple::tarball
