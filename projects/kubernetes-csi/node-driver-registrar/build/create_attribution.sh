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

set -o errexit
set -o nounset
set -o pipefail

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT_DIR="${MAKE_ROOT}/_output"
ATTRIBUTION_DIR="${OUTPUT_DIR}/attribution"
source "${MAKE_ROOT}/../../../build/lib/common.sh"

GOLANG_VERSION="$1"

# go-licenses calls adds an additonal cmd/csi-node-driver-registrar 
# to the main module name in the csv output
MODULE_NAME=$(cat "${ATTRIBUTION_DIR}/root-module.txt")
SEARCH=$(build::common::re_quote "$MODULE_NAME/cmd/csi-node-driver-registrar")
REPLACE=$(build::common::re_quote $MODULE_NAME)
sed -i.bak "s/^$SEARCH/$REPLACE/" "${ATTRIBUTION_DIR}/go-license.csv"

build::generate_attribution $MAKE_ROOT $GOLANG_VERSION
