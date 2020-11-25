#!/usr/bin/env bash

set -x
set -o errexit
set -o nounset
set -o pipefail

RELEASE_BRANCH="$1"
GO_RUNNER_IMAGE="$2"
KUBE_PROXY_BASE_IMAGE="$3"
REPOSITORY_BASE="$4"
REPO_PREFIX="$5"
IMAGE_TAG="$6"
PUSH="$7"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

source "${MAKE_ROOT}/build/lib/init.sh"

if [ ! -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin not present! Run 'make binaries'"
    exit 1
fi
BIN_DIR=${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
if [ "$PUSH" != "true" ]; then
    echo "Placing images under in $BIN_DIR"
    build::images::release_image_tar $RELEASE_BRANCH $GO_RUNNER_IMAGE $KUBE_PROXY_BASE_IMAGE $REPOSITORY_BASE $REPO_PREFIX $IMAGE_TAG $BIN_DIR
else
    build::images::push $RELEASE_BRANCH $GO_RUNNER_IMAGE $KUBE_PROXY_BASE_IMAGE $REPOSITORY_BASE $REPO_PREFIX $IMAGE_TAG $BIN_DIR
fi
