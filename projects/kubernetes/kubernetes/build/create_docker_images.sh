#!/usr/bin/env bash

set -x
set -o errexit
set -o nounset
set -o pipefail

RELEASE_BRANCH="$1"
GO_RUNNER_IMAGE="$2"
KUBE_PROXY_BASE_IMAGE="$3"
IMAGE_REPOSITORY="$4"
REPO_PREFIX="$5"
IMAGE_TAG="$6"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

source "${MAKE_ROOT}/build/lib/init.sh"

if [ ! -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin not present!"
    exit 1
fi
IMAGE_TAR_DIR=${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
mkdir -p $IMAGE_TAR_DIR
build::images::docker $RELEASE_BRANCH $GO_RUNNER_IMAGE $KUBE_PROXY_BASE_IMAGE $IMAGE_REPOSITORY $REPO_PREFIX $IMAGE_TAG
