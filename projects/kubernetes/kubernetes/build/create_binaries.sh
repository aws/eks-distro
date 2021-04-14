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

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

CLONE_URL="$1"
RELEASE_BRANCH="$2"
GIT_TAG="$3"
GOLANG_VERSION="$4"

source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
RELEASE_FILE="${BASE_DIRECTORY}/release/${RELEASE_BRANCH}/${RELEASE_ENVIRONMENT}/RELEASE"
PATCH_DIR=${MAKE_ROOT}/${RELEASE_BRANCH}/patches
export KUBE_GIT_VERSION=$(build::version::kube_git_version $GIT_TAG $RELEASE_FILE $RELEASE_BRANCH)
if [ -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin already exists. Run 'make clean' before rebuilding"
    exit 0
fi
build::git::clone "$CLONE_URL" "$SOURCE_DIR"
build::git::patch "$SOURCE_DIR" "$GIT_TAG" "$PATCH_DIR"
build::common::use_go_version $GOLANG_VERSION
build::binaries::kube_bins "$SOURCE_DIR"

mkdir -p ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
cp -r ${SOURCE_DIR}/_output/local/bin/* ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin

# In presubmit builds space is very limited
rm -rf ${SOURCE_DIR}/_output

# The heketi/heketi dependency is dual licensed between Apache 2.0 or LGPLv3+
# this was done at the request of the kubernetes project since the orginial licese
# was not one that all redistro.  The pieces used by the kubernetes project follow under
# the apache2 license.
# https://github.com/heketi/heketi/pull/1419
# https://github.com/kubernetes/kubernetes/pull/70828
# Copy the apache2 license into place in the vendor directory
cp $REPOSITORY/vendor/github.com/heketi/heketi/LICENSE-APACHE2 $REPOSITORY/vendor/github.com/heketi/heketi/LICENSE 

PATTERNS="./cmd/kubelet ./cmd/kube-proxy ./cmd/kubeadm ./cmd/kubectl ./cmd/kube-apiserver ./cmd/kube-controller-manager ./cmd/kube-scheduler"
(cd $REPOSITORY && build::gather_licenses ${OUTPUT_DIR}/${RELEASE_BRANCH} "$PATTERNS")
cp $MAKE_ROOT/${RELEASE_BRANCH}/ATTRIBUTION.txt ${OUTPUT_DIR}/${RELEASE_BRANCH}
