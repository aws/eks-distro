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
CLONE_URL="$2"
TAG="$3"
BIN_ROOT="_output/bin"
BIN_PATH=$BIN_ROOT/$REPO

readonly SUPPORTED_PLATFORMS=(
  linux/amd64
  linux/arm64
)

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

function build::plugins::binaries(){
  mkdir -p "$BIN_PATH"
  git clone "$CLONE_URL" "$REPO"
  cd "$REPO"
  git switch -c "$TAG"
  for platform in "${SUPPORTED_PLATFORMS[@]}"; do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    CGO_ENABLED=0 GOOS=$OS GOARCH=$ARCH sh build_linux.sh -ldflags "-s -w -buildid='' -extldflags -static -X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=${TAG}"
    mkdir -p ../${BIN_PATH}/${OS}-${ARCH}
    mv bin/* ../${BIN_PATH}/${OS}-${ARCH}
  done
  build::gather_licenses ./ $MAKE_ROOT/LICENSES
  cd ..
  rm -rf $REPO
}

build::plugins::binaries
