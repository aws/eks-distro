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

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

if [[ -z "$JOB_TYPE" ]]; then
    exit 0
fi

GOPATH=$GOPATH
if [ -d "/go" ]; then
    GOPATH="/go"
fi

for go in $GOPATH/go*/bin/go; do
    VERSION=$($go version | grep -o "go[0-9].* " | grep -o "[0-9\.]*")
    NOPATCH=$(cut -d. -f"1,2" <<< $VERSION)
    sed -i "s,\${GOLANG${NOPATCH//./}_VERSION:-.*},\${GOLANG${NOPATCH//./}_VERSION:-$VERSION}," ./build/lib/install_go_versions.sh 
done
