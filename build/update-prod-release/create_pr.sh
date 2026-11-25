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
PR_BRANCH="prod-release-${MAIN_BRANCH}"
INTERNAL_BUILDS_PR_BRANCH="internal-builds-${MAIN_BRANCH}"
DRY_RUN="${DRY_RUN:-false}"
AUTOMATED_RELEASE_BRANCHES=(1-31 1-32 1-33 1-34 1-35 1-36)

# Prints files changed between the dev release commit and ref that can change what this branch's prod release builds.
function changed_build_inputs() {
    local -r dev_commit="$1"
    local -r ref="$2"
    local -r release_branch="$3"
    local -r ignored='^(docs/|\.github/|development/|build/update-[^/]+/|build/lib/release_pr\.sh$|release/(SUPPORTED_RELEASE_BRANCHES|DEFAULT_RELEASE_BRANCH)$|EKS_DISTRO_[A-Z0-9_]*TAG_FILE$)|\.md$|(^|/)(go\.sum|go\.mod|Help\.mk|[A-Z_]*ATTRIBUTION\.txt|CHECKSUMS|LICENSE|NOTICE|OWNERS)$'
    local -r internal_outputs="^projects/(kubernetes/kubernetes|kubernetes/cloud-provider-aws|kubernetes-sigs/aws-iam-authenticator|etcd-io/etcd|containernetworking/plugins)/${release_branch}/(.*/)?(GIT_TAG|GOLANG_VERSION)$"
    local changed
    changed=$(git diff --name-only "${dev_commit}" "${ref}")
    changed=$(grep -vE "${ignored}" <<< "${changed}" || true)
    grep -vE "^release/1-[0-9]+/|^projects/[^/]+/[^/]+/1-[0-9]+/" <<< "${changed}" || true
    grep -E "^release/${release_branch}/development/|^projects/[^/]+/[^/]+/${release_branch}/" <<< "${changed}" \
        | grep -vE "${internal_outputs}" \
        || true
}

