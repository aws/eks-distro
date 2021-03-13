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

set -eo pipefail

BASEDIR=$(dirname "$0")
source ${BASEDIR}/set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1

mkdir -p "./${KOPS_CLUSTER_NAME}"
if [ -f "./${KOPS_CLUSTER_NAME}/values.yaml" ]; then
    echo -e "Error the ./${KOPS_CLUSTER_NAME}/values.yaml file already exists."
    echo -e "Delete the cluster and cluster store before creating a new cluster"
    exit 1
fi

function get_container_yaml() {
    REPOSITORY_NAME="${1}"
    RELEASE="${2}"
    VERSION="$(get_project_version $REPOSITORY_NAME)"
    echo "    repository: ${REPOSITORY_URI}/${REPOSITORY_NAME}
    tag: ${VERSION}-eks-${RELEASE_BRANCH}-${RELEASE}"
}

function get_project_version(){
    REPOSITORY_NAME="${1}"
    if  [[ $REPOSITORY_NAME == kubernetes/* ]] 
    then
        REPOSITORY_NAME="kubernetes/kubernetes"
    fi
    
    TAG_FILE=${BASEDIR}/../../projects/${REPOSITORY_NAME}/GIT_TAG
    if [ -f "$TAG_FILE" ]; then
        VERSION=$(cat ${BASEDIR}/../../projects/${REPOSITORY_NAME}/GIT_TAG)
    else
        VERSION=$(cat ${BASEDIR}/../../projects/${REPOSITORY_NAME}/${RELEASE_BRANCH}/GIT_TAG)
    fi
    
    echo $VERSION
}


echo "Creating ./${KOPS_CLUSTER_NAME}/values.yaml"
cat << EOF > ./${KOPS_CLUSTER_NAME}/values.yaml
kubernetesVersion: ${ARTIFACT_URL}/kubernetes/${KUBERNETES_VERSION}
clusterName: $KOPS_CLUSTER_NAME
configBase: $KOPS_STATE_STORE/$KOPS_CLUSTER_NAME
awsRegion: $AWS_DEFAULT_REGION
controlPlaneInstanceProfileArn: $CONTROL_PLANE_INSTANCE_PROFILE
nodeInstanceProfileArn: $NODE_INSTANCE_PROFILE
pause:
$(get_container_yaml kubernetes/pause $RELEASE)
kube_apiserver:
$(get_container_yaml kubernetes/kube-apiserver $RELEASE)
kube_controller_manager:
$(get_container_yaml kubernetes/kube-controller-manager $RELEASE)
kube_scheduler:
$(get_container_yaml kubernetes/kube-scheduler $RELEASE)
kube_proxy:
$(get_container_yaml kubernetes/kube-proxy $RELEASE)
metrics_server:
$(get_container_yaml kubernetes-sigs/metrics-server $RELEASE)
awsiamauth:
$(get_container_yaml kubernetes-sigs/aws-iam-authenticator $RELEASE)
coredns:
$(get_container_yaml coredns/coredns $RELEASE)
EOF
