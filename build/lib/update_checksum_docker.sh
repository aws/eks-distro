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

PROJECT="$1"
RELEASE_BRANCH="$2"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

$MAKE_ROOT/build/lib/run_target_docker.sh $PROJECT "clean binaries checksums" $RELEASE_BRANCH

PROJECT_CHECKSUM=$PROJECT/CHECKSUMS

if [ -d $MAKE_ROOT/projects/$PROJECT/$RELEASE_BRANCH ]; then
	PROJECT_CHECKSUM=$PROJECT/$RELEASE_BRANCH/CHECKSUMS
fi

docker cp eks-d-builder:/eks-distro/projects/$PROJECT_CHECKSUM $MAKE_ROOT/projects/$PROJECT_CHECKSUM
