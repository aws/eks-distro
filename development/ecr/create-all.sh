#!/usr/bin/env bash -e
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

BASEDIR=$(dirname "$0")
COMMAND="${BASEDIR}/ecr-command.sh create-public-repository"

$COMMAND "coredns/coredns"
$COMMAND "etcd-io/etcd"
$COMMAND "kubernetes-csi/external-attacher"
$COMMAND "kubernetes-csi/external-provisioner"
$COMMAND "kubernetes-csi/external-resizer"
$COMMAND "kubernetes-csi/external-snapshotter/csi-snapshotter"
$COMMAND "kubernetes-csi/external-snapshotter/snapshot-controller"
$COMMAND "kubernetes-csi/external-snapshotter/snapshot-validation-webhook"
$COMMAND "kubernetes-csi/livenessprobe"
$COMMAND "kubernetes-csi/node-driver-registrar"
$COMMAND "kubernetes-sigs/aws-iam-authenticator"
$COMMAND "kubernetes-sigs/metrics-server"
$COMMAND "kubernetes/go-runner"
$COMMAND "kubernetes/kube-apiserver"
$COMMAND "kubernetes/kube-controller-manager"
$COMMAND "kubernetes/kube-proxy"
$COMMAND "kubernetes/kube-proxy-base"
$COMMAND "kubernetes/kube-scheduler"
$COMMAND "kubernetes/pause"
