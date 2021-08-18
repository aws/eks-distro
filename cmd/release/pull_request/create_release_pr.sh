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

# TODO: Consider replacing this script with Go code
set -e
set -o pipefail
set -x

PR_BRANCH="${1?...}"
PR_COMMIT_MESSAGE="${2?...}"
PR_FILE_PATHS="${3?...}"
PR_FOR_BOT="${4?...}"

if [ "$PR_FOR_BOT" == "true" ]; then
    IS_BOT=true
else
    IS_BOT=false
fi

ORIGINAL_BRANCH=$(git branch --show-current)

function cleanup {
  echo "Encountered error! Cleaning up..."
  if "$IS_BOT"; then
    git checkout HEAD^ -- "${PR_FILE_PATHS}"
    git checkout "${ORIGINAL_BRANCH}"
    git push -d origin "${PR_BRANCH}"
    git branch -D "${PR_BRANCH}"
    echo "Cleaned up as much as possible for non-bot submitter"
  else
    git checkout "${ORIGINAL_BRANCH}"
    git push -d origin "${PR_BRANCH}"
    echo "Cleaned up minimally for bot submitter"
  fi
}

trap cleanup ERR

PR_REPO="eks-distro"
PR_ORG_REPO="aws/${PR_REPO}"
ORIGIN_ORG=$(git remote get-url origin | sed -n -e "s|git@github.com:\(.*\)/${PR_REPO}.git|\1|p")

PR_BODY=$(cat <<EOF
${PR_COMMIT_MESSAGE}

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)

PR_TITLE="${PR_COMMIT_MESSAGE}"
if "$IS_BOT"; then
  PR_TITLE="[BOT RELEASE] ${PR_TITLE}"
fi

pr_arguments=(
  --title "${PR_TITLE}"
  --body "${PR_BODY}"
  --head "${ORIGIN_ORG}:${PR_BRANCH}"
  --repo "${PR_ORG_REPO}"
)
labels="do-not-merge/hold release"
for label in $labels; do
     pr_arguments+=(--label "${label}")
done

if ! "$IS_BOT"; then
    pr_arguments+=(--web)
fi

git checkout -b "${PR_BRANCH}"
for aFilePath in $PR_FILE_PATHS; do
  git add "${aFilePath}"
done
git commit -m "${PR_COMMIT_MESSAGE}" || true

echo "pushing..."
git push origin "${PR_BRANCH}"
echo "pushed!"

gh pr create "${pr_arguments[@]}"

git co "${ORIGINAL_BRANCH}"
git br -D "${PR_BRANCH}"
