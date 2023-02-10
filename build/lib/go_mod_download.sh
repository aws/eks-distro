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

set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT="$1"
REPO="$2"
TAG="$3"
GOLANG_VERSION="$4"
REPO_SUBPATH="${5:-}"

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

cd $REPO/$REPO_SUBPATH

CACHE_KEY=$(echo $PROJECT_ROOT | sed 's/\(.*\)\//\1-/' | xargs basename)
build::common::use_go_version $GOLANG_VERSION
build::common::set_go_cache $CACHE_KEY $TAG
build::common::echo_and_run go mod vendor
