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
set -x
set -o errexit
set -o nounset
set -o pipefail

REPO="$1"
OUTPUT_DIR="$2"
RELEASE_BRANCH="$3"

# The heketi/heketi dependency is dual licensed between Apache 2.0 or LGPLv3+
# this was done at the request of the kubernetes project since the original license
# was not one that allowed redistro.  The pieces used by the kubernetes project follow under
# the apache2 license.
# https://github.com/heketi/heketi/pull/1419
# https://github.com/kubernetes/kubernetes/pull/70828
# Copy the apache2 license into place in the vendor directory
#
# For Kubernetes 1.26+, heketi was removed https://github.com/kubernetes/kubernetes/pull/112015
# This block should be removed once 1-25 is no longer supported.
MINOR_VERSION=${RELEASE_BRANCH: -2}
if [[ $MINOR_VERSION -le 25 ]]; then
  cp $REPO/vendor/github.com/heketi/heketi/LICENSE-APACHE2 $REPO/vendor/github.com/heketi/heketi/LICENSE
  rm -f $REPO/vendor/github.com/heketi/heketi/COPYING-*
fi

# a number of k8s.io dependencies which come from the main repo show
# up in the list and since they are in the repo they have no version
# set the rootmodule name to k8s.io to force all projects with that 
# prefix and no version to use the k8s git_tag version
mkdir -p ${OUTPUT_DIR}/attribution
echo "k8s.io" > ${OUTPUT_DIR}/attribution/root-module.txt
