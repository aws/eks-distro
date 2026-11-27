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

set -euo pipefail
shopt -s inherit_errexit

echo "===== Starting ${BASH_SOURCE[0]} ====="

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_ROOT}/../.." && pwd -P)"

source "${REPO_ROOT}/build/lib/common.sh"
source "${REPO_ROOT}/build/lib/release_pr.sh"

MAIN_BRANCH="${PULL_BASE_REF:-main}"
PR_BRANCH="release-docs-${MAIN_BRANCH}"
DRY_RUN="${DRY_RUN:-false}"
AUTOMATED_RELEASE_BRANCHES=(1-31 1-32 1-33 1-34 1-35 1-36)
SECONDS_BETWEEN_BRANCHES=15

function manifest_url() {
    echo "https://distro.eks.amazonaws.com/kubernetes-$1/kubernetes-$1-eks-$2.yaml"
}

function release_key() {
    local entries=()
    local i
    for i in "${!BRANCHES[@]}"; do
        entries+=("${BRANCHES[$i]} ${PROD_RELEASES[$i]}")
    done
    echo "release-pr-key: $(release_pr::join ", " "${entries[@]}")"
}

function pr_title() {
    echo "Add release docs: $(release_pr::join ", " "${BRANCHES[@]}")"
}

function pr_body() {
    printf "Adds release docs for prod releases whose prod-release postsubmit passed.\n\n"
    printf "| Release branch | Prod release | Manifest |\n"
    printf "|---|---|---|\n"
    local i
    for i in "${!BRANCHES[@]}"; do
        printf "| %s | %s | %s |\n" "${BRANCHES[$i]}" "${PROD_RELEASES[$i]}" "$(manifest_url "${BRANCHES[$i]}" "${PROD_RELEASES[$i]}")"
    done
    printf "\n"
    if [ "${#FAILED[@]}" -gt 0 ]; then
        printf "Docs generation failed for these branches, so they are not included. See the job logs.\n\n"
        printf -- "- %s\n" "${FAILED[@]}"
        printf "\n"
    fi
    printf "Merging this PR tags each release, publishes its GitHub release, and then sends the release announcement.\n\n"
    release_pr::job_logs_line
    printf "<!-- %s -->\n\n" "${RELEASE_PR_KEY}"
    printf "/hold\n\nBy submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice."
}

cd "${REPO_ROOT}"
release_pr::require_job
release_pr::fetch_main "${MAIN_BRANCH}"
MAIN_REF="upstream/${MAIN_BRANCH}"

CANDIDATES=()
CANDIDATE_RELEASES=()

for RELEASE_BRANCH in "${AUTOMATED_RELEASE_BRANCHES[@]}"; do
    PROD_RELEASE=$(release_pr::read_file "${MAIN_REF}" "release/${RELEASE_BRANCH}/production/RELEASE")
    if [ -z "${PROD_RELEASE}" ] || [ "${PROD_RELEASE}" -le 1 ]; then
        echo "Skipping ${RELEASE_BRANCH} because docs for a new minor version need manual setup"
        continue
    fi
    if git cat-file -e "${MAIN_REF}:docs/contents/releases/${RELEASE_BRANCH}/${PROD_RELEASE}" 2>/dev/null; then
        echo "${RELEASE_BRANCH} already has docs for prod release ${PROD_RELEASE}"
        continue
    fi

    PROD_COMMIT=$(release_pr::last_commit "${MAIN_REF}" "release/${RELEASE_BRANCH}/production/RELEASE")
    PROD_STATE=$(release_pr::job_state "${PROD_COMMIT}" "prod-release-${RELEASE_BRANCH}-postsubmit")
    if [ "${PROD_STATE}" != "success" ]; then
        echo "${RELEASE_BRANCH} prod release ${PROD_RELEASE} postsubmit is ${PROD_STATE}"
        continue
    fi

    if ! curl -sSfI "$(manifest_url "${RELEASE_BRANCH}" "${PROD_RELEASE}")" > /dev/null; then
        echo "${RELEASE_BRANCH} release manifest for prod release ${PROD_RELEASE} is not published yet"
        continue
    fi

    echo "${RELEASE_BRANCH} needs docs for prod release ${PROD_RELEASE}"
    CANDIDATES+=("${RELEASE_BRANCH}")
    CANDIDATE_RELEASES+=("${PROD_RELEASE}")
done

if [ "${#CANDIDATES[@]}" -eq 0 ]; then
    echo "No release branch needs docs"
    if [ "${DRY_RUN}" != "true" ]; then
        release_pr::setup
        release_pr::close_stale "${PR_BRANCH}" "Every passing prod release on main already has docs, so this PR is no longer needed."
    fi
    exit 0
fi

if [ "${DRY_RUN}" == "true" ]; then
    printf "DRY RUN: would generate docs for %s\n" "$(release_pr::join ", " "${CANDIDATES[@]}")"
    exit 0
fi

release_pr::setup
GITHUB_TOKEN=$(cat "${RELEASE_PR_GITHUB_TOKEN_FILE}")
export GITHUB_TOKEN

BRANCHES=()
PROD_RELEASES=()
FAILED=()

git checkout --detach "${MAIN_REF}"
for i in "${!CANDIDATES[@]}"; do
    RELEASE_BRANCH="${CANDIDATES[$i]}"
    PROD_RELEASE="${CANDIDATE_RELEASES[$i]}"
    if [ "${i}" -gt 0 ]; then
        sleep "${SECONDS_BETWEEN_BRANCHES}"
    fi

    SNAPSHOT_DIR=$(mktemp -d)
    cp README.md docs/contents/index.md "${SNAPSHOT_DIR}/"
    GENERATED=$(go run ./cmd/release/docs/main.go --branch="${RELEASE_BRANCH}" --manageGitAndOpenPR=false >&2 && echo yes || echo no)
    if [ "${GENERATED}" != "yes" ]; then
        FAILED+=("${RELEASE_BRANCH} ${PROD_RELEASE}")
        cp "${SNAPSHOT_DIR}/README.md" README.md
        cp "${SNAPSHOT_DIR}/index.md" docs/contents/index.md
        rm -rf "docs/contents/releases/${RELEASE_BRANCH:?}/${PROD_RELEASE:?}"
        continue
    fi

    BRANCHES+=("${RELEASE_BRANCH}")
    PROD_RELEASES+=("${PROD_RELEASE}")
done

if [ "${#BRANCHES[@]}" -eq 0 ]; then
    printf "Docs generation failed for every candidate branch: %s\n" "$(release_pr::join ", " "${FAILED[@]}")" >&2
    exit 1
fi

RELEASE_PR_KEY=$(release_key)
TITLE=$(pr_title)
BODY=$(pr_body)
release_pr::publish "${MAIN_BRANCH}" "${PR_BRANCH}" "${TITLE}" "${BODY}" \
    docs/contents/releases README.md docs/contents/index.md

if [ "${#FAILED[@]}" -gt 0 ]; then
    exit 1
fi

echo "===== Ending ${BASH_SOURCE[0]} ====="
