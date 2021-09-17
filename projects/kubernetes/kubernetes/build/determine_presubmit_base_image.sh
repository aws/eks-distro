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
set -o nounset
set -o pipefail

IMAGE="$1"

mkdir -p /tmp/base-test
cat <<EOF >/tmp/base-test/Dockerfile
    FROM $IMAGE
    RUN echo "exists"
EOF

buildctl \
    build \
    --frontend dockerfile.v0 \
    --local dockerfile=/tmp/base-test \
    --local context=./ \
    --output type=oci,oci-mediatypes=true,dest=/tmp/docker-fake.tar

if [ $? == 0 ]; then
    echo $IMAGE
else
    # If the image does not exist in the registry, default to AL2
    # This can happen when adding a new version of Kubernetes
    # where the release project hasn't been built in postsubmit yet,
    # but the Kubernetes presubmit is trying to build an image
    # based on it.  Using AL2 should be fine since this is
    # a temporary situation.
    echo "public.ecr.aws/amazonlinux/amazonlinux:2"
fi
