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

setupgo() {
    local -r version=$1
    go get golang.org/dl/go${version}
    go${version} download
    # Removing the patch number as we only care about the minor version of golang
    local -r majorversion=${version%.*}
    mkdir -p ${GOPATH}/go${majorversion}/bin
    ln -sf ${GOPATH}/bin/go${version} ${GOPATH}/go${majorversion}/bin/go
    ln -sf ${HOME}/sdk/go${version}/bin/gofmt ${GOPATH}/go${majorversion}/bin/gofmt
}

setupgo "${GOLANG113_VERSION:-1.13.15}"
setupgo "${GOLANG114_VERSION:-1.14.15}"
setupgo "${GOLANG115_VERSION:-1.15.15}"
setupgo "${GOLANG116_VERSION:-1.16.12}"
