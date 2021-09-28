#!/usr/bin/env bash
# Copyright 2020 Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function build::binaries::bins() {
    local -r repository_dir="$1"
    local -r output_dir="$2"
    cd $repository_dir/images/build/go-runner
	go mod vendor
    export CGO_ENABLED=0
    export GOLDFLAGS='-s -w --buildid=""'

    export GOOS=linux
    export GOARCH=amd64
    go build -trimpath -v -ldflags="$GOLDFLAGS" \
        -o $output_dir/go-runner-linux-amd64

    export GOARCH=arm64
    go build -trimpath -v -ldflags="$GOLDFLAGS" \
        -o $output_dir/go-runner-linux-arm64
}
