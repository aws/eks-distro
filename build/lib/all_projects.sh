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

BASE_DIRECTORY="${1?Specify first argument - Base directory of build-tooling repo}"
MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

cd $MAKE_ROOT

# Iterating over orgs under projects folder
for org_path in projects/*; do
    org=$(basename "$org_path")
    for repo_path in projects/$org/*; do
        repo=$(basename "$repo_path")
        # couple odd ball non-builds in this repo
        if [[ -f $repo_path/DO_NOT_BUILD ]]; then
            continue
        fi
        echo -n "${org}_${repo} "
    done
done

echo
