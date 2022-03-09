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

# In kops 1-22 metrics was updated and the port was changed to 443 from 4443. In the verison of metrics server we ship for kube versions < 1-22, it does not support binding to 443
# patching back to old port and behavior
if [ "${RELEASE_BRANCH}" != "1-22" ]; then
    PATCH='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--secure-port=4443" },{"op": "replace", "path": "/spec/template/spec/containers/0/ports/0/containerPort", "value": 4443 }]'
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

# kops 1-22 installs an older metrics server than we ship with eksd 1.22 along with an older clusterrole def.  The 0.6 version of metrics requires a slightly different rbac setup
# Appling the clusterrole from the metrics repo fixes the permissions
if [ "${RELEASE_BRANCH}" == "1-22" ]; then
    kubectl --context $KOPS_CLUSTER_NAME apply -f metrics-server-0.6-clusterrole.yaml
fi

# We do not let kops install the cni, instead we install the eks-a cilium build to better match eksa
export HELM_EXPERIMENTAL_OCI=1
CILIUM_REGISTRY="public.ecr.aws/isovalent"
CILIUM_TAG="v1.9.13-eksa.2"
helm install cilium oci://$CILIUM_REGISTRY/cilium  --version ${CILIUM_TAG#"v"} --namespace kube-system  \
    --set operator.image.tag=$CILIUM_TAG --set image.tag=$CILIUM_TAG \
    --set image.repository="$CILIUM_REGISTRY/cilium" --set operator.image.repository="$CILIUM_REGISTRY/operator" \
    --set cni.chainingMode="portmap" --set rollOutCiliumPods=true

set -x
${KOPS} validate cluster --wait 15m
