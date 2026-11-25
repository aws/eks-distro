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
PR_BRANCH="dev-release-${MAIN_BRANCH}"
DRY_RUN="${DRY_RUN:-false}"
AUTOMATED_RELEASE_BRANCHES=(1-31 1-32 1-33 1-34 1-35 1-36)
MIN_COPY_AGE_SECONDS=1800
REQUIRED_KEY_PATTERNS=(
    'artifacts/kubernetes/v[^/]+/artifacts/kubernetes-public/[^/]+/\.go-version'
    'artifacts/aws-iam-authenticator/[^/]+/\.go-version'
    'artifacts/cloud-provider-aws/[^/]+/\.go-version'
    'artifacts/etcd/\.git_tag'
    'artifacts/etcd/\.go-version'
)

function version_gt() {
    [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" == "$1" ]
}

function platform_versions() {
    local -r release_branch="$1"
    local prefixes
    prefixes=$(aws s3api list-objects-v2 --bucket "${RELEASE_PR_DEV_RELEASE_BUCKET}" \
        --prefix "kubernetes-${release_branch}/releases/" --delimiter / \
        --query "CommonPrefixes[].Prefix" --output text)
    tr '\t' '\n' <<< "${prefixes}" | grep -oE '/eks\.[0-9]+/$' | tr -d / | sort -rV || true
}

function is_complete() {
    local -r release_branch="$1"
    local -r platform_version="$2"
    local -r prefix="kubernetes-${release_branch}/releases/${platform_version}/"
    local objects
    objects=$(aws s3api list-objects-v2 --bucket "${RELEASE_PR_DEV_RELEASE_BUCKET}" --prefix "${prefix}" \
        --query "Contents[].[Key,LastModified]" --output text)

    local pattern
    for pattern in "${REQUIRED_KEY_PATTERNS[@]}"; do
        if ! grep -qE "^${prefix//./\\.}${pattern}\s" <<< "${objects}"; then
            echo "${release_branch} ${platform_version} has no object matching ${pattern} yet" >&2
            echo "incomplete"
            return 0
        fi
    done

    local newest
    newest=$(awk '{print $2}' <<< "${objects}" | sort | tail -1)
    if [ $(( $(date +%s) - $(date -d "${newest}" +%s) )) -lt "${MIN_COPY_AGE_SECONDS}" ]; then
        echo "${release_branch} ${platform_version} was written at ${newest}, so the copy may still be running" >&2
        echo "incomplete"
        return 0
    fi
    echo "complete"
}

function newest_complete_after() {
    local -r release_branch="$1"
    local -r pinned="$2"
    local candidates
    candidates=$(platform_versions "${release_branch}")

    local candidate state
    for candidate in ${candidates}; do
        if ! version_gt "${candidate}" "${pinned}"; then
            return 0
        fi
        state=$(is_complete "${release_branch}" "${candidate}")
        if [ "${state}" == "complete" ]; then
            echo "${candidate}"
            return 0
        fi
    done
}

function checklist() {
    cat <<'EOF'
### Before merging

- [ ] CoreDNS GIT_TAG and patches match the internal build
- [ ] Open ATTRIBUTION, CHECKSUMS, and go.mod PRs are merged

EOF
}

function pr_body() {
    printf "Cuts dev releases from the newest platform versions in \`s3://%s\`.\n\n" "${RELEASE_PR_DEV_RELEASE_BUCKET}"
    printf "| Release branch | Dev release | Previous platform version | New platform version |\n"
    printf "|---|---|---|---|\n"
    local i
    for i in "${!BRANCHES[@]}"; do
        printf "| %s | %s | %s | %s |\n" "${BRANCHES[$i]}" "${DEV_RELEASES[$i]}" "${FROM_VERSIONS[$i]}" "${TO_VERSIONS[$i]}"
    done
    printf "\n"
    checklist
    release_pr::job_logs_line
    printf "<!-- %s -->\n\n" "${RELEASE_PR_KEY}"
    printf "/hold\n\nBy submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice."
}

function release_key() {
    local entries=()
    local i
    for i in "${!BRANCHES[@]}"; do
        entries+=("${BRANCHES[$i]} ${TO_VERSIONS[$i]}")
    done
    echo "release-pr-key: $(release_pr::join ", " "${entries[@]}")"
}

function pr_title() {
    echo "Bump dev releases: $(release_pr::join ", " "${BRANCHES[@]}")"
}

cd "${REPO_ROOT}"
release_pr::require_job
release_pr::fetch_main "${MAIN_BRANCH}"
MAIN_REF="upstream/${MAIN_BRANCH}"

BRANCHES=()
FROM_VERSIONS=()
TO_VERSIONS=()
DEV_RELEASES=()
CHANGED_FILES=()

for RELEASE_BRANCH in "${AUTOMATED_RELEASE_BRANCHES[@]}"; do
    PIN_FILE="release/${RELEASE_BRANCH}/development/PLATFORM_VERSION"
    PINNED=$(release_pr::read_file "${MAIN_REF}" "${PIN_FILE}")
    DEV_RELEASE=$(release_pr::read_file "${MAIN_REF}" "release/${RELEASE_BRANCH}/development/RELEASE")
    if [ -z "${PINNED}" ] || [ -z "${DEV_RELEASE}" ]; then
        echo "Skipping ${RELEASE_BRANCH} because it has no development RELEASE or PLATFORM_VERSION file"
        continue
    fi
    if [[ ! "${PINNED}" =~ ^eks\.[0-9]+$ ]]; then
        echo "Skipping ${RELEASE_BRANCH} because it is pinned to custom release ${PINNED}"
        continue
    fi

    NEXT=$(newest_complete_after "${RELEASE_BRANCH}" "${PINNED}")
    if [ -z "${NEXT}" ]; then
        echo "${RELEASE_BRANCH} has no complete platform version newer than ${PINNED}"
        continue
    fi

    echo "${RELEASE_BRANCH} moves from ${PINNED} to ${NEXT}"
    BRANCHES+=("${RELEASE_BRANCH}")
    FROM_VERSIONS+=("${PINNED}")
    TO_VERSIONS+=("${NEXT}")
    DEV_RELEASES+=("$(( DEV_RELEASE + 1 ))")
    CHANGED_FILES+=("release/${RELEASE_BRANCH}/development/RELEASE" "${PIN_FILE}")
done

if [ "${#BRANCHES[@]}" -eq 0 ]; then
    echo "No release branch has a newer complete platform version"
    if [ "${DRY_RUN}" != "true" ]; then
        release_pr::setup
        release_pr::close_stale "${PR_BRANCH}" "No release branch has a newer complete platform version than main, so this PR is no longer needed."
    fi
    exit 0
fi

RELEASE_PR_KEY=$(release_key)
TITLE=$(pr_title)
BODY=$(pr_body)

if [ "${DRY_RUN}" == "true" ]; then
    printf "DRY RUN: would push %s with PR \"%s\"\n%s\n" "${PR_BRANCH}" "${TITLE}" "${BODY}"
    exit 0
fi

release_pr::setup
git checkout --detach "${MAIN_REF}"
for i in "${!BRANCHES[@]}"; do
    echo "${DEV_RELEASES[$i]}" > "release/${BRANCHES[$i]}/development/RELEASE"
    echo "${TO_VERSIONS[$i]}" > "release/${BRANCHES[$i]}/development/PLATFORM_VERSION"
done
release_pr::publish "${MAIN_BRANCH}" "${PR_BRANCH}" "${TITLE}" "${BODY}" "${CHANGED_FILES[@]}"

echo "===== Ending ${BASH_SOURCE[0]} ====="
