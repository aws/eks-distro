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

# Taken from https://github.com/aws/eks-distro-build-tooling/blob/main/builder-base/install.sh
# TODO: introduce a shared scripts repo to better share things like this

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

setupgo() {
    local -r version=$1
    go install golang.org/dl/go${version}@latest
    go${version} download
    # Removing the patch number as we only care about the minor version of golang
    local -r majorversion=$(cut -d. -f"1,2" <<< $version)
    mkdir -p ${GOPATH}/go${majorversion}/bin
    ln -sf ${GOPATH}/bin/go${version} ${GOPATH}/go${majorversion}/bin/go
    ln -sf ${HOME}/sdk/go${version}/bin/gofmt ${GOPATH}/go${majorversion}/bin/gofmt
}

setupgo "${GOLANG117_VERSION:-1.17.13}"
setupgo "${GOLANG118_VERSION:-1.18.10}"
setupgo "${GOLANG119_VERSION:-1.19.12}"
setupgo "${GOLANG120_VERSION:-1.20.8}"

# use 1.17 when installing and running go-licenses
# go-licenses needs to be installed by the same version of go that is being used
# to generate the deps list during the attribution generation process
build::common::use_go_version "1.17"
GOBIN=${GOPATH}/go1.17/bin go install github.com/google/go-licenses@v1.2.1

build::common::use_go_version "1.18"
GOBIN=${GOPATH}/go1.18/bin go install github.com/google/go-licenses@v1.2.1

build::common::use_go_version "1.19"
GOBIN=${GOPATH}/go1.19/bin go install github.com/google/go-licenses@v1.2.1

build::common::use_go_version "1.20"
GOBIN=${GOPATH}/go1.20/bin go install github.com/google/go-licenses@v1.2.1

# 1.17 is the default so symlink it to /go/bin
ln -sf ${GOPATH}/go1.17/bin/go-licenses ${GOPATH}/bin
