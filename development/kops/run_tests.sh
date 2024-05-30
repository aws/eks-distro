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

function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=5
  local delay=1
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

function k {
    retry kubectl --context ${KOPS_CLUSTER_NAME} "$@"
}

function node_driver_registrar_expect {
    echo "node_driver_registrar_expect"
    k logs --selector app=csi-mockplugin --container node-driver-registrar  | \
        grep "Registration Server started"
}

function liveness_probe_expect {
    echo "liveness_probe_expect"
    k logs --selector app=csi-mockplugin --container liveness-probe | \
        grep "io.kubernetes.storage.mock"
}

function provisioning_expect {
    echo "provisioning_expect"
    [ $(k get events --field-selector involvedObject.name=example-pvc,reason=ProvisioningSucceeded | wc -l) -ge 1 ]
}

function attach_expect {
    echo "attach_expect"
    k logs --selector app=csi-mockplugin --container csi-attacher | \
        grep "Fully attached"
}

function resize_expect {
    echo "resize_expect"
    [ $(k get events --field-selector involvedObject.name=example-pvc,reason=VolumeResizeSuccessful | wc -l) -ge 1 ]    
}

function validate_csi {
    # Launch mock csi driver and validate all sidecars launch and trigger specific
    # events and/or log messages
    # Not a full suite but at least verifies all containers launch and 
    # executes some of the flows

    ${KOPS} toolbox template --template ${BASEDIR}/tests/csi/deploy/csi-mock-driver-deployment.yaml.tpl \
        --values ./${KOPS_CLUSTER_NAME}/values.yaml > "./${KOPS_CLUSTER_NAME}/csi-mock-driver-deployment.yaml"

    k apply -f ${BASEDIR}/tests/csi/deploy/csi-mock-driver-rbac.yaml

    k apply -f "./${KOPS_CLUSTER_NAME}/csi-mock-driver-deployment.yaml"

    k wait deploy/csi-mockplugin --for condition=available --timeout=5m
    
    retry node_driver_registrar_expect
    retry liveness_probe_expect

    k apply -f "tests/csi/pvc-test.yaml"
    retry provisioning_expect
    
    k apply -f tests/csi/pod-test.yaml 
    k wait pod/web-server --for condition=ready --timeout=5m
    retry attach_expect

    k patch pvc example-pvc -p '{"spec":{"resources":{"requests":{"storage": "2Mi"}}}}'  
    retry resize_expect

}

function etcd_expect {
    echo "etcd_expect"
    [ $(k exec etcd0  -- etcdctl --endpoints=http://etcd0:2379 member list | wc -l) = 3 ]
}

function validate_etcd {
    # Not a full suite
    # Launch a 3 node etcd cluster using etcd images to validate they launch correctly
    
    ${KOPS} toolbox template --template ${BASEDIR}/tests/etcd/deploy/etcd.yaml.tpl \
        --values ./${KOPS_CLUSTER_NAME}/values.yaml > "./${KOPS_CLUSTER_NAME}/etcd.yaml"
    
    k apply -f "./${KOPS_CLUSTER_NAME}/etcd.yaml"
    k wait pod/etcd0 --for condition=ready --timeout=5m
    k wait pod/etcd1 --for condition=ready --timeout=5m
    k wait pod/etcd2 --for condition=ready --timeout=5m
    retry etcd_expect

}

validate_csi
validate_etcd
