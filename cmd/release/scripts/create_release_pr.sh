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

PATHWAY="${1?....}"

#SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

#UPSTREAM_ORG="aws"
IS_BOT=false

ORIGIN_ORG=$(git remote get-url origin | sed -n -e "s|git@github.com:\(.*\)/eks-distro.git|\1|p")

#ORIGIN_ORG="eks-distro-pr-bot"
#cd ${SCRIPT_ROOT}/../../ # Correct??
#git config --global push.default current
#git config user.name "EKS Distro PR Bot"
#git remote add origin git@github.com:${ORIGIN_ORG}/eks-distro.git
#git remote add upstream https://github.com/${UPSTREAM_ORG}/eks-distro.git

PR_TITLE="TEST!! Increment RELEASE ..."
COMMIT_MESSAGE="TEST!! [PR BOT] Increment RELEASE for ..."
#
PR_BODY=$(cat <<EOF
TEST!! Bumping RELEASE version

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)
#
PR_BRANCH="automate-release-number-final"#"automated-release-update"

#git checkout -b $PR_BRANCH

if [[ "$(git status --porcelain | wc -l)" -eq 1 ]]; then
  git add "${PATHWAY}"
  if [[ $(git diff --staged --name-only) == "" ]]; then
    exit 0
  fi
  git commit -m "${COMMIT_MESSAGE}" || true
else
  git restore "${PATHWAY}"
  echo "Unexpected files."
  echo "Restored ${PATHWAY}"
  exit 145
fi

git push origin "$PR_BRANCH"
#

#
##
#git fetch upstream
### there will be conflicts before we are on the bots fork at this point
### -Xtheirs instructs git to favor the changes from the current branch
#git rebase -Xtheirs upstream/main

#HI=$(git push -u origin "$PR_BRANCH" -f)
#
#echo $HI
#
##ssh-agent bash -c 'ssh-add /secrets/ssh-secrets/ssh-key; ssh -o StrictHostKeyChecking=no git@github.com; git push -u origin $PR_BRANCH -f'
##
##gh auth login --with-token < /secrets/github-secrets/token
##
#PR_EXISTS=$(gh pr list | grep -c "${PR_BRANCH}" || true)
#if [ $PR_EXISTS -eq 0 ]; then
#  gh pr create --title "$PR_TITLE" --body "$PR_BODY"
#fi
