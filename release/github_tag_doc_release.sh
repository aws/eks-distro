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

REPO="aws/eks-distro"
GITHUB_TOKEN_FILE="/secrets/github-secrets/token"
BASE_DIRECTORY=$(git rev-parse --show-toplevel)
cd "${BASE_DIRECTORY}"

if [ -z "${PULL_BASE_SHA:-}" ]; then
  echo "Must be run in a Prowjob for access to PULL_BASE_SHA" >&2
  exit 1
fi
GH_TOKEN=$(cat "${GITHUB_TOKEN_FILE}")
export GH_TOKEN

function tag_commit() {
  local -r tag="$1"
  local existing tag_object
  existing=$(gh api "repos/${REPO}/git/ref/tags/${tag}" --jq .object.sha 2>/dev/null || true)
  if [ -n "${existing}" ]; then
    existing=$(gh api "repos/${REPO}/git/tags/${existing}" --jq .object.sha 2>/dev/null || echo "${existing}")
    if [ "${existing}" != "${PULL_BASE_SHA}" ]; then
      echo "Tag ${tag} already exists on ${existing}, not ${PULL_BASE_SHA}" >&2
      return 1
    fi
    echo "Tag ${tag} already exists on ${PULL_BASE_SHA}"
    return 0
  fi
  tag_object=$(gh api "repos/${REPO}/git/tags" -f tag="${tag}" -f message="${tag}" \
    -f object="${PULL_BASE_SHA}" -f type=commit --jq .sha)
  gh api "repos/${REPO}/git/refs" -f ref="refs/tags/${tag}" -f sha="${tag_object}" > /dev/null
  echo "Created tag ${tag} on ${PULL_BASE_SHA}"
}

ANNOUNCEMENTS=$(git diff --name-only HEAD^ HEAD | grep -E '^docs/contents/releases/1-[0-9]+/[0-9]+/release-announcement\.txt$' || true)
for ANNOUNCEMENT in ${ANNOUNCEMENTS}; do
  DOCS_DIRECTORY=$(dirname "${ANNOUNCEMENT}")
  RELEASE_NUMBER=$(basename "${DOCS_DIRECTORY}")
  RELEASE_BRANCH=$(basename "$(dirname "${DOCS_DIRECTORY}")")
  RELEASE_TAG="v${RELEASE_BRANCH}-eks-${RELEASE_NUMBER}"

  tag_commit "${RELEASE_TAG}"

  if gh release view "${RELEASE_TAG}" --repo "${REPO}" > /dev/null 2>&1; then
    echo "GitHub release ${RELEASE_TAG} already exists"
    continue
  fi
  bash "${BASE_DIRECTORY}/cmd/release/gh-release/create.sh" "${RELEASE_TAG}" \
    "${DOCS_DIRECTORY}/CHANGELOG-${RELEASE_TAG}.md" "${DOCS_DIRECTORY}/index.md"
done
