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

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${AWS_REGION}}
export AWS_REGION="${AWS_DEFAULT_REGION}"
if [ -z "$AWS_DEFAULT_REGION" -o -z "$KOPS_STATE_STORE" -o -z "$KOPS_CLUSTER_NAME" ]
then
    echo "AWS_DEFAULT_REGION, KOPS_STATE_STORE and KOPS_CLUSTER_NAME must be set to run this script"
    exit 1
fi

mkdir -p "./${KOPS_CLUSTER_NAME}"
if [ -f "./${KOPS_CLUSTER_NAME}/values.yaml" ]; then
    read -r -p "A ./${KOPS_CLUSTER_NAME}/values.yaml file exists. Would you like to delete it? [Y/n] " DELETE_VALUES
    DELETE_VALUES=${DELETE_VALUES:-y}
    if [ "$(echo ${DELETE_VALUES} | tr '[:upper:]' '[:lower:]')" == "y" ]; then
        rm "./${KOPS_CLUSTER_NAME}/values.yaml"
    else
        echo "Skipping delete and exiting"
        exit 1
    fi
fi

export DEFAULT_REPOSITORY_URI=public.ecr.aws/eks-distro
export REPOSITORY_URI=${REPOSITORY_URI:-${DEFAULT_REPOSITORY_URI}}
function get_container_yaml() {
    REPOSITORY_NAME="${1}"
    TAG="${2}"
    if [ "${REPOSITORY_URI}" != "${DEFAULT_REPOSITORY_URI}" ]
    then
        QUERY='[.imageDetails[] | select(.imageTags != null)] | sort_by(.imagePushedAt)|reverse|first|.imageTags[0]'
        TAG=$(aws --region us-east-1 ecr-public  describe-images \
                  --repository-name "${REPOSITORY_NAME}" | \
                  jq -r "${QUERY}")
    fi
    echo "    repository: ${REPOSITORY_URI}/${REPOSITORY_NAME}
    tag: ${TAG}"
}

echo "Creating ./${KOPS_CLUSTER_NAME}/values.yaml"
cat << EOF > ./${KOPS_CLUSTER_NAME}/values.yaml
kubernetesVersion: $KUBERNETES_VERSION
clusterName: $KOPS_CLUSTER_NAME
configBase: $KOPS_STATE_STORE/$KOPS_CLUSTER_NAME
awsRegion: $AWS_DEFAULT_REGION
pause:
$(get_container_yaml kubernetes v1.18.9-eks-1-18-1)
kubernetes:
$(get_container_yaml kubernetes v1.18.9-eks-1-18-1)
metrics:
$(get_container_yaml kubernetes-sigs v0.4.0-eks-1-18-1)
awsiamauth:
$(get_container_yaml kubernetes-sigs v0.5.2-eks-1-18-1)
coredns:
$(get_container_yaml coredns v1.7.0-eks-1-18-1)
EOF
