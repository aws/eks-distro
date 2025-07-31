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

EKS_VERSION=$(cat .eks_version_temp 2>/dev/null || echo "")
if [[ -n "${EKS_VERSION}" ]]; then
    echo "${EKS_VERSION}"
    rm -f .eks_version_temp
else
    echo "Error: Could not process EKS version - value is empty" >&2
    exit 1
fi

