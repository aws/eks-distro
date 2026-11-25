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

RELEASE_PR_ORIGIN_ORG="eks-distro-pr-bot"
RELEASE_PR_UPSTREAM_REPO="aws/eks-distro"
RELEASE_PR_GITHUB_TOKEN_FILE="/secrets/github-secrets/token"
# shellcheck disable=SC2034
RELEASE_PR_DEV_RELEASE_BUCKET="eks-distro-dev-release-artifacts"

function release_pr::require_job() {
    if [ "${DRY_RUN:-false}" != "true" ] && [ -z "${JOB_TYPE:-}" ]; then
        echo "Not running in a Prow job, so nothing is pushed. Set DRY_RUN=true to preview."
        exit 0
    fi
}

function release_pr::fetch_main() {
    local -r main_branch="$1"
    git config remote.upstream.url >&- || git remote add upstream "https://github.com/${RELEASE_PR_UPSTREAM_REPO}.git"
    build::common::echo_and_run retry git fetch upstream "${main_branch}"
}

function release_pr::join() {
    local -r separator="$1"
    shift
    local joined
    joined=$(printf "${separator}%s" "$@")
    echo "${joined:${#separator}}"
}

function release_pr::github_api() {
    local -r path="$1"
    local response status
    if [ -r "${RELEASE_PR_GITHUB_TOKEN_FILE}" ]; then
        response=$(printf 'header = "Authorization: token %s"\n' "$(cat "${RELEASE_PR_GITHUB_TOKEN_FILE}")" \
            | curl -sS --config - -w '\n%{http_code}' "https://api.github.com/${path}")
    else
        response=$(curl -sS -w '\n%{http_code}' "https://api.github.com/${path}")
    fi
    status="${response##*$'\n'}"
    if [ "${status}" == "403" ] || [ "${status}" == "429" ]; then
        echo "ERROR: GitHub API rate limit reached for ${path}. Retest later." >&2
        return 1
    fi
    if [ "${status}" -lt 200 ] || [ "${status}" -ge 300 ]; then
        echo "ERROR: GitHub API returned HTTP ${status} for ${path}" >&2
        return 1
    fi
    echo "${response%$'\n'*}"
}

function release_pr::job_state() {
    local -r sha="$1"
    local -r context="$2"
    local statuses
    statuses=$(release_pr::github_api "repos/${RELEASE_PR_UPSTREAM_REPO}/commits/${sha}/status?per_page=100")
    jq -r --arg context "${context}" '[.statuses[] | select(.context == $context) | .state][0] // "missing"' <<< "${statuses}"
}

function release_pr::last_commit() {
    local -r ref="$1"
    local -r path="$2"
    git log -1 --format=%H "${ref}" -- "${path}"
}

function release_pr::read_file() {
    local -r ref="$1"
    local -r path="$2"
    if git cat-file -e "${ref}:${path}" 2>/dev/null; then
        git show "${ref}:${path}" | tr -d '[:space:]'
    fi
}

