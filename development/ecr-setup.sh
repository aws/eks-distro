#!/usr/bin/env bash

set -e

readonly ECR_REPOS=(
    coredns/coredns
    etcd-io/etcd
    kubernetes-csi/external-attacher
    kubernetes-csi/external-provisioner
    kubernetes-csi/external-resizer
    kubernetes-csi/external-snapshotter/csi-snapshotter
    kubernetes-csi/external-snapshotter/snapshot-controller
    kubernetes-csi/external-snapshotter/snapshot-validation-webhook
    kubernetes-csi/livenessprobe
    kubernetes-csi/node-driver-registrar
    kubernetes-sigs/aws-iam-authenticator
    kubernetes-sigs/metrics-server
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
