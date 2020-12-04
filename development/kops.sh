#!/usr/bin/env bash
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

set -eo pipefail
set -x

if [ -z "$CLUSTER_NAME" ]; then
    echo "Cluster name must be an FQDN: <yourcluster>.yourdomain.com or <yourcluster>.sub.yourdomain.com"
    read -r -p "What is the name of your Cluster? " CLUSTER_NAME
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
	  echo "Please set a default region for the kops config bucket (e.g. us-west-2)"
	  read -r -p "What region would you like to store the config? " AWS_DEFAULT_REGION
fi

export KUBERNETES_VERSION=https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9
export CNI_VERSION_URL=https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz
export CNI_ASSET_HASH_STRING=sha256:7426431524c2976f481105b80497238030e1c3eedbfcad00e2a9ccbaaf9eef9d

# Create a unique s3 bucket name, or use an existing S3_BUCKET environment variable
export S3_BUCKET=${S3_BUCKET:-"kops-state-store-$(cat /dev/urandom | LC_ALL=C tr -dc "[:alpha:]" | tr '[:upper:]' '[:lower:]' | head -c 32)"}
export KOPS_STATE_STORE=s3://$S3_BUCKET
echo "Using S3 bucket $S3_BUCKET: to use with kops run"

# Create the bucket if it doesn't exist
_bucket_name=$(aws s3api list-buckets  --query "Buckets[?Name=='$S3_BUCKET'].Name | [0]" --out text)
if [ $_bucket_name == "None" ]; then
    echo "Creating S3 bucket: $S3_BUCKET"
    if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket $S3_BUCKET
    else
        aws s3api create-bucket --bucket $S3_BUCKET --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
    fi
fi

# Write aws-iam-authenticator.yaml file for later
cat << EOF > aws-iam-authenticator.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-iam-authenticator
  namespace: kube-system
  labels:
    k8s-app: aws-iam-authenticator
data:
  config.yaml: |
    clusterID: $CLUSTER_NAME
EOF

# Check if the config file already has config in it
if [ -f values.yaml ]; then
	echo "A values.yaml file already exists"
	read -r -p "Would you like to delete it and create a new cluster? [Y/n] " DELETE_VALUES
	DELETE_VALUES=${DELETE_VALUES:-y}
fi
if [ $(echo ${DELETE_VALUES} | tr '[:upper:]' '[:lower:]') == "y" ]; then
	rm values.yaml
	cat << EOF > values.yaml
kubernetesVersion: $KUBERNETES_VERSION
clusterName: $CLUSTER_NAME
configBase: $KOPS_STATE_STORE
EOF
else
	echo "Skipping delete and exiting"
	exit
fi

kops toolbox template --template eks-d.tpl --values values.yaml > "${CLUSTER_NAME}".yaml

echo "Creating cluster"
echo
kops create -f ./"${CLUSTER_NAME}".yaml

echo "Creating cluster ssh key"
# Allow users to set an SSH key
export SSH_KEY_PATH=${SSH_KEY_PATH:-$HOME/.ssh/id_rsa.pub}
kops create secret --name $CLUSTER_NAME sshpublickey admin -i ${SSH_KEY_PATH}

read -r -p "Do you want to create the cluster now? [Y/n] " CREATE_CLUSTER
# Set a default value
export CREATE_CLUSTER=${CREATE_CLUSTER:-y}

# Test variable as lowercase
if [ $(echo ${CREATE_CLUSTER} | tr '[:upper:]' '[:lower:]') == "y" ]; then
	kops update cluster $CLUSTER_NAME --yes
	kops validate cluster --wait 10m
	kubectl apply -f ./aws-iam-authenticator.yaml
else
	echo "Skipping cluster create"
	echo "Run this command whenever you're ready"
	echo ""
	echo "kops update cluster $CLUSTER_NAME --yes"
	echo ""
fi

