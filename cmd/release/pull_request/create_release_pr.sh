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
PR_COMMIT_MESSAGE="${2?...}"
PR_FILE_PATHS="${3?...}"

ORIGINAL_BRANCH=$(git branch --show-current)

function cleanup {
  echo "Encountered error! Cleaning up..."
  git checkout HEAD^ -- "${PR_FILE_PATHS}"
  git checkout "${ORIGINAL_BRANCH}"
  git push -d origin "${PR_BRANCH}"
  git branch -D "${PR_BRANCH}"
  echo "Cleaned up"
}

trap cleanup ERR

ORIGIN_ORG=$(git remote get-url origin | sed -n -e "s|git@github.com:\(.*\)/eks-distro.git|\1|p")
PR_BODY=$(cat <<EOF
${PR_COMMIT_MESSAGE}

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)

git checkout -b "${PR_BRANCH}"
for aFilePath in $PR_FILE_PATHS; do
  git add "${aFilePath}"
done
git commit -m "${PR_COMMIT_MESSAGE}" || true

echo "pushing..."
git push origin "${PR_BRANCH}" -f #--verbose | grep "distro" #--porcelain
echo "pushed!"

gh pr create \
    --title "${PR_COMMIT_MESSAGE}" \
    --body "${PR_BODY}" \
    --head "${ORIGIN_ORG}:${PR_BRANCH}" \
    --repo "aws/eks-distro" \
    --web

git co "${ORIGINAL_BRANCH}"
git br -D "${PR_BRANCH}"