function release_pr::job_logs_line() {
    if [ -n "${JOB_SPEC:-}" ]; then
        local prow_bucket
        prow_bucket=$(jq -r ".decoration_config.gcs_configuration.bucket" <<< "${JOB_SPEC}" | awk -F// '{print $NF}')
        printf "Click [here](https://prow.eks.amazonaws.com/view/s3/%s/logs/%s/%s) to view job logs.\n\n" \
            "${prow_bucket}" "${JOB_NAME}" "${BUILD_ID}"
    fi
}

function release_pr::setup() {
    git config --global push.default current
    git config user.name "EKS Distro PR Bot"
    git config user.email "aws-model-rocket-bots+eksdistroprbot@amazon.com"
    git config remote.origin.url >&- || git remote add origin "git@github.com:${RELEASE_PR_ORIGIN_ORG}/eks-distro.git"
    gh auth login --with-token < "${RELEASE_PR_GITHUB_TOKEN_FILE}"
}

function release_pr::open_number() {
    local -r pr_branch="$1"
    gh pr list --repo "${RELEASE_PR_UPSTREAM_REPO}" --author "${RELEASE_PR_ORIGIN_ORG}" --head "${pr_branch}" \
        --state open --json number --jq ".[0].number // empty"
}

function release_pr::pr_files() {
    local -r pr_number="$1"
    gh api --paginate "repos/${RELEASE_PR_UPSTREAM_REPO}/pulls/${pr_number}/files?per_page=100" --jq ".[].filename"
}

# Prints "yes" when a person closed an unmerged bot PR with this title, ignoring PRs the bot closed itself.
function release_pr::was_rejected() {
    local -r pr_branch="$1"
    local -r key="$2"
    local closed numbers number closer
    closed=$(gh pr list --repo "${RELEASE_PR_UPSTREAM_REPO}" --author "${RELEASE_PR_ORIGIN_ORG}" --head "${pr_branch}" \
        --state closed --limit 20 --json number,body,mergedAt)
    numbers=$(jq -r --arg key "<!-- ${key} -->" '.[] | select((.body | contains($key)) and .mergedAt == null) | .number' <<< "${closed}")
    for number in ${numbers}; do
        closer=$(gh api "repos/${RELEASE_PR_UPSTREAM_REPO}/issues/${number}/events?per_page=100" \
            --jq '[.[] | select(.event == "closed")] | last | .actor.login')
        if [ "${closer}" != "${RELEASE_PR_ORIGIN_ORG}" ]; then
            echo "yes"
            return 0
        fi
    done
    echo "no"
}

function release_pr::close_stale() {
    local -r pr_branch="$1"
    local -r reason="$2"
    local pr_number
    pr_number=$(release_pr::open_number "${pr_branch}")
    if [ -n "${pr_number}" ]; then
        gh pr close "${pr_number}" --repo "${RELEASE_PR_UPSTREAM_REPO}" --comment "${reason}"
    fi
}

# Callers write every file on a detached checkout of upstream main before calling this.
# Prints new_body with every checklist item ticked that is ticked with identical text in old_body.
function release_pr::keep_checked() {
    local -r old_body="$1"
    local -r new_body="$2"
    awk 'NR == FNR { if (sub(/^- \[[xX]\] /, "")) done[$0] = 1; next }
        { line = $0; if (sub(/^- \[ \] /, "", line) && (line in done)) $0 = "- [x] " line; print }' \
        <(printf '%s\n' "${old_body}" | tr -d '\r') <(printf '%s\n' "${new_body}")
}

function release_pr::publish() {
    local -r main_branch="$1"
    local -r pr_branch="$2"
    local -r title="$3"
    local body="$4"
    shift 4
    local -r files=("$@")

    git checkout -B "${pr_branch}"
    git add "${files[@]}"
    git commit -m "[PR BOT] ${title}"

    local pr_number rejected current_body
    pr_number=$(release_pr::open_number "${pr_branch}")
    if [ -n "${pr_number}" ]; then
        current_body=$(gh pr view "${pr_number}" --repo "${RELEASE_PR_UPSTREAM_REPO}" --json body --jq .body)
        body=$(release_pr::keep_checked "${current_body}" "${body}")
    fi

    if [ -n "${pr_number}" ] \
        && git fetch "https://github.com/${RELEASE_PR_ORIGIN_ORG}/eks-distro.git" "${pr_branch}" \
        && git diff --quiet FETCH_HEAD HEAD -- release/ "${files[@]}" ':(exclude)docs/contents/index.md'; then
        echo "PR #${pr_number} is already open with these changes"
        return 0
    fi

    if [ -z "${pr_number}" ]; then
        rejected=$(release_pr::was_rejected "${pr_branch}" "${RELEASE_PR_KEY}")
        if [ "${rejected}" == "yes" ]; then
            echo "A reviewer closed a PR for ${RELEASE_PR_KEY} without merging it, so it is not reopened"
            return 0
        fi
    fi

    ssh-agent bash -c "ssh-add /secrets/ssh-secrets/ssh-key; ssh -o StrictHostKeyChecking=no git@github.com; git push -u origin ${pr_branch} -f"

    if [ -z "${pr_number}" ]; then
        gh pr create --repo "${RELEASE_PR_UPSTREAM_REPO}" --base "${main_branch}" \
            --head "${RELEASE_PR_ORIGIN_ORG}:${pr_branch}" --title "${title}" --body "${body}"
    else
        gh pr edit "${pr_number}" --repo "${RELEASE_PR_UPSTREAM_REPO}" --title "${title}" --body "${body}"
        gh pr comment "${pr_number}" --repo "${RELEASE_PR_UPSTREAM_REPO}" --body "/hold"
    fi
}
