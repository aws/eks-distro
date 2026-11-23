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
CONFORMANCE_MODE=${CONFORMANCE_MODE:-certified}
CONFORMANCE_PARALLEL_PROCS=${CONFORMANCE_PARALLEL_PROCS:-20}
SERIAL_TESTS_REGEX='\[Serial\]|\[Disruptive\]|\[Slow\]|Garbage.collector'
echo "Testing cluster ${KOPS_CLUSTER_NAME} with conformance mode ${CONFORMANCE_MODE}"

function start_sonobuoy() {
  local count=0
  while ! sonobuoy --context ${KOPS_CLUSTER_NAME} run --mode=certified-conformance --wait --kube-conformance-image ${CONFORMANCE_IMAGE} "$@"
  do
    sonobuoy --context ${KOPS_CLUSTER_NAME} delete --all --wait||true
    sleep 5
    count=$(expr $count + 1)
    if [ $count -gt 3 ]
    then
      echo "Failed to run sonobuoy"
      exit 1
    fi
    echo 'Waiting for the cluster to be ready...'
  done
}

results=''
function save_results() {
  local artifact_dir=$1
  local results_dir=$2

  results=$(sonobuoy --context ${KOPS_CLUSTER_NAME} retrieve)
  mv $results "./${KOPS_CLUSTER_NAME}/$results"
  results="./${KOPS_CLUSTER_NAME}/$results"
  mkdir -p $results_dir
  tar xzf $results -C $results_dir
  if [ -w /logs/artifacts ]
  then
    mkdir -p /logs/artifacts/$artifact_dir
    cp $results_dir/plugins/e2e/results/global/* /logs/artifacts/$artifact_dir
  fi

  sonobuoy results --plugin e2e ${results}
  if sonobuoy results --plugin e2e ${results} | grep 'Status: passed'; then
    return 0
  else
    return 1
  fi
}

function run_conformance() {
  local phase=$1
  shift
  local artifact_prefix=$NODE_ARCHITECTURE${phase:+-$phase}
  local results_dir=./${KOPS_CLUSTER_NAME}/results${phase:+-$phase}

  start_sonobuoy "$@"

  local count=1
  while ! save_results $artifact_prefix-$count $results_dir; do
    # retry failed conformance tests up to 3 times
    echo "Rerunning failed conformace tests"
    count=$(expr $count + 1)
    if [ $count -gt 4 ]; then
      echo "Conformance test still failing after reruns"
      exit 1
    fi
    sonobuoy --context ${KOPS_CLUSTER_NAME} delete --all --wait
    sonobuoy --context ${KOPS_CLUSTER_NAME} run --rerun-failed ${results} --wait --kube-conformance-image ${CONFORMANCE_IMAGE}
  done
  sonobuoy --context ${KOPS_CLUSTER_NAME} delete --all --wait || true
}

case $CONFORMANCE_MODE in
  certified)
    run_conformance ""
    ;;
  split)
    run_conformance parallel \
      --e2e-skip="${SERIAL_TESTS_REGEX}" \
      --plugin-env=e2e.E2E_EXTRA_GINKGO_ARGS=--procs=${CONFORMANCE_PARALLEL_PROCS}
    run_conformance serial \
      --e2e-focus="(${SERIAL_TESTS_REGEX}).*\[Conformance\]"
    ;;
  *)
    echo "Unknown CONFORMANCE_MODE ${CONFORMANCE_MODE}, expected certified or split"
    exit 1
    ;;
esac
