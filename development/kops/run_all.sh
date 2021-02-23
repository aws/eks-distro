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
cd ${BASEDIR}

function cleanup()
{
  echo 'Deleting...'
  ./delete_cluster.sh || true
  ./delete_store.sh
  exit 255;
}

echo "This script will create a cluster, run tests and tear it down"
source ./set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1
./install_requirements.sh
if [[ "${KOPS_STATE_STORE}" != "" ]]; then
  for cluster_name in $(aws s3 ls ${KOPS_STATE_STORE}); do
    if [[ "${cluster_name}" == "${RELEASE_BRANCH}-"* ]]; then
      cluster_fqdn="$(echo ${cluster_name}|tr -d "/")"
      echo "Deleting cluster ${cluster_fqdn}"
      ${KOPS} delete cluster --state "${KOPS_STATE_STORE}" --name ${cluster_fqdn} --yes || true
      aws s3 rm --recursive "${KOPS_STATE_STORE}/${cluster_name}" || true
    fi
  done
fi
trap cleanup SIGINT SIGTERM ERR
./create_values_yaml.sh
./create_configuration.sh
./create_cluster.sh
./set_nodeport_access.sh
./cluster_wait.sh
./validate_eks.sh
./run_sonobuoy.sh
./delete_cluster.sh || true
./delete_store.sh
