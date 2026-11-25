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
INTERNAL_GIT_TAG="$2"

if [ -z "${INTERNAL_GIT_TAG}" ]; then
  echo "ERROR: no etcd git tag was provided for ${RELEASE_BRANCH}" >&2
  exit 1
fi

# Only K8s 1.36+ moves to etcd 3.6.x; older release branches stay on v3.5.21
if [ "${RELEASE_BRANCH##*-}" -ge 36 ]; then
  MIN_VERSION="v3.6.12"
else
  MIN_VERSION="v3.5.21"
fi

if [[ "$(printf '%s\n' "${MIN_VERSION}" "${INTERNAL_GIT_TAG}" | sort -V | head -1)" != "${MIN_VERSION}" ]]; then
  echo "${MIN_VERSION}"
else
  echo "${INTERNAL_GIT_TAG}"
fi
