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

set -euxo pipefail

RELEASE_BRANCH="${1?First required argument is release branch for example 1-18}"
CURR_RELEASE="${2?Second required argument is release for example 1}"
NEW_RELEASE="${3?Second required argument is release for example 2}"

BASE_DIRECTORY=$(git rev-parse --show-toplevel)

echo "in components script file"

# Generating release/*
for file in "${BASE_DIRECTORY}/release/${RELEASE_BRANCH}"/*; do
  echo "${NEW_RELEASE}" >| "${file}"
done

# Generating projects/kubernetes/kubernetes/${RELEASE_BRANCH}/*
kubernetes_release_branch_dir="${BASE_DIRECTORY}/projects/kubernetes/kubernetes/${RELEASE_BRANCH}"

source "./common.sh"
FORMATTED_CURR_RELEASE=$(get_formatted_version_release "${RELEASE_BRANCH}" "${CURR_RELEASE}")
FORMATTED_NEW_RELEASE=$(get_formatted_version_release "${RELEASE_BRANCH}" "${NEW_RELEASE}")

sed -i '' "s/${FORMATTED_CURR_RELEASE}/${FORMATTED_NEW_RELEASE}/g" ${kubernetes_release_branch_dir}/KUBE_GIT_VERSION_FILE

echo "${NEW_RELEASE}" >|"${kubernetes_release_branch_dir}/RELEASE"
