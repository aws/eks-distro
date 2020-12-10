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
export KOPS_STATE_STORE=${1:-${KOPS_STATE_STORE}}
if [ -z "${KOPS_STATE_STORE}" ]
then
  echo "Usage: ${0} s3://bucketname"
  echo "  or set and export KOPS_STATE_STORE"
  exit 1
fi
unset KOPS_CLUSTER_NAME
BUCKET_NAME=$(echo "${KOPS_STATE_STORE}" | sed -e 's,s3://,,g')
echo "Deleting cluster $KOPS_STATE_STORE"
kops get cluster --state "${KOPS_STATE_STORE}" |
  tail -n +2 |
  cut -f1 -d '  ' |
  while read NAME
  do
    set -x
    kops delete cluster --state "${KOPS_STATE_STORE}" --name "${NAME}" --yes || true
    set +x
  done
set -x
aws s3 rm --recursive "${KOPS_STATE_STORE}" || true
aws s3api delete-bucket --bucket "${BUCKET_NAME}"
