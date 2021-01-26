#!/usr/bin/env bash
# Copyright 2021 Amazon.com Inc. or its affiliates. All Rights Reserved.
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

set -euxo pipefail

RELEASE_BRANCH="${1?First argument is release branch for example 1-18}"
RELEASE="${2?Second argument is release for example 1}"
PROJECT="${3?Third argument is project}"

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
DEST_DIR=${BASE_DIRECTORY}/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts

if [ $PROJECT = "kubernetes/kubernetes" ]; then
  SOURCE_DIR=_output/${RELEASE_BRANCH}
  GIT_TAG=$(cat ${RELEASE_BRANCH}/GIT_TAG)
else
  SOURCE_DIR=_output/tar/
  GIT_TAG=$(cat GIT_TAG)
fi
REPO="$(cut -d '/' -f2 <<< ${PROJECT})"
ARTIFACT_DIR=${DEST_DIR}/${REPO}/${GIT_TAG}
mkdir -p $ARTIFACT_DIR
cp -r $SOURCE_DIR/* $ARTIFACT_DIR
