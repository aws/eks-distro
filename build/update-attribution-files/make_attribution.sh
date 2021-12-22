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

set -e
set -o errexit
set -o nounset
set -o pipefail
shopt -s globstar

PROJECT="$1"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
PROJECT_ROOT=$MAKE_ROOT/$PROJECT

mkdir -p _output
touch _output/total_summary.txt

function build::attribution::generate(){
    if [ $# -ge 1 ]; then
        export RELEASE_BRANCH="$1"
    fi
    make -C $PROJECT_ROOT binaries attribution checksums
    if [ -f $PROJECT_ROOT/_output/**/summary.txt ]; then
        for summary in $PROJECT_ROOT/_output/**/summary.txt; do
            sed -i "s/+.*=/ =/g" $summary
            awk -F" =\> " '{ count[$1]+=$2} END { for (item in count) printf("%s => %d\n", item, count[item]) }' \
                $summary _output/total_summary.txt | sort > _output/total_summary.tmp && mv _output/total_summary.tmp _output/total_summary.txt
        done
    fi
    make -C $PROJECT_ROOT clean 
}


# Some projects have specific folders for different kubernetes release
# dynamically find all versions to avoid having to update with every release
RELEASE_FOLDER=$(find $PROJECT_ROOT -type d -name "1-*")

if [ -z "${RELEASE_FOLDER}" ]; then
    build::attribution::generate
else
    for release in $PROJECT_ROOT/1-*/ ; do
        build::attribution::generate $(basename $release)
    done
fi
