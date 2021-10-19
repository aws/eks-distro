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
ARTIFACT_BUCKET="${3?Third required argument is artifact bucket name}"
CRDS="${4:-false}"
DRY_RUN="${5:-false}"

BASE_DIRECTORY=$(git rev-parse --show-toplevel)

PUBLIC_READ='--acl public-read'

cd ${BASE_DIRECTORY}
PREFIX_DIR=kubernetes-${RELEASE_BRANCH}
DEST_DIR=${PREFIX_DIR}/releases/${RELEASE}/artifacts

if [ "$DRY_RUN" = "true" ]; then
  aws s3 cp $DEST_DIR s3://${ARTIFACT_BUCKET}/${DEST_DIR} ${PUBLIC_READ} --recursive --dryrun
else
  aws s3 sync $DEST_DIR s3://${ARTIFACT_BUCKET}/${DEST_DIR} ${PUBLIC_READ}
fi


if [ "$CRDS" != "true" ]
then
  exit 0
fi
if [ "$DRY_RUN" = "true" ]; then
  echo "dry run not supported for crd uploads!"
  exit 1
fi

cd ${PREFIX_DIR}
if [ RELEASE == *.minimal ]
then
  # For minimal releases do not touch CRDs/release channels
  exit 0
fi

for CRD
in *yaml
do
  aws s3 ls s3://${ARTIFACT_BUCKET}/${PREFIX_DIR}/${CRD} || aws s3 cp ${CRD} s3://${ARTIFACT_BUCKET}/${PREFIX_DIR}/${CRD} ${PUBLIC_READ}
done
cd ${BASE_DIRECTORY}
if [ -d crds ]
then
  for CRD
  in crds/*yaml
  do
    aws s3 ls s3://${ARTIFACT_BUCKET}/${CRD} || aws s3 cp ${CRD} s3://${ARTIFACT_BUCKET}/${CRD} ${PUBLIC_READ}
  done
fi
if [ -d releasechannels ]
then
  for CHANNEL
  in releasechannels/*yaml
  do
    aws s3 cp ${CHANNEL} s3://${ARTIFACT_BUCKET}/${CHANNEL} ${PUBLIC_READ}
  done
fi
