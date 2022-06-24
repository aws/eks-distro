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

# Generates release on GitHub.
# IMPORTANT!! GIT_TAG for release must already exist.
set -e
set -o pipefail
set -x

GIT_TAG="${1?...}"
VERSION="${2?...}"
CHANGELOG_FILEPATH="${3?...}"
INDEX_FILEPATH="${4?...}"

# Removes the first to lines to get rid of H1 headers and an empty line.
# The H1 headers are larger than the release titles on GitHub, and it
# looks confusing with them.
releaseNotes="$(sed '1,2d' "$CHANGELOG_FILEPATH")

$(sed '1,2d' "$INDEX_FILEPATH")"

gh release create "$GIT_TAG" --title "EKS Distro $VERSION Release" --notes "$releaseNotes"
