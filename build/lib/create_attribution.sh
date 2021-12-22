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

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

PROJECT_ROOT="$1"
GOLANG_VERSION="$2"
OUTPUT_DIR="$3"
OUTPUT_FILENAME="$4"
RELEASE_BRANCH="${5:-}"

if [[ -n "$RELEASE_BRANCH" ]] && [ -d "$PROJECT_ROOT/$RELEASE_BRANCH" ]; then
	PROJECT_ROOT=$PROJECT_ROOT/$RELEASE_BRANCH
fi

build::generate_attribution $PROJECT_ROOT $GOLANG_VERSION $OUTPUT_DIR $PROJECT_ROOT/$OUTPUT_FILENAME
