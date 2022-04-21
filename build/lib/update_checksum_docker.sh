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
IMAGE_REPO="$2"
RELEASE_BRANCH="${3:-}"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

$MAKE_ROOT/build/lib/run_target_docker.sh $PROJECT "binaries attribution checksums" $IMAGE_REPO $RELEASE_BRANCH

PROJECT_CHECKSUM=$PROJECT/CHECKSUMS
PROJECT_ATTRIBUTION=$PROJECT/ATTRIBUTION.txt

if [[ ! -z "$RELEASE_BRANCH" ]] && [ -d $MAKE_ROOT/projects/$PROJECT/$RELEASE_BRANCH ]; then
	PROJECT_CHECKSUM=$PROJECT/$RELEASE_BRANCH/CHECKSUMS
	PROJECT_ATTRIBUTION=$PROJECT/$RELEASE_BRANCH/ATTRIBUTION.txt
fi

docker cp eks-d-builder:/eks-distro/projects/$PROJECT_CHECKSUM $MAKE_ROOT/projects/$PROJECT_CHECKSUM
docker cp eks-d-builder:/eks-distro/projects/$PROJECT_ATTRIBUTION $MAKE_ROOT/projects/$PROJECT_ATTRIBUTION
