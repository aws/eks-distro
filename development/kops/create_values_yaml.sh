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


function get_container_latest_tag() {
    REPOSITORY_NAME="${1}"
    DEFAULT_TAG="${2}"
    RELEASE="${3}"
    if [ "${REPOSITORY_URI}" == "${DEFAULT_REPOSITORY_URI}" ]
    then
        echo "${DEFAULT_TAG}-${RELEASE}"
        return
    fi
    QUERY='[.imageDetails[] | select(.imageTags != null)] | sort_by(.imagePushedAt)|reverse|first|.imageTags[0]'
    if [[ "${REPOSITORY_URI}" != "public.ecr.aws/*" ]] # Public
    then
        if aws --region us-east-1 ecr-public  describe-images --repository-name "${REPOSITORY_NAME}" --image-ids=imageTag=${DEFAULT_TAG}-${RELEASE} 2>/dev/null >/dev/null
        then
            TAG=${DEFAULT_TAG}-${RELEASE}
        else
            TAG=${DEFAULT_TAG}-${DEFAULT_RELEASE}
        fi
    else # Private
        if aws ecr  describe-images --repository-name "${REPOSITORY_NAME}" --image-ids=imageTag=${DEFAULT_TAG}-${RELEASE} 2>/dev/null >/dev/null
        then
            TAG=${DEFAULT_TAG}-${RELEASE}
        else
            TAG=${DEFAULT_TAG}-1
        fi
    fi
    echo "${TAG:-${DEFAULT_TAG}}"
}

function get_container_yaml() {
    REPOSITORY_NAME="${1}"
    echo "    repository: ${REPOSITORY_URI}/${REPOSITORY_NAME}
    tag: $(get_container_latest_tag $*)"
}

echo "Creating ./${KOPS_CLUSTER_NAME}/values.yaml"
cat << EOF > ./${KOPS_CLUSTER_NAME}/values.yaml
kubernetesVersion: https://distro.eks.amazonaws.com/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts/kubernetes/${VERSION}
clusterName: $KOPS_CLUSTER_NAME
configBase: $KOPS_STATE_STORE/$KOPS_CLUSTER_NAME
awsRegion: $AWS_DEFAULT_REGION
pause:
$(get_container_yaml kubernetes/pause v1.18.9-eks-1-18 $RELEASE)
kube_apiserver:
$(get_container_yaml kubernetes/kube-apiserver v1.18.9-eks-1-18 $RELEASE)
kube_controller_manager:
$(get_container_yaml kubernetes/kube-controller-manager v1.18.9-eks-1-18 $RELEASE)
kube_scheduler:
$(get_container_yaml kubernetes/kube-scheduler v1.18.9-eks-1-18 $RELEASE)
kube_proxy:
$(get_container_yaml kubernetes/kube-proxy v1.18.9-eks-1-18 $RELEASE)
metrics_server:
$(get_container_yaml kubernetes-sigs/metrics-server v0.4.0-eks-1-18 $RELEASE)
awsiamauth:
$(get_container_yaml kubernetes-sigs/aws-iam-authenticator v0.5.2-eks-1-18 $RELEASE)
coredns:
$(get_container_yaml coredns/coredns v1.7.0-eks-1-18 $RELEASE)
EOF
