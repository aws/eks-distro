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

REPOSITORY_NAME="${1}"
QUERY='[.imageDetails[] | select(.imageTags != null)] | sort_by(.imagePushedAt)|reverse|first|.imageTags[0]'
TAG=$(aws --region us-east-1 ecr-public  describe-images \
          --repository-name "${REPOSITORY_NAME}" | \
          jq -r "${QUERY}")
echo ${TAG}
