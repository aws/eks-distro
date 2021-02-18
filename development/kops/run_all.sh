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

set -exo pipefail
BASEDIR=$(dirname "$0")

function cleanup()
{
  echo 'Deleting...'
  ${BASEDIR}/delete_cluster.sh || true
  ${BASEDIR}/delete_store.sh
  exit 255;
}

echo "This script will create a cluster, run tests and tear it down"
cd "$BASEDIR"
source ${BASEDIR}/set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1
${BASEDIR}/install_requirements.sh
trap cleanup SIGINT SIGTERM ERR
${BASEDIR}/create_values_yaml.sh
${BASEDIR}/create_configuration.sh
${BASEDIR}/create_cluster.sh
${BASEDIR}/set_nodeport_access.sh
${BASEDIR}/cluster_wait.sh
${BASEDIR}/validate_eks.sh
${BASEDIR}/run_sonobuoy.sh
${BASEDIR}/delete_cluster.sh || true
${BASEDIR}/delete_store.sh
