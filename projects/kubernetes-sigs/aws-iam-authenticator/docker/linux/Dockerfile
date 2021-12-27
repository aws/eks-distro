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

FROM $BUILDER_IMAGE as builder

ARG TARGETARCH
ARG TARGETOS

COPY --from=base /etc/group /etc/group
COPY --from=base /etc/passwd /etc/passwd

RUN yum install -y shadow-utils && \
    adduser \
    --system \
    --no-create-home \
    --uid 10000 \
    aws-iam-authenticator && \
    yum clean all && \
    rm -rf /var/cache/yum

ARG RELEASE_BRANCH

COPY --chown=aws-iam-authenticator _output/$RELEASE_BRANCH/bin/aws-iam-authenticator/$TARGETOS-$TARGETARCH/aws-iam-authenticator /
COPY _output/$RELEASE_BRANCH/LICENSES /LICENSES
COPY $RELEASE_BRANCH/ATTRIBUTION.txt /ATTRIBUTION.txt


FROM builder as standard

USER aws-iam-authenticator
ENTRYPOINT ["/aws-iam-authenticator"]


FROM $BASE_IMAGE as minimal

COPY --from=builder /etc/group /etc/group
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /aws-iam-authenticator /aws-iam-authenticator
COPY --from=builder /LICENSES /LICENSES
COPY --from=builder /ATTRIBUTION.txt /ATTRIBUTION.txt

USER aws-iam-authenticator
ENTRYPOINT ["/aws-iam-authenticator"]
