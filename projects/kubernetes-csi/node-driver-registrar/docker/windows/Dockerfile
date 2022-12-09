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

ARG BUILDER_IMAGE
ARG BASE_IMAGE
FROM $BUILDER_IMAGE as servercore
FROM $BASE_IMAGE

COPY --from=servercore /Windows/System32/netapi32.dll /Windows/System32/netapi32.dll

ARG TARGETARCH
ARG TARGETOS


COPY LICENSES /LICENSES
COPY ATTRIBUTION.txt /ATTRIBUTION.txt
COPY bin/node-driver-registrar/$TARGETOS-$TARGETARCH/csi-node-driver-registrar.exe /csi-node-driver-registrar.exe

USER ContainerAdministrator
ENTRYPOINT ["/csi-node-driver-registrar.exe"]
