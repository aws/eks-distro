#!/usr/bin/env bash

set -x
set -o errexit
set -o nounset
set -o pipefail

CLONE_URL="$1"
REPO="$2"
TAG="$3"
BIN_ROOT="_output/bin"
BIN_PATH=$BIN_ROOT/$REPO

readonly SUPPORTED_PLATFORMS=(
  linux/amd64
  linux/arm64
)

function build::coredns::binaries(){
  mkdir -p $BIN_PATH
  git clone $CLONE_URL $REPO
  cd "$REPO"
  git checkout $TAG
  go mod vendor
  for platform in "${SUPPORTED_PLATFORMS[@]}";
  do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    make SYSTEM="GOOS=\"$OS\" GOARCH=\"$ARCH\""
    mkdir -p ../${BIN_PATH}/${OS}-${ARCH}
    mv coredns ../${BIN_PATH}/${OS}-${ARCH}
    make clean
  done
  cd ..
  rm -rf $REPO
}

build::coredns::binaries
