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


function retry {
  local n=1
  local max=120
  local delay=5
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
    retry kubectl --context $KOPS_CLUSTER_NAME "$@"
}

# Add IAM configmap
echo 'Waiting for cluster to come up...'
k apply -f ./${KOPS_CLUSTER_NAME}/aws-iam-authenticator.yaml

# kops installs an older metrics server
# than we ship with EKS-D, along with an older clusterrole def. The 0.6 version
# of metrics requires a slightly different rbac setup.
k apply -f metrics-server-0.6-clusterrole.yaml

# kops doesnt support setting these cilium values
# session affinity for conformance tess
# kube-proxy disabled to make sure we are validating our kube-proxy
# k -n kube-system patch cm/cilium-config --type merge -p '{"data":{"enable-session-affinity":"true"}}'
# k -n kube-system rollout restart deployment/cilium-operator
# k -n kube-system rollout status deployment/cilium-operator --timeout=30s
# k -n kube-system delete pods -lk8s-app=cilium

set -x
${KOPS} validate cluster --wait 15m

# --set ipam.mode="kubernetes" 
