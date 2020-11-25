#!/usr/bin/env bash
set -x
set -o errexit
set -o nounset
set -o pipefail

CLONE_URL=$1
REPOSITORY=$2
TAG=$3

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT_DIR="${OUTPUT_DIR:-${MAKE_ROOT}/_output}"

source "${MAKE_ROOT}/build/lib/clone.sh"
source "${MAKE_ROOT}/build/lib/binaries.sh"

mkdir -p $OUTPUT_DIR
build::clone::release $CLONE_URL $REPOSITORY $TAG
build::binaries::bins $MAKE_ROOT/$REPOSITORY $OUTPUT_DIR
