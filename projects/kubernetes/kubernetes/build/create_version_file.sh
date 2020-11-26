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

set -o errexit
set -o nounset
set -o pipefail

TAG=$1
RELEASE_BRANCH=$2

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"
if [ ! -d ${MAKE_ROOT}/_bin ] ;  then
    echo "${MAKE_ROOT}/_bin not present! Run 'make binaries'"
    exit 1
fi

VERSION_FILE="${MAKE_ROOT}/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"
rm -f $VERSION_FILE
touch $VERSION_FILE
RELEASE_FILE="${MAKE_ROOT}/${RELEASE_BRANCH}/RELEASE"
build::version::create_env_file "$TAG" "$VERSION_FILE" "$RELEASE_FILE" "kubernetes"
