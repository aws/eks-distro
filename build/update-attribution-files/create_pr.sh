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
set -x
set -o pipefail

echo "===== Starting ${BASH_SOURCE[0]} ====="

CONTEXT=${1:-"all"}

if [[ -z "$JOB_TYPE" ]]; then
    exit 0
fi

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

source $SCRIPT_ROOT/../lib/common.sh

ORIGIN_ORG="eks-distro-pr-bot"
UPSTREAM_ORG="aws"

MAIN_BRANCH="${PULL_BASE_REF:-main}"

cd ${SCRIPT_ROOT}/../../
git config --global push.default current
git config user.name "EKS Distro PR Bot"
git config user.email "aws-model-rocket-bots+eksdistroprbot@amazon.com"
git config remote.origin.url >&- || git remote add origin git@github.com:${ORIGIN_ORG}/eks-distro.git
git config remote.upstream.url >&- || git remote add upstream https://github.com/${UPSTREAM_ORG}/eks-distro.git

build::common::echo_and_run git status

# Files have already changed, stash to perform rebase
build::common::echo_and_run git stash
build::common::echo_and_run retry git fetch upstream

build::common::echo_and_run git checkout $MAIN_BRANCH
# there will be conflicts before we are on the bots fork at this point
# -Xtheirs instructs git to favor the changes from the current branch
build::common::echo_and_run git rebase -Xtheirs upstream/$MAIN_BRANCH

if [ "$(git stash list)" != "" ]; then
    build::common::echo_and_run git stash pop
    build::common::echo_and_run git status
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
        echo "Creating PR $pr_title"
        gh pr create --title "$pr_title" --body "$pr_body" --base $MAIN_BRANCH
    fi
}

function pr::create::pr_body(){
    pr_body=""
    case $1 in
    attribution)
        pr_body=$(cat <<'EOF'
This PR updates the ATTRIBUTION.txt files across all dependency projects if there have been changes.

These files should only be changing due to project GIT_TAG bumps or Golang version upgrades. If changes are for any other reason, please review carefully before merging!
EOF
)
        ;;
    checksums)
        pr_body=$(cat <<'EOF'
This PR updates the CHECKSUMS files across all dependency projects if there have been changes.

These files should only be changing due to project GIT_TAG bumps or Golang version upgrades. If changes are for any other reason, please review carefully before merging!
EOF
)
        ;;
    makehelp)
        pr_body=$(cat <<'EOF'
This PR updates the Help.mk files across all dependency projects if there have been changes.
EOF
)
        ;;
    go-mod)
        pr_body=$(cat <<'EOF'
This PR updates the checked in go.mod and go.sum files across all dependency projects to support automated vulnerability scanning.
EOF
)
        ;;
    internal-builds)
        pr_body=$(cat <<'EOF'
This PR updates the checked in GIT_TAG, GOLANG_VERSION, and ATTRIBUTION files across all internally build projects.
EOF
)
        ;;
    *)
        echo "Invalid argument: $1"
        exit 1
        ;;
    esac
    PROW_BUCKET_NAME=$(echo $JOB_SPEC | jq -r ".decoration_config.gcs_configuration.bucket" | awk -F// '{print $NF}')
    full_pr_body=$(printf "%s\nClick [here](https://prow.eks.amazonaws.com/view/s3/$PROW_BUCKET_NAME/logs/$JOB_NAME/$BUILD_ID) to view job logs.\n\n/hold\n\nBy submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice." "$pr_body")

    printf "$full_pr_body"
}

