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

REPO="$1"
TAG="$2"
TAR_PATH="_output/tar"
BIN_ROOT="_output/bin"
readonly SUPPORTED_PLATFORMS=(
  linux/amd64
  linux/arm64
)
MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

function build::plugins::tarball() {
  build::common::ensure_tar
  mkdir -p "$TAR_PATH"

  for platform in "${SUPPORTED_PLATFORMS[@]}"; do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    TAR_FILE="cni-plugins-${OS}-${ARCH}-${TAG}.tar.gz"
    build::common::create_tarball ${TAR_PATH}/${TAR_FILE} $BIN_ROOT/$REPO/${OS}-${ARCH} .
  done
  rm -rf $BIN_ROOT
}

build::plugins::tarball

build::common::generate_shasum "${TAR_PATH}"
