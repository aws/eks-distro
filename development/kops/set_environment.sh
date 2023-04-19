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

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
export DEFAULT_RELEASE_BRANCH=$(cat ${BASE_DIRECTORY}/release/DEFAULT_RELEASE_BRANCH)
export RELEASE_BRANCH=${RELEASE_BRANCH:-"${DEFAULT_RELEASE_BRANCH}"}
RELEASE_ENVIRONMENT=${RELEASE_ENVIRONMENT:-development}
export DEFAULT_RELEASE=$(cat ${BASE_DIRECTORY}/release/${RELEASE_BRANCH}/${RELEASE_ENVIRONMENT}/RELEASE)
export RELEASE=${RELEASE:-${DEFAULT_RELEASE}}
export ARTIFACT_BASE_URL="https://distro.eks.amazonaws.com"
export NODE_INSTANCE_TYPE=${NODE_INSTANCE_TYPE:-t3.medium}
export NODE_ARCHITECTURE=${NODE_ARCHITECTURE:-amd64}
export UBUNTU_RELEASE=${UBUNTU_RELEASE:-focal-20.04}
export IPV6=${IPV6:-false}

# Remove once kops 1.27 is stable and working for all versions
if [ "$RELEASE_BRANCH" == "1-27" ]; then
    export KOPS_VERSION="995bdda1588b7225dca29543ae73d09ae27f767d"
else
    export KOPS_VERSION="1.26.2"
fi

if [ -n "$ARTIFACT_BUCKET" ]; then
    export ARTIFACT_BASE_URL="https://$ARTIFACT_BUCKET.s3.amazonaws.com"
fi

if [ "${PREFLIGHT_CHECK_PASSED:-false}" != "true" ]
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

export KUBERNETES_VERSION=$(cat ../../projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG)
export IMAGE_REPO=${IMAGE_REPO:-public.ecr.aws/eks-distro}
export ARTIFACT_URL=${ARTIFACT_URL:-$ARTIFACT_BASE_URL/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts}
export CNI_VERSION=$(cat ../../projects/containernetworking/plugins/${RELEASE_BRANCH}/GIT_TAG)
export CNI_VERSION_URL=${ARTIFACT_URL}/plugins/${CNI_VERSION}/cni-plugins-linux-${NODE_ARCHITECTURE}-${CNI_VERSION}.tar.gz
export CNI_ASSET_HASH_STRING=${CNI_ASSET_HASH_STRING:-sha256:$(curl -s ${CNI_VERSION_URL}.sha256 | cut -f1 -d' ')}
export KOPS_BASE_URL=https://eks-d-postsubmit-artifacts.s3.amazonaws.com/kops/$KOPS_VERSION
export KOPS=bin/kops
mkdir -p bin
export PATH=`pwd`/bin:${PATH}
