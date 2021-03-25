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

CLONE_URL=$1
REPOSITORY=$2
TAG=$3
GOLANG_VERSION="$4"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT_DIR="${OUTPUT_DIR:-${MAKE_ROOT}/_output}"

source "${MAKE_ROOT}/build/lib/clone.sh"
source "${MAKE_ROOT}/build/lib/binaries.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

mkdir -p $OUTPUT_DIR
build::clone::release $CLONE_URL $REPOSITORY $TAG
build::common::use_go_version $GOLANG_VERSION
build::binaries::bins $MAKE_ROOT/$REPOSITORY $OUTPUT_DIR

(cd $MAKE_ROOT/$REPOSITORY/images/build/go-runner && build::gather_licenses $MAKE_ROOT/_output "./go-runner.go") 
