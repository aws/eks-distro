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

set -exo pipefail

export KOPS_STATE_STORE=${1:-${KOPS_STATE_STORE}}
if [ -z "${KOPS_STATE_STORE}" ]
then
  echo "Usage: ${0} s3://bucketname"
  echo "  or set and export KOPS_STATE_STORE"
  exit 1
fi
if [[ "${KOPS_STATE_STORE}" != s3://* ]]
then
  export KOPS_STATE_STORE="s3://${KOPS_STATE_STORE}"
fi
if [ -z "${KOPS_CLUSTER_NAME}" ]
then
  export KOPS_CLUSTER_NAME=$(kops get cluster --state "${KOPS_STATE_STORE}" | tail -n +2 | cut -f1 -d '	' 2>/dev/null)
  if [ -z "${KOPS_CLUSTER_NAME}" ]
  then
    echo "KOPS_CLUSTER_NAME must be set and exported to run this script"
    exit 1
  fi
fi

# Move to the script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

echo "Download sonobuoy"
if [ "$(uname)" == "Darwin" ]
then
  SONOBUOY=https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.19.0/sonobuoy_0.19.0_darwin_amd64.tar.gz
else
  SONOBUOY=https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.19.0/sonobuoy_0.19.0_linux_386.tar.gz
fi
wget -qO- ${SONOBUOY} |tar -xz
rm -f LICENSE
chmod 755 sonobuoy

echo "Testing cluster $KOPS_STATE_STORE"
./sonobuoy run --mode=certified-conformance --wait --kube-conformance-image k8s.gcr.io/conformance:v1.18.9
results=$(./sonobuoy retrieve)
mv $results "./${KOPS_CLUSTER_NAME}/$results"
results="./${KOPS_CLUSTER_NAME}/$results"
mkdir ./${KOPS_CLUSTER_NAME}/results
tar xzf $results -C ./${KOPS_CLUSTER_NAME}/results
cp ./${KOPS_CLUSTER_NAME}/results/plugins/e2e/results/global/junit_01.xml /logs/artifacts
./sonobuoy e2e ${results}
./sonobuoy e2e ${results} | grep 'failed tests: 0' >/dev/null
