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
TARGET="$2"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
PROJECT_ROOT=$MAKE_ROOT/$PROJECT

OUTPUT_DIR=$MAKE_ROOT/_output
mkdir -p $OUTPUT_DIR
touch $OUTPUT_DIR/total_summary.txt

function build::attribution::generate(){
    make -C $PROJECT_ROOT $TARGET

    if ls $PROJECT_ROOT/_output/**/summary.txt 1> /dev/null 2>&1; then
        for summary in $PROJECT_ROOT/_output/**/summary.txt; do
            sed -i "s/+.*=/ =/g" $summary
            awk -F" => " '{ count[$1]+=$2} END { for (item in count) printf("%s => %d\n", item, count[item]) }' \
                $summary $OUTPUT_DIR/total_summary.txt | sort > $OUTPUT_DIR/total_summary.tmp && mv $OUTPUT_DIR/total_summary.tmp $OUTPUT_DIR/total_summary.txt
        done
    fi
}


# Some projects have specific folders for different kubernetes release
# dynamically find all versions to avoid having to update with every release
RELEASE_FOLDER=$(find $PROJECT_ROOT -type d -name "1-*")

if [ -z "${RELEASE_FOLDER}" ]; then
    build::attribution::generate
else
    LAST_GIT_TAG=""
    LAST_GOLANG_VERSION=""
    LAST_RELEASE_BRANCH=""

    for release in $(cat $MAKE_ROOT/release/SUPPORTED_RELEASE_BRANCHES) ; do
        export RELEASE_BRANCH="$release"
        GIT_TAG="$(cat $PROJECT_ROOT/$release/GIT_TAG)"
        GOLANG_VERSION="$(cat $PROJECT_ROOT/$release/GOLANG_VERSION)"


          if [ "$GIT_TAG" != "$LAST_GIT_TAG" ] || [ "${GOLANG_VERSION}" != "${LAST_GOLANG_VERSION}" ] || [ $TARGET == "update-go-mods" ]; then
              # clean before regenerating to ensure there are no intermediate files left around
              make -C $PROJECT_ROOT clean clean-go-cache
              build::attribution::generate $release
          else
              # if the git_tags match across release branches, save the output state to avoid
              # rebuilding/regenerating
              if [[ $TARGET == *"checksums"* ]] && [ -f "$PROJECT_ROOT/$LAST_RELEASE_BRANCH/CHECKSUMS" ]; then
                  echo "Copying $LAST_RELEASE_BRANCH CHECKSUMS to $release"
                  mkdir -p $PROJECT_ROOT/_output/$release
                  sed "s/$LAST_RELEASE_BRANCH/$release/" $PROJECT_ROOT/$LAST_RELEASE_BRANCH/CHECKSUMS > $PROJECT_ROOT/$release/CHECKSUMS
              fi

              if [[ $TARGET == *"attribution"* ]] && ls $PROJECT_ROOT/$LAST_RELEASE_BRANCH/*TTRIBUTION.txt 1> /dev/null 2>&1; then
                  echo "Copying $LAST_RELEASE_BRANCH ATTRIBUTION to $release"
                  mkdir -p $PROJECT_ROOT/_output/$release
                  cp -rf $PROJECT_ROOT/$LAST_RELEASE_BRANCH/*TTRIBUTION.txt $PROJECT_ROOT/$release
              fi
          fi

        LAST_GIT_TAG="$GIT_TAG"
        LAST_GOLANG_VERSION="${GOLANG_VERSION}"
        LAST_RELEASE_BRANCH="$release"
    done
fi

make -C $PROJECT_ROOT clean clean-go-cache
