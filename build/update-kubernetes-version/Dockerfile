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

FROM 316434458148.dkr.ecr.us-west-2.amazonaws.com/eks-distro/builder:e35d4971088ca37db784caf525373f7342126bf3 as build
ARG RELEASE_BRANCH 
ARG KUBERNETES_ROOT

ADD build /var/eks-distro/build
ADD ${KUBERNETES_ROOT}/Makefile /var/eks-distro/${KUBERNETES_ROOT}/
ADD ${KUBERNETES_ROOT}/build /var/eks-distro/${KUBERNETES_ROOT}/build
ADD ${KUBERNETES_ROOT}/ATTRIBUTION.txt /var/eks-distro/${KUBERNETES_ROOT}/ATTRIBUTION.txt
ADD ${KUBERNETES_ROOT}/${RELEASE_BRANCH}/patches /var/eks-distro/${KUBERNETES_ROOT}/${RELEASE_BRANCH}/patches
ADD ${KUBERNETES_ROOT}/${RELEASE_BRANCH}/GIT_TAG /var/eks-distro/${KUBERNETES_ROOT}/${RELEASE_BRANCH}/GIT_TAG
ADD ${KUBERNETES_ROOT}/${RELEASE_BRANCH}/RELEASE /var/eks-distro/${KUBERNETES_ROOT}/${RELEASE_BRANCH}/RELEASE

WORKDIR /var/eks-distro/${KUBERNETES_ROOT}
RUN make binaries
RUN make update-version 
RUN make update-checksums 


FROM scratch as export
ARG RELEASE_BRANCH 
ARG KUBERNETES_ROOT
COPY --from=build /var/eks-distro/${KUBERNETES_ROOT}/${RELEASE_BRANCH}/checksums .
COPY --from=build /var/eks-distro/${KUBERNETES_ROOT}/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE .

