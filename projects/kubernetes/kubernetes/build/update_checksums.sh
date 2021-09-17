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

RELEASE_BRANCH="$1"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"
BIN_DIR="${OUTPUT_DIR}/${RELEASE_BRANCH}/bin"
if [ ! -d ${BIN_DIR} ] ;  then
    echo "${BIN_DIR} not present! Run 'make binaries'"
    exit 1
fi

if [ "$(go env GOROOT)" != "/usr/local/go" ]; then
    echo "GOROOT mismatch from CI environment!"
    echo "In your environment, GOROOT=$(go env GOROOT), expected \"/usr/local/go\""
    echo "This is required for reproducible builds"
fi

rm ${MAKE_ROOT}/${RELEASE_BRANCH}/checksums || true
# TODO: come up with a better filter than 'kube*'
for file in $(find ${BIN_DIR} -name 'kube*' -type f ); do
    filepath=$(realpath --relative-base=$MAKE_ROOT $file)
    sha256sum $filepath >> ${MAKE_ROOT}/${RELEASE_BRANCH}/checksums
done
