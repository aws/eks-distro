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

set -euxo pipefail

RELEASE_BRANCH="${1?First required argument is release branch for example 1-18}"
NEW_RELEASE="${2?Second required argument is release for example 1}"
IS_ONLY_IMAGE_UPDATE="${3:-"false"}"


### Checking docs/contents/releases/${RELEASE_BRANCH}/
release_docs_dir=${BASE_DIRECTORY}/docs/contents/releases/${RELEASE_BRANCH}/${NEW_RELEASE}
mkdir "${release_docs_dir}"
touch ${release_docs_dir}/release-notification.txt
# TODO: generate release text
