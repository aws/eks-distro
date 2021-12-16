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

# Add IAM configmap
COUNT=0
echo 'Waiting for cluster to come up...'
while ! kubectl --context $KOPS_CLUSTER_NAME apply -f ./${KOPS_CLUSTER_NAME}/aws-iam-authenticator.yaml
do
    sleep 5
    COUNT=$(expr $COUNT + 1)
    if [ $COUNT -gt 120 ]
    then
        echo "Failed to configure IAM"
        exit 1
    fi
    echo 'Waiting for cluster to come up...'
done

# In kops 1-21 the metrics addon is not configurable enough for 1.18 based clusters
# manually add -kubelet-insecure-tls
# https://github.com/kubernetes/kops/blob/v1.21.0-beta.3/upup/models/cloudup/resources/addons/metrics-server.addons.k8s.io/k8s-1.11.yaml.template#L140
# UseKopsControllerForNodeBootstrap is only true when 1.19 and above
if [ "${RELEASE_BRANCH}" == "1-18" ]; then
    PATCH='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls" }]'
    while ! kubectl --context $KOPS_CLUSTER_NAME  -n kube-system patch deployments metrics-server --type=json -p="$PATCH"
    do
        sleep 5
        COUNT=$(expr $COUNT + 1)
        if [ $COUNT -gt 120 ]
        then
            echo "Failed to configure metrics server"
            exit 1
        fi
        echo 'Waiting for cluster to come up...'
    done
fi

set -x
${KOPS} validate cluster --wait 15m
