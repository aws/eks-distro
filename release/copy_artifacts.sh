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

PROJECT="${1?First required argument is project}"
SOURCE_ARTIFACT_DIR="${2?Second required argument is source artifact directory}"
RELEASE_BRANCH="${3?Third required argument is release branch for example 1-18}"
RELEASE="${4?Fourth required argument is release for example 1}"
GIT_TAG="${5:-}"

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
DEST_DIR=${BASE_DIRECTORY}/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts

# For when calling from projects other than kubernetes
if [ $PROJECT = "kubernetes" ]; then
  GIT_TAG=$(cat ${BASE_DIRECTORY}/projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG)
fi

ARTIFACT_DIR=${DEST_DIR}/${PROJECT}/${GIT_TAG}
mkdir -p $ARTIFACT_DIR
cp -r $SOURCE_ARTIFACT_DIR/* $ARTIFACT_DIR

$SCRIPT_ROOT/create_release_checksums.sh $ARTIFACT_DIR