function pinned_tags() {
    local -r release_branch="$1"
    local -r platform_version="$2"
    local -r prefix="kubernetes-${release_branch}/releases/${platform_version}/artifacts/"
    local keys
    keys=$(aws s3api list-objects-v2 --bucket "${RELEASE_PR_DEV_RELEASE_BUCKET}" --prefix "${prefix}" \
        --query "Contents[].Key" --output text | tr '\t' '\n')

    local kubernetes ccm authenticator etcd
    kubernetes=$(grep -oE "^${prefix//./\\.}kubernetes/v[^/]+/" <<< "${keys}" | awk -F/ '{print $(NF-1)}' | sort -u | head -1 || true)
    ccm=$(grep -oE "^${prefix//./\\.}cloud-provider-aws/v[^/]+/" <<< "${keys}" | awk -F/ '{print $(NF-1)}' | sort -u | head -1 \
        | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
    authenticator=$(grep -oE "^${prefix//./\\.}aws-iam-authenticator/[^/]+/" <<< "${keys}" | awk -F/ '{print $(NF-1)}' | sort -u \
        | grep -E '^(v[0-9]|[0-9].*-v[0-9])' | sort -V | tail -1 || true)
    etcd=$(aws s3 cp "s3://${RELEASE_PR_DEV_RELEASE_BUCKET}/${prefix}etcd/.git_tag" - | tr -d '[:space:]')
    etcd=$("${REPO_ROOT}/projects/etcd-io/etcd/build/effective_git_tag.sh" "${release_branch}" "${etcd}")

    echo "kubernetes/kubernetes ${kubernetes}"
    echo "kubernetes/cloud-provider-aws ${ccm}"
    echo "kubernetes-sigs/aws-iam-authenticator ${authenticator}"
    echo "etcd-io/etcd ${etcd}"
}

# Prints "project committed=X pinned=Y" for each project whose committed GIT_TAG does not match the pinned artifacts.
function git_tag_mismatches() {
    local -r ref="$1"
    local -r release_branch="$2"
    local -r platform_version="$3"
    local tags project pinned committed
    tags=$(pinned_tags "${release_branch}" "${platform_version}")
    while read -r project pinned; do
        committed=$(release_pr::read_file "${ref}" "projects/${project}/${release_branch}/GIT_TAG")
        if [ "${committed}" != "${pinned}" ]; then
            echo "${project} committed=${committed:-none} pinned=${pinned:-none}"
        fi
    done <<< "${tags}"
}

# Prints the reason a branch cannot be prod released from ref, or nothing when it can.
function prod_blocker() {
    local -r ref="$1"
    local -r release_branch="$2"
    local -r dev_commit="$3"
    local -r dev_pin="$4"

    local dev_state build_state inputs mismatches
    dev_state=$(release_pr::job_state "${dev_commit}" "dev-release-${release_branch}-postsubmit")
    build_state=$(release_pr::job_state "${dev_commit}" "build-${release_branch}-postsubmit")
    if [ "${dev_state}" != "success" ] || [ "${build_state}" != "success" ]; then
        echo "the dev release commit ${dev_commit:0:12} has dev-release ${dev_state} and build ${build_state}"
        return 0
    fi

    inputs=$(changed_build_inputs "${dev_commit}" "${ref}" "${release_branch}")
    if [ -n "${inputs}" ]; then
        echo "build inputs changed after the dev release, so cut a new dev release first ($(release_pr::join ", " ${inputs}))"
        return 0
    fi

    mismatches=$(git_tag_mismatches "${ref}" "${release_branch}" "${dev_pin}")
    if [ -n "${mismatches}" ]; then
        echo "merge the internal-builds GIT_TAG PR first ($(release_pr::join "; " "${mismatches}"))"
        return 0
    fi
}

function release_key() {
    local entries=()
    local i
    for i in "${!BRANCHES[@]}"; do
        entries+=("${BRANCHES[$i]} ${PROD_RELEASES[$i]} ${PLATFORM_VERSIONS[$i]}")
    done
    echo "release-pr-key: $(release_pr::join ", " "${entries[@]}")"
}

function pr_body() {
    printf "Cuts prod releases from dev releases that passed their dev release and build postsubmits.\n\n"
    printf "| Release branch | Prod release | Platform version | Dev release commit |\n"
    printf "|---|---|---|---|\n"
    local i
    for i in "${!BRANCHES[@]}"; do
        printf "| %s | %s | %s | %s |\n" "${BRANCHES[$i]}" "${PROD_RELEASES[$i]}" "${PLATFORM_VERSIONS[$i]}" "${DEV_COMMITS[$i]}"
    done
    printf "\n"
    if [ "${#WAITING[@]}" -gt 0 ]; then
        printf "These branches are not included yet.\n\n"
        printf -- "- %s\n" "${WAITING[@]}"
        printf "\n"
    fi
    release_pr::job_logs_line
    printf "<!-- %s -->\n\n" "${RELEASE_PR_KEY}"
    printf "/hold\n\nBy submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice."
}

function pr_title() {
    echo "Bump prod releases: $(release_pr::join ", " "${BRANCHES[@]}")"
}

cd "${REPO_ROOT}"
release_pr::require_job
release_pr::fetch_main "${MAIN_BRANCH}"
MAIN_REF="upstream/${MAIN_BRANCH}"

INTERNAL_BUILDS_FILES=""
if [ "${DRY_RUN}" != "true" ]; then
    release_pr::setup
    INTERNAL_BUILDS_PR=$(release_pr::open_number "${INTERNAL_BUILDS_PR_BRANCH}")
    if [ -n "${INTERNAL_BUILDS_PR}" ]; then
        INTERNAL_BUILDS_FILES=$(release_pr::pr_files "${INTERNAL_BUILDS_PR}")
    fi
fi

BRANCHES=()
PROD_RELEASES=()
PLATFORM_VERSIONS=()
DEV_COMMITS=()
CHANGED_FILES=()
WAITING=()

for RELEASE_BRANCH in "${AUTOMATED_RELEASE_BRANCHES[@]}"; do
    PROD_RELEASE=$(release_pr::read_file "${MAIN_REF}" "release/${RELEASE_BRANCH}/production/RELEASE")
    DEV_COMMIT=$(release_pr::last_commit "${MAIN_REF}" "release/${RELEASE_BRANCH}/development/RELEASE")
    PROD_COMMIT=$(release_pr::last_commit "${MAIN_REF}" "release/${RELEASE_BRANCH}/production/RELEASE")
    if [ -z "${PROD_RELEASE}" ] || [ -z "${DEV_COMMIT}" ] || [ -z "${PROD_COMMIT}" ]; then
        echo "Skipping ${RELEASE_BRANCH} because it has no development or production RELEASE file"
        continue
    fi
    if git merge-base --is-ancestor "${DEV_COMMIT}" "${PROD_COMMIT}"; then
        echo "${RELEASE_BRANCH} prod release already follows its latest dev release"
        continue
    fi

    DEV_PIN=$(release_pr::read_file "${DEV_COMMIT}" "release/${RELEASE_BRANCH}/development/PLATFORM_VERSION")
    if [ -z "${DEV_PIN}" ]; then
        WAITING+=("${RELEASE_BRANCH}: the latest dev release has no development/PLATFORM_VERSION")
        continue
    fi
    if [[ ! "${DEV_PIN}" =~ ^eks\.[0-9]+$ ]]; then
        echo "Skipping ${RELEASE_BRANCH} because its dev release is custom release ${DEV_PIN}"
        continue
    fi

    if [ -n "${INTERNAL_BUILDS_FILES}" ] && grep -qE "^projects/[^/]+/[^/]+/${RELEASE_BRANCH}/" <<< "${INTERNAL_BUILDS_FILES}"; then
        WAITING+=("${RELEASE_BRANCH}: merge the open internal-builds GIT_TAG PR first")
        continue
    fi

    BLOCKER=$(prod_blocker "${MAIN_REF}" "${RELEASE_BRANCH}" "${DEV_COMMIT}" "${DEV_PIN}")
    if [ -n "${BLOCKER}" ]; then
        WAITING+=("${RELEASE_BRANCH}: ${BLOCKER}")
        continue
    fi

    echo "${RELEASE_BRANCH} moves to prod release $(( PROD_RELEASE + 1 )) on ${DEV_PIN}"
    BRANCHES+=("${RELEASE_BRANCH}")
    PROD_RELEASES+=("$(( PROD_RELEASE + 1 ))")
    PLATFORM_VERSIONS+=("${DEV_PIN}")
    DEV_COMMITS+=("${DEV_COMMIT:0:12}")
    CHANGED_FILES+=("release/${RELEASE_BRANCH}/production/RELEASE" "release/${RELEASE_BRANCH}/production/PLATFORM_VERSION")
done

if [ "${#WAITING[@]}" -gt 0 ]; then
    printf "%s\n" "${WAITING[@]}"
fi

if [ "${#BRANCHES[@]}" -eq 0 ]; then
    echo "No release branch is ready for a prod release"
    if [ "${DRY_RUN}" != "true" ]; then
        release_pr::close_stale "${PR_BRANCH}" "No release branch is ready for a prod release anymore, so this PR is no longer needed."
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

git checkout --detach "${MAIN_REF}"
for i in "${!BRANCHES[@]}"; do
    echo "${PROD_RELEASES[$i]}" > "release/${BRANCHES[$i]}/production/RELEASE"
    echo "${PLATFORM_VERSIONS[$i]}" > "release/${BRANCHES[$i]}/production/PLATFORM_VERSION"
done
release_pr::publish "${MAIN_BRANCH}" "${PR_BRANCH}" "${TITLE}" "${BODY}" "${CHANGED_FILES[@]}"

echo "===== Ending ${BASH_SOURCE[0]} ====="
