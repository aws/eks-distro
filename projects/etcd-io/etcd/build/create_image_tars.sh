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

BASE_IMAGE="$1"
IMAGE="$2"

readonly SUPPORTED_PLATFORMS=(
  linux/amd64
  linux/arm64
)

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

function build::etcd::image_tars(){
  for platform in "${SUPPORTED_PLATFORMS[@]}";
  do
      OS="$(cut -d '/' -f1 <<< ${platform})"
      ARCH="$(cut -d '/' -f2 <<< ${platform})"
      buildctl \
		      build \
		      --frontend dockerfile.v0 \
		      --opt platform=${platform} \
		      --opt build-arg:BASE_IMAGE=${BASE_IMAGE} \
		      --local dockerfile=./docker/linux \
		      --local context=. \
		      --output type=oci,oci-mediatypes=true,name=${IMAGE},dest=${MAKE_ROOT}/_output/bin/etcd/${OS}-${ARCH}/etcd.tar
  done
}

build::etcd::image_tars