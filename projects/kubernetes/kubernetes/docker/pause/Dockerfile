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
FROM ${BUILDER_IMAGE}

ARG PAUSE_VERSION

COPY pause/pause.c /pause.c

RUN yum update -y && \
  yum install -y gcc glibc-static && \
  gcc -Os -Wall -Werror -static -DVERSION=${PAUSE_VERSION} -o /pause /pause.c && \
  yum autoremove -y gcc glibc-static && \
  yum clean all && \
  rm -rf /var/cache/yum

FROM ${BASE_IMAGE}
COPY --from=0 /pause /pause
ENTRYPOINT ["/pause"]
