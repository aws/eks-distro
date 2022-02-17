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

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

REPO="$1"
GOLANG_VERSION="$2"
GIT_TAG="$3"
RELEASE_BRANCH="$4"

source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

OUTPUT_DIR=${MAKE_ROOT}/_output/${RELEASE_BRANCH}
KUBE_GIT_VERSION_FILE=${MAKE_ROOT}/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE

build::common::use_go_version $GOLANG_VERSION
build::common::set_go_cache kubernetes $GIT_TAG
build::binaries::kube_bins "$SOURCE_DIR" $RELEASE_BRANCH $GIT_TAG $KUBE_GIT_VERSION_FILE

mkdir -p ${OUTPUT_DIR}/bin
rsync --remove-source-files -a --include '*/' --include 'kube-*' --include 'kubelet*' \
	--include 'kubeadm*' --include 'kubectl*' --exclude '*' ${SOURCE_DIR}/_output/local/bin ${OUTPUT_DIR}

# In presubmit builds space is very limited
rm -rf ${SOURCE_DIR}/_output
