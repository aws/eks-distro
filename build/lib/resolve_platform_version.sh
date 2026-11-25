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

set -euo pipefail

RELEASE_BRANCH="$1"
LISTING_FILE="$2"

ROOT_DIR="$(git rev-parse --show-toplevel)"
PIN_FILE="${ROOT_DIR}/release/${RELEASE_BRANCH}/${RELEASE_ENVIRONMENT:-development}/PLATFORM_VERSION"

if [ ! -s "${PIN_FILE}" ]; then
    grep -o 'eks\.[0-9]\+' "${LISTING_FILE}" | sort -V | tail -1
    exit 0
fi

PLATFORM_VERSION="$(tr -d '[:space:]' < "${PIN_FILE}")"
if ! grep -qF "/releases/${PLATFORM_VERSION}/" "${LISTING_FILE}"; then
    echo "ERROR: ${PIN_FILE} pins ${PLATFORM_VERSION}, which is not in the dev release bucket" >&2
    exit 1
fi
echo "${PLATFORM_VERSION}"
