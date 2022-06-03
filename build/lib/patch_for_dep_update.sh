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

REPO="$1"
GIT_TAG="$2"
PATCHES_DIR="${3:-../patches}"

mkdir -p $PATCHES_DIR

cd $REPO

COMMIT=$(git rev-parse HEAD)
LATEST_PATCH_NUMBER=$(ls -f $PATCHES_DIR | cut -d- -f1 | sort | tail -1)

if [[ ! $LATEST_PATCH_NUMBER =~ ^[0-9] ]]; then
    LATEST_PATCH_NUMBER=1
fi

git add go.mod go.sum

# if the upstream project vends their deps, lets update them in the patch
if [ $(git cat-file -t $GIT_TAG:vendor 2>/dev/null) ]; then
    git add ./vendor
fi

git commit
git format-patch --signoff --start-number $((LATEST_PATCH_NUMBER + 1)) -o $PATCHES_DIR $COMMIT --

# Copy into project folder to check in for dependabot
cp -f go.{mod,sum} $(dirname $PATCHES_DIR)
