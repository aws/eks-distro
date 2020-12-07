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

function build::metrics-server::binaries(){
  mkdir -p "$BIN_PATH"
  if [ ! -d $REPO ]; then
    git clone "$CLONE_URL" "$REPO"
  fi
  local -r pkg="sigs.k8s.io/metrics-server/pkg"
  local -r git_commit="$(git -C $REPO describe --always --abbrev=0)"
  local -r build_date=$(git -C $REPO show -s --format=format:%ct HEAD)
  local -r goldflags="-X ${pkg}/version.gitVersion=$TAG -X ${pkg}/version.gitCommit=$git_commit -X ${pkg}/version.buildDate=$build_date"
  git -C $REPO switch -c "$TAG"
  for platform in "${SUPPORTED_PLATFORMS[@]}";
  do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    GOOS=$OS make -C $REPO ARCH=$ARCH LDFLAGS="-s -w -buildid='' $goldflags"
    mkdir -p $BIN_PATH/$OS-$ARCH
    mv $REPO/metrics-server $BIN_PATH/$OS-$ARCH/metrics-server
    make -C $REPO clean
  done
  build::gather_licenses ./ $MAKE_ROOT/LICENSES
  rm -rf "$REPO"
}

build::metrics-server::binaries
