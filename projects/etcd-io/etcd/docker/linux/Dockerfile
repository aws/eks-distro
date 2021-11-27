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

ARG BASE_IMAGE
FROM $BASE_IMAGE AS base

ARG TARGETARCH
ARG TARGETOS
ARG RELEASE_BRANCH

FROM base AS branch-version-amd64

FROM base AS branch-version-arm64
ENV ETCD_UNSUPPORTED_ARCH=arm64

FROM branch-version-${TARGETARCH} AS final

COPY _output/$RELEASE_BRANCH/bin/etcd/$TARGETOS-$TARGETARCH/etcd /usr/local/bin/
COPY _output/$RELEASE_BRANCH/bin/etcd/$TARGETOS-$TARGETARCH/etcdctl /usr/local/bin/
COPY _output/$RELEASE_BRANCH/LICENSES /LICENSES
COPY $RELEASE_BRANCH/ATTRIBUTION.txt /ATTRIBUTION.txt

VOLUME /var/etcd/
VOLUME /var/lib/etcd/

EXPOSE 2379 2380

# Define default command.
CMD ["/usr/local/bin/etcd"]
