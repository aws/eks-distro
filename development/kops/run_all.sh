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

function cleanup()
{
  echo 'Deleting...'
  ./delete_cluster.sh || true
  ./delete_store.sh
  exit 255;
}

set -exo pipefail
BASEDIR=$(dirname "$0")
echo "This script will create a cluster, run tests and tear it down"
cd "$BASEDIR"
source ./create_store_name.sh
source ./set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1
./install_requirements.sh
trap cleanup SIGINT SIGTERM ERR EXIT
./create_values_yaml.sh
./create_configuration.sh
./create_cluster.sh
./set_nodeport_access.sh
./cluster_wait.sh
./run_sonobuoy.sh
