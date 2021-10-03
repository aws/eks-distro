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

PROJECT="${1?First required argument is project}"
RELEASE_BRANCH="${2?Second required argument is release branch for example 1-18}"
RELEASE="${3?Third required argument is release for example 1}"

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
DEST_DIR=${BASE_DIRECTORY}/kubernetes-${RELEASE_BRANCH}/releases/${RELEASE}/artifacts

if [ $PROJECT = "kubernetes/kubernetes" ]; then
  SOURCE_DIR=_output/${RELEASE_BRANCH}
  GIT_TAG=$(cat ${RELEASE_BRANCH}/GIT_TAG)
elif [ $PROJECT = "etcd-io/etcd" ] || [ $PROJECT = "coredns/coredns" ]; then
  # Copy oci tars into kubernetes directory for use by capi image-builder
  KUBERNETES_GIT_TAG=$(cat ${BASE_DIRECTORY}/projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG)
  KUBERNETES_ARTIFACT_DIR=${DEST_DIR}/kubernetes/${KUBERNETES_GIT_TAG}
  mkdir -p $KUBERNETES_ARTIFACT_DIR
  cp -r _output/images/* $KUBERNETES_ARTIFACT_DIR
  
  # coredns has no tars to upload, just the oci target which is uploaded above
  if [ $PROJECT = "coredns/coredns" ]; then
    exit 0
  fi

  SOURCE_DIR=_output/tar
  GIT_TAG=$(cat ${RELEASE_BRANCH}/GIT_TAG)
elif [ ! -f GIT_TAG ]; then
  SOURCE_DIR=_output/tar
  GIT_TAG=$(cat ${RELEASE_BRANCH}/GIT_TAG)
else
  SOURCE_DIR=_output/tar
  GIT_TAG=$(cat GIT_TAG)
fi
REPO="$(cut -d '/' -f2 <<< ${PROJECT})"
ARTIFACT_DIR=${DEST_DIR}/${REPO}/${GIT_TAG}
mkdir -p $ARTIFACT_DIR
cp -r $SOURCE_DIR/* $ARTIFACT_DIR
