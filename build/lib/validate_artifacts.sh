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

set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT="$1"
ARTIFACTS_FOLDER="$2"
GIT_TAG="$3"
FAKE_ARM_ARTIFACTS_FOR_VALIDATION="$4"

EXPECTED_FILES_PATH=$PROJECT_ROOT/expected_artifacts
if [[ $ARTIFACTS_FOLDER == *images ]]; then
	EXPECTED_FILES_PATH=$PROJECT_ROOT/expected_images
fi

ACTUAL_FILES=$(mktemp)

find ${ARTIFACTS_FOLDER} -type f -print0 | sort -z | while IFS= read -r -d '' file; do
    filepath=$(realpath --relative-base=$ARTIFACTS_FOLDER "$file")
	echo "$filepath" >> "$ACTUAL_FILES"
done

EXPECTED_FILES=$(mktemp)
export GIT_TAG=$GIT_TAG
envsubst '$GIT_TAG' \
	< "$EXPECTED_FILES_PATH" \
	| sort \
	> "$EXPECTED_FILES"

if $FAKE_ARM_ARTIFACTS_FOR_VALIDATION; then
	sed -i '/arm64/d' "$EXPECTED_FILES"
fi

if ! diff "$EXPECTED_FILES" "$ACTUAL_FILES"; then
	echo "Artifacts directory does not match expected!"
	echo "******************* Actual ******************"
	cat "$ACTUAL_FILES"
	echo "*********************************************"
	exit 1
fi