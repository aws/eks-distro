#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
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

set -o errexit
set -o nounset
set -o pipefail

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

RELEASE_BRANCH="$1"
GOLANG_VERSION="$2"

export ARTIFACTS=${ARTIFACTS:-"./_artifacts"}
export KUBE_JUNIT_REPORT_DIR="${ARTIFACTS}"
export KUBE_KEEP_VERBOSE_TEST_OUTPUT=y
export LOG_LEVEL=4
export KUBE_TIMEOUT=${KUBE_TIMEOUT:-"--timeout=600s"}

build::common::use_go_version $GOLANG_VERSION

go get gotest.tools/gotestsum

cd $MAKE_ROOT/kubernetes

# Install etcd for tests
./hack/install-etcd.sh

export PATH="${GOPATH}/bin:${MAKE_ROOT}/kubernetes/third_party/etcd:${PATH}"

MAX_RETRIES=5
# There are flakes in upstream tests, the process also caches passing results
# so on rerun it only runs the tests which failed
for i in $(seq 1 $MAX_RETRIES); 
do 
  [ $i -gt 1 ] && sleep 5
  make test && ret=0 && break || ret=$?; 
done

if [ $ret -ne 0 ]; then
  echo "Tests failed after $MAX_RETRIES runs, checking if failures are known flakes"

  latest_log=$(ls -td $ARTIFACTS/junit*.stdout | head -1)
  gotestsum --jsonfile $ARTIFACTS/out.json --raw-command cat "$latest_log"
  jq -r 'select(.Action=="fail" and .Test) | [.Package, .Test]  | join("/")' $ARTIFACTS/out.json > $ARTIFACTS/failed_tests
  non_flakes=$(grep -Fxv -f $MAKE_ROOT/top_flakes $ARTIFACTS/failed_tests || true)

  if [ ! "$non_flakes" ]
  then
        echo "Failures are confirmed flakes.  Tests considered passing"
        ret=0
  else
    echo "
The following tests failed after $MAX_RETRIES runs and are not listed in top_flakes
Check upstream if failing test is a common flake and add it to the top_flakes file:
  https://github.com/kubernetes/community/blob/master/contributors/devel/sig-testing/flaky-tests.md

$non_flakes
"
  fi
fi

exit $ret
