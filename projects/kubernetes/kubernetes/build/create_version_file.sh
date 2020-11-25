#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

TAG=$1
RELEASE_BRANCH=$2

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"
if [ ! -d ${MAKE_ROOT}/_bin ] ;  then
    echo "${MAKE_ROOT}/_bin not present! Run 'make binaries'"
    exit 1
fi

VERSION_FILE="${MAKE_ROOT}/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE"
rm -f $VERSION_FILE
touch $VERSION_FILE
RELEASE_FILE="${MAKE_ROOT}/${RELEASE_BRANCH}/RELEASE"
build::version::create_env_file "$TAG" "$VERSION_FILE" "$RELEASE_FILE" "kubernetes"
