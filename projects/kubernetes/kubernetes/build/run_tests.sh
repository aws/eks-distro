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
source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

export ARTIFACTS=${ARTIFACTS:-"./_artifacts"}
export KUBE_JUNIT_REPORT_DIR="${ARTIFACTS}"
export KUBE_KEEP_VERBOSE_TEST_OUTPUT=y
export LOG_LEVEL=4
export KUBE_TIMEOUT=${KUBE_TIMEOUT:-"--timeout=600s"}

build::binaries::use_go_version_k8s "$RELEASE_BRANCH"

go get gotest.tools/gotestsum

cd $MAKE_ROOT/kubernetes

# Install etcd for tests
./hack/install-etcd.sh

MAX_RETRIES=3
# There are flakes in upstream tests, the process also caches passing results
# so on rerun it only runs the tests which failed
for i in $(seq 1 $MAX_RETRIES); 
do 
  [ $i -gt 1 ] && sleep 5
  PATH="${GOPATH}/bin:${MAKE_ROOT}/kubernetes/third_party/etcd:${PATH}" make test && ret=0 && break || ret=$?; 
done
exit $ret
