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


set -e

readonly ECR_REPOS=(
    coredns/coredns
    etcd-io/etcd
    kubernetes-sigs/aws-iam-authenticator
    kubernetes/go-runner
    kubernetes/kube-apiserver
    kubernetes/kube-controller-manager
    kubernetes/kube-proxy
    kubernetes/kube-proxy-base
    kubernetes/kube-scheduler
    kubernetes/pause
)
for image in "${ECR_REPOS[@]}"; do
    aws ecr describe-repositories --repository-name $image 2>/dev/null ||
    aws ecr create-repository \
        --repository-name $image \
        --image-scanning-configuration  scanOnPush=true || true
done
