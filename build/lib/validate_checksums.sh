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

set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT="$1"
OUTPUT_BIN_DIR="$2"
RELEASE_BRANCH="$3"

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

cd $PROJECT_ROOT

CHECKSUMS_FILE=$PROJECT_ROOT/CHECKSUMS

if [ -d $PROJECT_ROOT/$RELEASE_BRANCH ]; then
	CHECKSUMS_FILE=$PROJECT_ROOT/$RELEASE_BRANCH/CHECKSUMS
fi

if ! sha256sum -c $CHECKSUMS_FILE; then
	echo "Checksums do not match!"
	echo "The correct checksums are printed below"
	echo "Please only update if changing GIT_TAG or build flags."
	$SCRIPT_ROOT/update_checksums.sh $PROJECT_ROOT $OUTPUT_BIN_DIR $RELEASE_BRANCH
	exit 1
fi
