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

if [ "$(uname)" == "Darwin" ]
then
    OS="darwin"
    ARCH="amd64"
else
    OS="linux"
    ARCH="amd64"
fi

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
    KOPS_URL="https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-${OS}-${ARCH}"
    set -x
    mkdir -p ${BASEDIR}/bin
    curl -L -o ${KOPS} "${KOPS_URL}"
    chmod 755 ${KOPS}
    set +x
else
    echo "Kops executable ${KOPS} available..."
    ${KOPS} version
fi
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found. Downloading..."
    
    KUBECTL_VERSION=$(cat ${BASEDIR}/../../projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG)
    KUBECTL_PATH=${BASEDIR}/bin/kubectl
    mkdir -p ${BASEDIR}/bin
    set -x
    curl -sSL "https://distro.eks.amazonaws.com/kubernetes-${RELEASE_BRANCH}/releases/1/artifacts/kubernetes/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl" -o ${KUBECTL_PATH}
    chmod +x ${KUBECTL_PATH}
    set +x
fi
exit 0
