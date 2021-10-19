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

set -eo pipefail

BASEDIR=$(dirname "$0")
source ${BASEDIR}/set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1

echo "Deleting kops store $KOPS_STATE_STORE"
set -x
aws s3 rm --recursive "${KOPS_STATE_STORE}/${KOPS_CLUSTER_NAME}" || true
if [ -n "${KOPS_CLUSTER_NAME}" ]
then
  rm -rf "./${KOPS_CLUSTER_NAME}"
fi
