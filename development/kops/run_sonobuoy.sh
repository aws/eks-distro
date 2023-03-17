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

CONFORMANCE_IMAGE=registry.k8s.io/conformance:${KUBERNETES_VERSION}
echo "Testing cluster ${KOPS_CLUSTER_NAME}"

COUNT=0
while ! sonobuoy --context ${KOPS_CLUSTER_NAME} run --mode=certified-conformance --wait --kube-conformance-image ${CONFORMANCE_IMAGE}
do
  sonobuoy --context ${KOPS_CLUSTER_NAME} delete --all --wait||true
  sleep 5
  COUNT=$(expr $COUNT + 1)
  if [ $COUNT -gt 3 ]
  then
    echo "Failed to run sonobuoy"
    exit 1
  fi
  echo 'Waiting for the cluster to be ready...'
done

results=''
function save_results() {
  local run=$1
  
  results=$(sonobuoy --context ${KOPS_CLUSTER_NAME} retrieve)
  mv $results "./${KOPS_CLUSTER_NAME}/$results"
  results="./${KOPS_CLUSTER_NAME}/$results"
  mkdir -p ./${KOPS_CLUSTER_NAME}/results
  tar xzf $results -C ./${KOPS_CLUSTER_NAME}/results
  if [ -w /logs/artifacts ]
  then
    mkdir -p /logs/artifacts/$NODE_ARCHITECTURE-$run
    cp ./${KOPS_CLUSTER_NAME}/results/plugins/e2e/results/global/* /logs/artifacts/$NODE_ARCHITECTURE-$run
  fi

  sonobuoy results --plugin e2e ${results}
  if sonobuoy results --plugin e2e ${results} | grep 'Status: passed'; then
    return 0
  else
    return 1
  fi
}

COUNT=1
while ! save_results $COUNT; do
  # retry failed conformance tests up to 3 times
  echo "Rerunning failed conformace tests"
  COUNT=$(expr $COUNT + 1)
  if [ $COUNT -gt 4 ]; then
    echo "Conformance test still failing after reruns"
    exit 1
  fi
  sonobuoy --context ${KOPS_CLUSTER_NAME} delete --all --wait
  sonobuoy --context ${KOPS_CLUSTER_NAME} run --rerun-failed ${results} --wait --kube-conformance-image ${CONFORMANCE_IMAGE}  
done
