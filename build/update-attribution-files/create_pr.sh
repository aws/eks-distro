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

if [[ -z "$JOB_TYPE" ]]; then
    exit 0
fi

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

ORIGIN_ORG="eks-distro-pr-bot"
UPSTREAM_ORG="aws"

MAIN_BRANCH="${PULL_BASE_REF:-main}"

cd ${SCRIPT_ROOT}/../../
git config --global push.default current
git config user.name "EKS Distro PR Bot"
git config user.email "aws-model-rocket-bots+eksdistroprbot@amazon.com"
git config remote.origin.url >&- || git remote add origin git@github.com:${ORIGIN_ORG}/eks-distro.git
git config remote.upstream.url >&- || git remote add upstream https://github.com/${UPSTREAM_ORG}/eks-distro.git

# Files have already changed, stash to perform rebase
git stash
git fetch upstream
# there will be conflicts before we are on the bots fork at this point
# -Xtheirs instructs git to favor the changes from the current branch
git rebase -Xtheirs upstream/$MAIN_BRANCH

if [ "$(git stash list)" != "" ]; then
    git stash pop
fi

function pr:create()
{
    local -r pr_title="$1"
    local -r commit_message="$2"
    local -r pr_branch="$3"
    local -r pr_body="$4"

    git diff --staged
    local -r files_added=$(git diff --staged --name-only)
    if [ "$files_added" = "" ]; then
        return 0
    fi

    git checkout -B $pr_branch
    git commit -m "$commit_message" || true

    if [ "$JOB_TYPE" != "periodic" ]; then
        return 0
    fi

    ssh-agent bash -c 'ssh-add /secrets/ssh-secrets/ssh-key; ssh -o StrictHostKeyChecking=no git@github.com; git push -u origin $pr_branch -f'

    gh auth login --with-token < /secrets/github-secrets/token
    local -r pr_exists=$(gh pr list | grep -c "$pr_branch" || true)
    if [ $pr_exists -eq 0 ]; then
        gh pr create --title "$pr_title" --body "$pr_body" --base $MAIN_BRANCH
    fi
}

function pr::create::attribution() {
    local -r pr_title="Update ATTRIBUTION.txt files"
    local -r commit_message="[PR BOT] Update ATTRIBUTION.txt files"
    local -r pr_branch="attribution-files-update-$MAIN_BRANCH"
    local -r pr_body=$(cat <<EOF
This PR updates the ATTRIBUTION.txt files across all dependency projects if there have been changes.

This files should only be changing due to project GIT_TAG bumps or golang version upgrades.  If changes are for any other reason please review carefully! 

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)
    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::create::checksums() {
    local -r pr_title="Update CHECKSUMS files"
    local -r commit_message="[PR BOT] Update CHECKSUMS files"
    local -r pr_branch="checksums-files-update-$MAIN_BRANCH"
    local -r pr_body=$(cat <<EOF
This PR updates the CHECKSUMS files across all dependency projects if there have been changes.

This files should only be changing due to golang version upgrades.  If changes are for any other reason please do not merge!

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)
    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::create::help() {
    local -r pr_title="Update Makefile generated help"
    local -r commit_message="[PR BOT] Update Help.mk files"
    local -r pr_branch="checksums-files-update-$MAIN_BRANCH"
    local -r pr_body=$(cat <<EOF
This PR updates the Help.mk files across all dependency projects if there have been changes.

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)
    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}


# Add attribution files
for FILE in $(find . -type f \( -name "*ATTRIBUTION.txt" ! -path "*/_output/*" \)); do    
    git check-ignore -q $FILE || git add $FILE
done

# stash checksums files
git stash --keep-index

pr::create::attribution

git checkout $MAIN_BRANCH

if [ "$(git stash list)" != "" ]; then
    git stash pop
fi
# Add checksum files
for FILE in $(find . -type f -name CHECKSUMS); do    
    git check-ignore -q $FILE || git add $FILE
done

# stash help.mk files
git stash --keep-index

pr::create::checksums

git checkout $MAIN_BRANCH

if [ "$(git stash list)" != "" ]; then
    git stash pop
fi
# Add help.mk/Makefile files
for FILE in $(find . -type f \( -name Help.mk -o -name Makefile \)); do    
    git check-ignore -q $FILE || git add $FILE
done

pr::create::help
