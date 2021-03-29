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

RELEASE_BRANCH="${1?First required argument is release branch for example 1-18}"
CURR_RELEASE="${2?Second required argument is release for example 1}"

NEXT_RELEASE=$((CURR_RELEASE + 1))

inconsistent_release_number_count=0

function increment_and_print_inconsistency_count() {
  inconsistent_release_number_count=$((inconsistent_release_number_count + 1))
  echo -e "\nError #${inconsistent_release_number_count}"
}

function print_error() {
  local final_path_with_inconsistency="${1}"
  local actual_value="${2}"
  local expected_value="${3:-$CURR_RELEASE}"

  increment_and_print_inconsistency_count
  echo "Unexpected release number in $final_path_with_inconsistency. Expected '$expected_value' but found '$actual_value'"
}

BASE_DIRECTORY=$(git rev-parse --show-toplevel)

# Checking release/*
for file in "${BASE_DIRECTORY}/release/${RELEASE_BRANCH}"/*; do
  [ $(<"$file") == "$CURR_RELEASE" ] || print_error $file $(<"$file")
done

# Checking projects/kubernetes/kubernetes/${RELEASE_BRANCH}/*
kubernetes_release_branch_dir="${BASE_DIRECTORY}/projects/kubernetes/kubernetes/${RELEASE_BRANCH}"

source "./common.sh"
FORMATTED_CURR_RELEASE=$(get_formatted_version_release "${RELEASE_BRANCH}" $CURR_RELEASE)

CURR_RELEVANT_KUBE_GIT_VERSION=$(grep -o -E "${FORMATTED_CURR_RELEASE}*[^']" "${kubernetes_release_branch_dir}/KUBE_GIT_VERSION_FILE")
if [ "$FORMATTED_CURR_RELEASE" != "$CURR_RELEVANT_KUBE_GIT_VERSION" ]; then
  print_error "${kubernetes_release_branch_dir}/KUBE_GIT_VERSION_FILE" "$CURR_RELEVANT_KUBE_GIT_VERSION" "$FORMATTED_CURR_RELEASE"
fi

kubernetes_release_branch_release_file="${kubernetes_release_branch_dir}/RELEASE"
if [ $(<"${kubernetes_release_branch_release_file}") != "${CURR_RELEASE}" ]; then
  print_error $(<"${kubernetes_release_branch_release_file}") $(<"${kubernetes_release_branch_release_file}")
fi

## Checking docs/contents/releases/${RELEASE_BRANCH}/
release_docs_dir=${BASE_DIRECTORY}/docs/contents/releases/${RELEASE_BRANCH}
largest_sub_dir=$(ls "${release_docs_dir}" | tail -1)
if [ "$largest_sub_dir" != "${CURR_RELEASE}" ]; then
  print_error "(subdirectories of) $release_docs_dir" "$largest_sub_dir"
fi

if [ -d "${release_docs_dir}/${NEXT_RELEASE}" ]; then
  increment_and_print_inconsistency_count
  echo -e "Did not expect the next release to already have directory at ${release_docs_dir}/${NEXT_RELEASE}"
fi

# If no errors were found, prints value that should be the next release number
if [ ${inconsistent_release_number_count} == 0 ]; then
  echo $NEXT_RELEASE
else
  echo -e "\nThere is/are ${inconsistent_release_number_count} inconsistency(ies) for release $CURR_RELEASE of release branch $RELEASE_BRANCH.\
  Creating a new release without resolving these could cause problems."
fi
