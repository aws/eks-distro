#!/usr/bin/env bash
# Copyright 2021 Amazon.com Inc. or its affiliates. All Rights Reserved.
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

RELEASE_BRANCH="${1?First argument is release branch for example 1-18}"
RELEASE="${2?Second argument is release for example 1}"
ARTIFACT_BUCKET="${3?Third argument is artifact bucket name}"

DEST_DIR=kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts
aws s3 sync $DEST_DIR s3://${ARTIFACT_BUCKET}/${DEST_DIR} --acl public-read
