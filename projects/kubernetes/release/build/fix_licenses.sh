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

set -o errexit
set -o nounset
set -o pipefail

OUTPUT_DIR="$1"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ATTRIBUTION_DIR="${OUTPUT_DIR}/attribution"
source "${MAKE_ROOT}/../../../build/lib/common.sh"


# go-licenses calls the main module command-line-arguments in the csv output
MODULE_NAME=$(cat "${ATTRIBUTION_DIR}/root-module.txt")
SEARCH='command-line-arguments'
REPLACE=$(build::common::re_quote $MODULE_NAME)
sed -i.bak "s/^$SEARCH/$REPLACE/" "${ATTRIBUTION_DIR}/go-license.csv"
