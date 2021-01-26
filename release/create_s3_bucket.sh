#!/usr/bin/env bash
# Copyright 2021 Amazon.com Inc. or its affiliates. All Rights Reserved.
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

set -euxo pipefail

ARTIFACT_BUCKET="${1?First argument should be bucket to create}"
BUCKET_NAME=${ARTIFACT_BUCKET#"s3://"}

# Create the bucket if it doesn't exist
_bucket_name=$(aws s3api list-buckets  --query "Buckets[?Name=='$BUCKET_NAME'].Name | [0]" --out text)
if [ $_bucket_name == "None" ]; then
    echo "Creating artifact bucket: $ARTIFACT_BUCKET"
    if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket $BUCKET_NAME
    else
        aws s3api create-bucket --bucket $BUCKET_NAME --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
    fi
else
    echo "Using existing artifact bucket: $ARTIFACT_BUCKET"
fi
