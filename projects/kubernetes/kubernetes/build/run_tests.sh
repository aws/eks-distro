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


set -x
set -o errexit
set -o nounset
set -o pipefail

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

export ARTIFACTS=${ARTIFACTS:-"./_artifacts"}
export KUBE_JUNIT_REPORT_DIR="${ARTIFACTS}"
export KUBE_KEEP_VERBOSE_TEST_OUTPUT=y
export LOG_LEVEL=4

cd $MAKE_ROOT/kubernetes

# Install etcd for tests
./hack/install-etcd.sh

# Install gotestsum which is used to get the junit output
# TODO: fails through athens proxy on the same dep as external-snapshotter
GOPROXY=direct go get gotest.tools/gotestsum

# Add gopath and etcd bin paths for use by unit test  
PATH="${GOPATH}/bin:${MAKE_ROOT}/kubernetes/third_party/etcd:${PATH}" make test KUBE_TIMEOUT=--timeout=600s
