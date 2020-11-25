#!/usr/bin/env bash

set -x
set -o errexit
set -o nounset
set -o pipefail

REPO="$1"
CLONE_URL="$2"
TAG="$3"
BIN_ROOT="_output/bin"
BIN_PATH=$BIN_ROOT/$REPO

readonly SUPPORTED_PLATFORMS=(
  linux/amd64
  linux/arm64
)

function build::plugins::binaries(){
  mkdir -p "$BIN_PATH"
  git clone "$CLONE_URL" "$REPO"
  cd "$REPO"
  git checkout "$TAG"
  for platform in "${SUPPORTED_PLATFORMS[@]}"; do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    CGO_ENABLED=0 GOOS=$OS GOARCH=$ARCH sh build_linux.sh -ldflags "-s -w -buildid='' -extldflags -static -X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=${TAG}"
    mkdir -p ../${BIN_PATH}/${OS}-${ARCH}
    mv bin/* ../${BIN_PATH}/${OS}-${ARCH}
  done
  cd ..
  rm -rf $REPO
}

build::plugins::binaries
