#!/usr/bin/env bash
# Copyright 2020 Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#            http://www.apache.org/licenses/LICENSE-2.0
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

if [ ! -x ${KOPS} ]
then
    echo "Determine kops version"
    if [ "${RELEASE_BRANCH}" == "1-19" ]
    then
        KOPS_VERSION="v1.19.0-beta.3"
    else
        KOPS_VERSION="v1.18.3"
    fi

    echo "Download kops"
    if [ "$(uname)" == "Darwin" ]
    then
        OS_ARCH="darwin-amd64"
    else
        OS_ARCH="linux-amd64"
    fi
    KOPS_URL="https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-${OS_ARCH}"
    set -x
    curl -L -o ${KOPS} "${KOPS_URL}"
    chmod 755 ${KOPS}
    set +x
else
    echo "Kops executable ${KOPS} available..."
    ${KOPS} version
fi
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    
    KUBECTL_VERSION=v1.18.9
    KUBECTL_PATH=/usr/local/bin/kubectl
    curl -sSL "https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o ${KUBECTL_PATH}
    chmod +x ${KUBECTL_PATH}
fi
exit 0
