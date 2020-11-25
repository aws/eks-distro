#!/usr/bin/env bash

function build::binaries::bins() {
    local -r repository_dir="$1"
    local -r output_dir="$2"
    cd $repository_dir/images/build/go-runner
    export CGO_ENABLED=0
    export GOLDFLAGS='-s -w --buildid=""'

    export GOOS=linux
    export GOARCH=amd64
    go build -v -ldflags="$GOLDFLAGS" \
        -o $output_dir/go-runner-linux-amd64

    export GOARCH=arm64
    go build -v -ldflags="$GOLDFLAGS" \
        -o $output_dir/go-runner-linux-arm64
}
