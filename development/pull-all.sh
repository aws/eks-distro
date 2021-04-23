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

# TODO: UPDATE ECR FOR EACH
set -e
set -x

RELEASE_BRANCH=1-20
RELEASE=1
RELEASE_TAG="eks-${RELEASE_BRANCH}-${RELEASE}"

docker pull public.ecr.aws/eks-distro/kubernetes/pause:v1.18.9-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v2.0.3-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes/go-runner:v0.4.2-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter:v3.0.2-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v3.0.2-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.1.0-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-controller:v3.0.2-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes/kube-scheduler:v1.18.9-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-attacher:v3.0.1-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes/kube-proxy-base:v0.4.2-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-sigs/aws-iam-authenticator:v0.5.2-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-sigs/metrics-server:v0.4.0-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes/kube-proxy:v1.18.9-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/coredns/coredns:v1.7.0-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.0.1-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.18.9-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-resizer:v1.0.1-${RELEASE_TAG}
docker pull public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.18.9-${RELEASE_TAG}
