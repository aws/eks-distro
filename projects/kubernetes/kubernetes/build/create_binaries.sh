#!/usr/bin/env bash
set -x
set -o errexit
set -o nounset
set -o pipefail

CLONE_URL="$1"
RELEASE_BRANCH="$2"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"

GIT_TAG="$(cat ${MAKE_ROOT}/${RELEASE_BRANCH}/GIT_TAG)"
PATCH_DIR=${MAKE_ROOT}/${RELEASE_BRANCH}/patches
export KUBE_GIT_VERSION_FILE="${MAKE_ROOT}/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"

if [ -d ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin ]; then
    echo "${OUTPUT_DIR}/${RELEASE_BRANCH}/bin already exists. Run 'make clean' before rebuilding"
    exit 0
fi
build::git::clone "$CLONE_URL" "$SOURCE_DIR"
build::git::patch "$SOURCE_DIR" "$GIT_TAG" "$PATCH_DIR"
build::binaries::kube_bins "$SOURCE_DIR"

mkdir -p ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
cp -r ${SOURCE_DIR}/_output/local/bin/* ${OUTPUT_DIR}/${RELEASE_BRANCH}/bin
