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
set -exo pipefail

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
cd ${BASE_DIRECTORY}

while read ANNOUNCEMENT; do
  RELEASE_TAG=$(echo "${ANNOUNCEMENT}" | grep -o -E "[[:digit:]]{1}\-[[:digit:]]{2}-eks-[[:digit:]]{1,2}") # e.g. 1-25-eks-36
  if [ -z "$RELEASE_TAG" ]; then
    echo "Failed to publish release notification: Unable to generate release number for notification subject"
    exit 1
  elif [ -z "${PULL_BASE_SHA}" ]; then
    echo "Must be run in a Prowjob for access to PULL_BASE_SHA"
    exit 1
  fi
  echo $(git remote -v) # TODO: Remove once we confirm the git repo has the correct remotes.
  # git tag -a ${RELEASE_TAG} ${BASE_PULL_SHA} -m ${RELEASE_TAG} # TODO: Temporarily comment out to prevent job from failing
  # git push ${RELEASE_TAG} # TODO: Temporarily comment out to prevent job from failing

done <$(git -C . diff --name-only HEAD^ HEAD | grep '^docs/contents/releases' | grep release-announcement.txt)
