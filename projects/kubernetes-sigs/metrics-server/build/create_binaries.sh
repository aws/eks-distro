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

TAG="$1"
BIN_PATH="$2"
OS="$3"
ARCH="$4"

PKG="sigs.k8s.io/metrics-server/pkg"
GIT_COMMIT="$(git describe --always --abbrev=0)"
BUILD_DATE=$(git show -s --format=format:%ct HEAD)
GOLDFLAGS="-X $PKG/version.gitVersion=$TAG -X $PKG/version.gitCommit=$GIT_COMMIT -X $PKG/version.buildDate=$BUILD_DATE"

GOARCH=$ARCH GOOS=$OS CGO_ENABLED=0 \
	go build -trimpath \
	-ldflags "-s -w -buildid='' $GOLDFLAGS" \
	-o $BIN_PATH/metrics-server sigs.k8s.io/metrics-server/cmd/metrics-server
    
make clean
