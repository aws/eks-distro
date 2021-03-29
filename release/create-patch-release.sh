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

BASE_DIRECTORY=$(git rev-parse --show-toplevel)

CURR_RELEASE=$(cat ${BASE_DIRECTORY}/release/${RELEASE_BRANCH}/RELEASE)
NEW_RELEASE=$("${BASE_DIRECTORY}/release/get-next-patch-release-number.sh" "${RELEASE_BRANCH}" "${CURR_RELEASE}")


if ! [[ $NEW_RELEASE =~ ^[0-9]{1,}$ ]]; then
  echo "${NEW_RELEASE}"
  exit 1
fi

"${BASE_DIRECTORY}/release/create-patch-release-components-releases.sh" "${RELEASE_BRANCH}" "${CURR_RELEASE}" "${NEW_RELEASE}"

# Create release docs

# Create announcement
