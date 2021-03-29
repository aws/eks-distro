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
source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

RELEASE_BRANCH="$1"
GOLANG_VERSION="$2"

OUTPUT_RELEASE_DIR="${OUTPUT_DIR}/${RELEASE_BRANCH}"

# a number of k8s.io dependencies which come from the main repo show
# up in the list and since they are in the repo they have no version
# set the rootmodule name to k8s.io to force all projects with that 
# prefix and no version to use the k8s git_tag version
echo "k8s.io" > ${OUTPUT_RELEASE_DIR}/attribution/root-module.txt

build::generate_attribution $MAKE_ROOT/$RELEASE_BRANCH $GOLANG_VERSION $OUTPUT_RELEASE_DIR
