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

BUILD_LIB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd -P)"

CMD="buildctl"
if [ -f "/buildkit.sh" ] && ! buildctl debug workers >/dev/null 2>&1; then
    # on the builder base this helper file exists to run buildkitd
    # in prow buildkitd is run as a seperate container so it will be running already
    # in codebuild its run directly on the instance so we want to use this helper
    CMD="/buildkit.sh"

fi
# From time to time we see random failures when creating/pushing images that fix on reruning the job
# this is an attempt to avoid failing key jobs, like the release job, with a flaky failure
# If running in builder base, most likely we are running in prow/codebuild, us retry logic
# if not in builder base, probably running locally so skip the retry
if [ -f "/buildkit.sh" ]; then
    for i in $(seq 1 5); do
        [ $i -gt 1 ] && sleep 15
        $CMD "$@" && s=0 && break || s=$?
    done
    (exit $s)
else
    # skip retry when running locally
    $CMD "$@"
fi

