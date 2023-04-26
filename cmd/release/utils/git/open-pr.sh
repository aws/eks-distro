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

set -e
set -o pipefail
set -x

PR_BRANCH="${1?...}"
PR_TITLE="${2?...}"

echo "pushing..."
git push origin "${PR_BRANCH}"
echo "pushed!"

PR_REPO="eks-distro"

GITHUB_USERNAME_REGEX="s/(https:\/\/|git@)github\.com(\/|:)(.*)\/${PR_REPO}.git/\3/p"
GITHUB_USERNAME=$(git remote get-url origin | sed -n -E "$GITHUB_USERNAME_REGEX")
if [ -z "$GITHUB_USERNAME" ]
then
echo "Failed to parse Github username! Ensure you have a remote 'origin' set." && return 1
fi

pr_arguments=(
  --head "${GITHUB_USERNAME}:${PR_BRANCH}"
  --repo "aws/${PR_REPO}"
  --title "${PR_TITLE}"
  --web
  --body "By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice."
)

gh pr create "${pr_arguments[@]}"
