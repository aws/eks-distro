#!/usr/bin/env bash

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

REPOSITORY="kubernetes"
SOURCE_DIR=${MAKE_ROOT}/${REPOSITORY}

OUTPUT_DIR="${MAKE_ROOT}/_output"

source "${MAKE_ROOT}/build/lib/git.sh"
source "${MAKE_ROOT}/build/lib/binaries.sh"
source "${MAKE_ROOT}/build/lib/version.sh"
source "${MAKE_ROOT}/build/lib/images.sh"
