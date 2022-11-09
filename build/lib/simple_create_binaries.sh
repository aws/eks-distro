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

set -x
set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT="$1"
TARGET_FILE="$2"
REPO="$3"
GOLANG_VERSION="$4"
BINARY_PLATFORMS="$5"
SOURCE_PATTERN="$6"
GOBUILD_COMMAND="$7" 
EXTRA_GOBUILD_FLAGS="$8"
GO_LDFLAGS="$9"
CGO_ENABLED="${10}"
CGO_LDFLAGS="${11}"
REPO_SUBPATH="${12:-}"
ALL_TARGET_FILES="${13:-}"

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

function build::simple::binaries(){
  mkdir -p $(dirname $TARGET_FILE)
  cd "$PROJECT_ROOT/$REPO/$REPO_SUBPATH"
  build::common::use_go_version $GOLANG_VERSION
  SUPPORTED_PLATFORMS=(${BINARY_PLATFORMS// / })
  for platform in "${SUPPORTED_PLATFORMS[@]}"; do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    if [ $CGO_ENABLED = 1 ]; then
      export CGO_LDFLAGS="$CGO_LDFLAGS,-L$PROJECT_ROOT/_output/source/$OS-$ARCH/usr/lib64"
      export CGO_CFLAGS="-I$PROJECT_ROOT/_output/source/$OS-$ARCH/usr/include"
      export LD_LIBRARY_PATH=$PROJECT_ROOT/_output/source/$OS-$ARCH/usr/lib64:${LD_LIBRARY_PATH-}
      export PKG_CONFIG_PATH=$PROJECT_ROOT/_output/source/$OS-$ARCH/usr/lib64/pkgconfig:${PKG_CONFIG_PATH-}
    fi

    # target file is meant to be treated as a folder since multiple binaries will written out
    if [[ "$TARGET_FILE" == */ ]]; then
      mkdir -p $TARGET_FILE
    fi

    CGO_ENABLED=$CGO_ENABLED GOOS=$OS GOARCH=$ARCH \
      go $GOBUILD_COMMAND -trimpath -a -ldflags "$GO_LDFLAGS" $EXTRA_GOBUILD_FLAGS -o $TARGET_FILE $SOURCE_PATTERN

    if [[ "$TARGET_FILE" == */ ]]; then
      # in the case of outputing to a directory, the files will be named by the basename of the source pattern
      # these need to be renamed to match the configured name from ALL_TARGET_FILES
      TARGET_FILES=(${ALL_TARGET_FILES// / })
      index=0
      for source in $SOURCE_PATTERN; do
        if [ "$(basename $source)" != "${TARGET_FILES[$index]}" ]; then
          # in the case of multiple target files but the first is a ., we cant move . but it should already be named correctly
          [ -f $TARGET_FILE$(basename $source) ] && mv $TARGET_FILE$(basename $source) $TARGET_FILE${TARGET_FILES[$index]}
        fi
        ((index=index+1))
      done
    fi
  done
}

build::simple::binaries
