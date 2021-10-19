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
ARG BUILDER_IMAGE
FROM $BASE_IMAGE as base

ARG TARGETARCH
ARG TARGETOS
ARG RELEASE_BRANCH

COPY _output/$RELEASE_BRANCH/bin/coredns/$TARGETOS-$TARGETARCH/coredns /coredns
COPY _output/$RELEASE_BRANCH/LICENSES /LICENSES
COPY $RELEASE_BRANCH/ATTRIBUTION.txt /ATTRIBUTION.txt

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]

FROM $BUILDER_IMAGE as builder
RUN yum update -y
RUN yum install -y ca-certificates && update-ca-trust

FROM base as standard
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

FROM base as minimal
