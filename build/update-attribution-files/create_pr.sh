#!/usr/bin/env bash
# Copyright 2020 Amazon.com Inc. or its affiliates. All Rights Reserved.
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

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

ORIGIN_ORG="eks-distro-pr-bot"
UPSTREAM_ORG="aws"

PR_TITLE="Update ATTRIBUTION.txt files"
COMMIT_MESSAGE="[PR BOT] Update ATTRIBUTION.txt files"

PR_BODY=$(cat <<EOF
This PR updates the ATTRIBUTION.txt files across all depedency projects if there have been changes.

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)

PR_BRANCH="attribution-files-update"

cd ${SCRIPT_ROOT}/../../
git config --global push.default current
git config user.name "EKS Distro PR Bot"
git remote add origin git@github.com:${ORIGIN_ORG}/eks-distro.git
git remote add upstream https://github.com/${UPSTREAM_ORG}/eks-distro.git
git checkout -b $PR_BRANCH

for FILE in $(find . -type f \( -name ATTRIBUTION.txt ! -path "*/_output/*" \)); do    
    git add $FILE
done
FILES_ADDED=$(git diff --staged --name-only)
if [ "$FILES_CHANGED" = "" ]; then
    exit 0
fi

git commit -m "$COMMIT_MESSAGE" || true

git fetch upstream
# there will be conflicts before we are on the bots fork at this point
# -Xtheirs instructs git to favor the changes from the current branch
git rebase -Xtheirs upstream/main

ssh-agent bash -c 'ssh-add /secrets/ssh-secrets/ssh-key; ssh -o StrictHostKeyChecking=no git@github.com; git push -u origin $PR_BRANCH -f'

gh auth login --with-token < /secrets/github-secrets/token

PR_EXISTS=$(gh pr list | grep -c "${PR_BRANCH}" || true)
if [ $PR_EXISTS -eq 0 ]; then
  gh pr create --title "$PR_TITLE" --body "$PR_BODY"
fi
