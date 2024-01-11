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

ARG BASE_IMAGE=public.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base:2023-09-06-1694026927.2
FROM $BASE_IMAGE

ARG TARGETARCH=amd64
ARG TARGETOS=linux


COPY bin/external-snapshotter/$TARGETOS-$TARGETARCH/csi-snapshotter /csi-snapshotter
ENTRYPOINT ["/csi-snapshotter"]
