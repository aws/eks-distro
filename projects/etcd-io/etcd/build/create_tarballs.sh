#!/usr/bin/env bash
set -x
set -o errexit
set -o nounset
set -o pipefail

REPO="$1"
TAG="$2"
TAR_PATH="_output/tar"
BIN_ROOT="_output/bin"
readonly SUPPORTED_PLATFORMS=(
  linux/amd64
  linux/arm64
)
MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

function build::etcd::tarball() {
  build::common::ensure_tar
  mkdir -p "$TAR_PATH"

  for platform in "${SUPPORTED_PLATFORMS[@]}";
  do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    TAR_FILE="${REPO}-${OS}-${ARCH}-${TAG}.tar.gz"
    build::common::create_tarball  "${TAR_PATH}/${TAR_FILE}" "${BIN_ROOT}/${REPO}" "$OS"-"$ARCH"
  done
  rm -rf "$BIN_ROOT"
}

build::etcd::tarball

build::common::generate_shasum "${TAR_PATH}"
