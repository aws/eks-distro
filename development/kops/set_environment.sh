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

BASEDIR=$(dirname "$0")
export RELEASE_BRANCH=${RELEASE_BRANCH:-"1-18"}
export DEFAULT_RELEASE=$(cat ${BASEDIR}/../../release/${RELEASE_BRANCH}/RELEASE)
export RELEASE=${RELEASE:-${DEFAULT_RELEASE}}

if [ -z "${PREFLIGHT_CHECK_PASSED}" ]
then
    PREFLIGHT_CHECK_PASSED=true
    GOOD="\xE2\x9C\x94"
    BAD="\xE2\x9D\x8C"
    export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${AWS_REGION}}
    export AWS_REGION="${AWS_DEFAULT_REGION}"
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        PREFLIGHT_CHECK_PASSED=false
        echo -e "${BAD} AWS_REGION must be set and exported"
    else
        echo -e "${GOOD} AWS_REGION=${AWS_REGION}"
    fi

    if ! aws sts get-caller-identity --query Account --output text >/dev/null 2>/dev/null
    then
        PREFLIGHT_CHECK_PASSED=false
        echo -e "${BAD} AWS CLI failed to authenticate"
    else
        echo -e "${GOOD} AWS CLI authenticated"
    fi

    if [ -z "$KOPS_STATE_STORE" ]; then
        PREFLIGHT_CHECK_PASSED=false
        echo -e "${BAD} KOPS_STATE_STORE must be set and exported"
    else
        echo -e "${GOOD} KOPS_STATE_STORE=${KOPS_STATE_STORE}"
    fi
    if [[ "${KOPS_STATE_STORE}" != s3://* ]]
    then
        export KOPS_STATE_STORE="s3://${KOPS_STATE_STORE}"
    fi
    export BUCKET_NAME=${KOPS_STATE_STORE#"s3://"}

    if [ -z "$KOPS_CLUSTER_NAME" ]; then
        PREFLIGHT_CHECK_PASSED=false
        echo -e "${BAD} KOPS_CLUSTER_NAME must be set and exported"
    else
        echo -e "${GOOD} KOPS_CLUSTER_NAME=${KOPS_CLUSTER_NAME}"
    fi
fi
export PREFLIGHT_CHECK_PASSED

VERSION=$(cat ${BASEDIR}/../../projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG)
export DEFAULT_REPOSITORY_URI=public.ecr.aws/eks-distro
export REPOSITORY_URI=${REPOSITORY_URI:-${DEFAULT_REPOSITORY_URI}}
export CNI_VERSION_URL=https://distro.eks.amazonaws.com/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz
export CNI_ASSET_HASH_STRING=sha256:7426431524c2976f481105b80497238030e1c3eedbfcad00e2a9ccbaaf9eef9d
mkdir -p ${BASEDIR}/bin
export PATH=${BASEDIR}/bin:${PATH}
export KOPS=${BASEDIR}/bin/kops-${RELEASE_BRANCH}
