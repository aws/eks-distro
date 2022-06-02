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
set -o pipefail
set -x

PR_BRANCH="${1?...}"
PR_COMMIT_MESSAGE="${2?...}"
VERSION_FOR_LABEL="${3?...}"

echo "VERSION_FOR_LABEL: $VERSION_FOR_LABEL"

PR_REPO="eks-distro"
ORIGIN_ORG=$(git remote get-url origin | sed -n -e "s|git@github.com:\(.*\)/${PR_REPO}.git|\1|p")

PR_BODY=$(cat <<EOF
${PR_COMMIT_MESSAGE}

By submitting this pull request, I confirm that you can use, modify, copy, and redistribute this contribution, under the terms of your choice.
EOF
)

PR_TITLE="${PR_COMMIT_MESSAGE}"

pr_arguments=(
  --title "${PR_TITLE}"
  --body "${PR_BODY}"
  --head "${ORIGIN_ORG}:${PR_BRANCH}"
  --repo "aws/${PR_REPO}"
  --web
)

labels="do-not-merge/hold release v$VERSION_FOR_LABEL"
for label in $labels; do
     pr_arguments+=(--label "${label}")
done

echo "pushing..."
git push origin "${PR_BRANCH}"
echo "pushed!"

gh pr create "${pr_arguments[@]}"
