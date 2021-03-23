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

set -euxo pipefail

RELEASE_BRANCH="${1?First required argument is release branch for example 1-18}"
RELEASE="${2?Second required argument is release for example 1}"
IMAGE_REPO="${3?Third required argument is image repository}"
REPO_OWNER=${REPO_OWNER:-aws}

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
cd ${BASE_DIRECTORY}

REPOSITORY="https://github.com/${REPO_OWNER}/eks-distro-build-tooling.git"
rm -rf ./eks-distro-build-tooling
git clone ${REPOSITORY}
make -C eks-distro-build-tooling/release
DESTINATION="./kubernetes-${RELEASE_BRANCH}/kubernetes-${RELEASE_BRANCH}-eks-${RELEASE}.yaml"
./eks-distro-build-tooling/release/bin/eks-distro-release release \
    --image-repository ${IMAGE_REPO} \
    --release-branch ${RELEASE_BRANCH} \
    --release-number ${RELEASE} | tee ${DESTINATION}
mkdir -p releasechannels
grep -v '^#.*' eks-distro-build-tooling/release/config/${RELEASE_BRANCH}/${RELEASE_BRANCH}.yaml \
    >releasechannels/${RELEASE_BRANCH}.yaml
mkdir -p crds
grep -v '^#.*' eks-distro-build-tooling/release/config/crds/releasechannels.distro.eks.amazonaws.com-v1alpha1.yaml \
    >crds/releasechannels.distro.eks.amazonaws.com-v1alpha1.yaml
grep -v '^#.*' eks-distro-build-tooling/release/config/crds/releases.distro.eks.amazonaws.com-v1alpha1.yaml \
    >crds/releases.distro.eks.amazonaws.com-v1alpha1.yaml