function pr::create::attribution() {
    local -r pr_title="Update ATTRIBUTION.txt files"
    local -r commit_message="[PR BOT] Update ATTRIBUTION.txt files"
    local -r pr_branch="attribution-files-update-$MAIN_BRANCH"
    local -r pr_body=$(pr::create::pr_body "attribution")

    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::create::checksums() {
    local -r pr_title="Update CHECKSUMS files"
    local -r commit_message="[PR BOT] Update CHECKSUMS files"
    local -r pr_branch="checksums-files-update-$MAIN_BRANCH"
    local -r pr_body=$(pr::create::pr_body "checksums")

    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::create::help() {
    local -r pr_title="Update Makefile generated help"
    local -r commit_message="[PR BOT] Update Help.mk files"
    local -r pr_branch="help-makefiles-update-$MAIN_BRANCH"
    local -r pr_body=$(pr::create::pr_body "makehelp")

    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::create::go-mod() {
    local -r pr_title="Update go.mod files"
    local -r commit_message="[PR BOT] Update go.mod files"
    local -r pr_branch="go-mod-update-$MAIN_BRANCH"
    local -r pr_body=$(pr::create::pr_body "go-mod")

    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::create::internal-builds() {
    local -r pr_title="Update GIT_TAG and GOLANG_VERSION files for internally built projects"
    local -r commit_message="[PR BOT] Update GIT_TAG and GOLANG_VERSION files"
    local -r pr_branch="internal-builds-$MAIN_BRANCH"
    local -r pr_body=$(pr::create::pr_body "internal-builds")

    pr:create "$pr_title" "$commit_message" "$pr_branch" "$pr_body"
}

function pr::file:add() {
    local -r file="$1"

    if git check-ignore -q $file; then
        return
    fi

    local -r diff="$(git diff --ignore-blank-lines --ignore-all-space $file)"
    if [[ -z $diff ]]; then
        return
    fi

    git add $file
}

function handle_checksums() {
echo "Adding Checksum files"
# Add checksum files
for FILE in $(find . -type f -name CHECKSUMS); do
    pr::file:add $FILE
done

# This file is being added as it may have been updated by the last lines of ./build/lib/update_go_versions.sh,
# which replaces the go version in this script with the go version(s) in the builder base if they are newer 
# when running `make update-checksum-files`
git add ./build/lib/install_go_versions.sh

pr::create::checksums
}

function handle_attribution() {
echo "Adding ATTRIBUTION files"
# Add attribution files
for FILE in $(find . -type f \( -name "*ATTRIBUTION.txt" ! -path "*/_output/*" \)); do
    pr::file:add $FILE
done

pr::create::attribution
}

function handle_help() {
echo "Adding Help.mk files"

# Add help.mk/Makefile files
for FILE in $(find . -type f \( -name Help.mk -o -name Makefile \)); do
    pr::file:add $FILE
done

pr::create::help
}

function handle_go_mod() {
echo "Adding go.mod and go.sum files"
# Add go.mod files
for FILE in $(find . -type f \( -name go.sum -o -name go.mod \)); do    
    git check-ignore -q $FILE || git add $FILE
done

pr::create::go-mod
}

function handle_internal_builds() {
echo "Processing internally built projects"

# Read supported release branches
SUPPORTED_RELEASE_BRANCHES=$(cat $(git rev-parse --show-toplevel)/release/SUPPORTED_RELEASE_BRANCHES)

for PROJECT in $INTERNALLY_BUILT_PROJECTS; do
    PROJECT_PATH=$(echo $PROJECT | sed 's/_/\//g')
    for RELEASE_BRANCH in $SUPPORTED_RELEASE_BRANCHES; do
        for FILE in $(find ./projects/$PROJECT_PATH/$RELEASE_BRANCH -type f \( -name GIT_TAG -o -name GOLANG_VERSION -o -name ATTRIBUTION.txt \) 2>/dev/null || true); do
            git check-ignore -q $FILE || git add $FILE
        done
    done
done

pr::create::internal-builds
}

# Main dispatcher
case $CONTEXT in
    "checksums")
        handle_checksums
        ;;
    "attribution")
        handle_attribution
        ;;
    "help")
        handle_help
        ;;
    "go-mod")
        handle_go_mod
        ;;
    "internal-builds")
        handle_internal_builds
        ;;
    "all")
        handle_checksums
        handle_attribution
        handle_help
        handle_go_mod
        handle_internal_builds
        ;;
    *)
        echo "Invalid context: $CONTEXT"
        exit 1
        ;;
esac

echo "===== Ending ${BASH_SOURCE[0]} ====="