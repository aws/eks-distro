#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
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
# Ignoring preflight check failures since we only need the env vars set

if [ "$(uname)" == "Darwin" ]
then
    OS="darwin"
    ARCH="amd64"
else
    OS="linux"
    ARCH="amd64"
fi

mkdir -p ${BASEDIR}/bin

if [ ! -x ${KOPS} ]
then
    echo "Determine kops version"
    KOPS_VERSION="v1.23.2"
    echo "Download kops"
    KOPS_URL="https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-${OS}-${ARCH}"
    set -x
    curl -L -o ${KOPS} "${KOPS_URL}"
    chmod 755 ${KOPS}
    set +x
fi

if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found. Downloading..."
    KUBECTL_VERSION=$(cat ${BASEDIR}/../../projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG)
    KUBECTL_PATH=${BASEDIR}/bin/kubectl
    COUNT=0
    while [ ! "$(${KUBECTL_PATH} version --client true --short)" ]; do
        sleep 5
        COUNT=$(expr $COUNT + 1)
        if [ $COUNT -gt 120 ]
        then
            echo "Failed to download kubectl"
            exit 1
        fi
        set -x
        curl -sSL "${ARTIFACT_URL}/kubernetes/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl" -o ${KUBECTL_PATH}
        chmod +x ${KUBECTL_PATH}
        set +x
    done
fi

if ! command -v helm &> /dev/null
then
    curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | HELM_INSTALL_DIR=${BASEDIR}/bin bash
fi

if ! command -v sonobuoy &> /dev/null
then
    echo "Download sonobuoy"
    SONOBUOY=https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.56.2/sonobuoy_0.56.2_${OS}_${ARCH}.tar.gz
    wget -qO- ${SONOBUOY} |tar -xz sonobuoy
    chmod 755 sonobuoy
    mv sonobuoy ./bin
fi

echo "$(which kops): $(kops version)"
echo "$(which kubectl): $(kubectl version --client=true --short)"
echo "$(which helm): $(helm version --short)"
echo "$(which sonobuoy): $(sonobuoy version --short)"

exit 0
