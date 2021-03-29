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

# In prow we have occasional dns issues after a cluster has been created
# Wait for 60 seconds giving both dns pods a chance to get the latest
# ip for the api server.  Printing out the results to potentially
# make debugging easier

set -eo pipefail
BASEDIR=$(dirname "$0")
echo "This script will create a cluster"
cd "$BASEDIR"
source ./set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1

APISERVER="api.$KOPS_CLUSTER_NAME"
for i in {1..12}
do
  echo "$APISERVER resolves to $(dig +short $APISERVER)"
  sleep 5s
done
