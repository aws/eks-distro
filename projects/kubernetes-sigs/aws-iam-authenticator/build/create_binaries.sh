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
  darwin/amd64
  windows/amd64
)

function build::aws-iam-authenticator::binaries(){

  mkdir -p "$BIN_PATH"
  git clone "$CLONE_URL" "$REPO"
  cd "$REPO"
  git checkout "$TAG"
  for platform in "${SUPPORTED_PLATFORMS[@]}";
  do
    OS="$(cut -d '/' -f1 <<< ${platform})"
    ARCH="$(cut -d '/' -f2 <<< ${platform})"
    suffix=""
    if [ $OS == "windows" ];
    then
      suffix=".exe"
    fi
    rev=`git rev-list -n1 HEAD`
    ld_flags="-buildid='' -s -w -X main.version=$TAG -X main.commit=$rev"

    CGO_ENABLED=0 GOOS="$OS" GOARCH="$ARCH"\
    go build -ldflags "$ld_flags"\
    -o "./bin/$REPO$suffix" ./cmd/aws-iam-authenticator/

    mkdir -p ../"$BIN_PATH"/"$OS"-"$ARCH"
    mv bin/* ../"$BIN_PATH"/"$OS"-"$ARCH"
  done
  cd ..
  rm -rf "$REPO"
}

build::aws-iam-authenticator::binaries
