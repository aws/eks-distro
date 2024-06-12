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

set -x
set -o errexit
set -o nounset
set -o pipefail

REPO="$1"
GIT_TAG="$2"
RELEASE_BRANCH="$3"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
GIT_TAG="$(cat ${MAKE_ROOT}/${RELEASE_BRANCH}/GIT_TAG)"

source "${MAKE_ROOT}/../../../build/lib/common.sh"
source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/build/lib/tarballs.sh"

if [ ! -d ${OUTPUT_DIR}/${RELEASE_BRANCH} ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH} not present!"
    exit 1
fi

OUTPUT_RELEASE_DIR="${OUTPUT_DIR}/${RELEASE_BRANCH}"
BIN="${OUTPUT_RELEASE_DIR}/bin" 
TAR_OUTPUT_DIR=${OUTPUT_DIR}/tar/${RELEASE_BRANCH}
IMAGES_DIR="${OUTPUT_RELEASE_DIR}/images/bin"

mkdir -p $TAR_OUTPUT_DIR
build::common::ensure_tar
build::tarballs::create_tarballs $BIN $OUTPUT_RELEASE_DIR $TAR_OUTPUT_DIR $IMAGES_DIR

# exclude helper files used for make targets
echo "eks-distro-checkout-$GIT_TAG export-ignore" >> $SOURCE_DIR/.git/info/attributes
echo "eks-distro-patched export-ignore" >> $SOURCE_DIR/.git/info/attributes

# Tag current HEAD of repo which includes the patches so that when the archive is created
# the proper tag will be written into the hack/lib/version.sh file for anyone building from 
# this source tarball. Load version file to avoid recreating git version
source "${MAKE_ROOT}/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"
git -C $SOURCE_DIR tag -f $KUBE_GIT_VERSION

git \
    -C $SOURCE_DIR \
    archive \
    --format=tar.gz \
    --output=${TAR_OUTPUT_DIR}/kubernetes-src.tar.gz \
    HEAD
