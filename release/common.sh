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

# Unless specifically noted, none of the printed values contain the quote characters shown in the comments.

# If add_d is 'true', prints 'eks-d-<release_branch>-<release_number>' (e.g. 'eks-d-1-19-1').
# Otherwise, prints 'eks-<release_branch>-<release_number>' (e.g. 'eks-1-19-1').
function get_formatted_version_release() {
  local release_branch=$1
  local release_number=$2
  local add_d="${3:-false}"

  echo "eks-$([ "$add_d" == "true" ] && echo "d-")$(get_basic_version_release $release_branch $release_number)"
}

# Prints '<release_branch>-<release_number>' (e.g. '1-19-1').
function get_basic_version_release() {
  local release_branch=$1
  local release_number=$2

  echo "${release_branch}-${release_number}"
}

# Prints 'v<release_branch>-eks-<release_number>' (e.g. 'v1-19-eks-1').
function get_github_release_tag() {
  local release_branch=$1
  local release_number=$2

  echo "v${release_branch}-eks-${release_number}"
}
