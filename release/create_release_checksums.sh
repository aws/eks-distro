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

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BASE_DIRECTORY="$(cd "${SCRIPT_ROOT}/.." && pwd -P)"
source ${BASE_DIRECTORY}/build/lib/common.sh

ASSET_ROOT="$1"

FIND=find
if which gfind &>/dev/null; then
    FIND=gfind
elif which gnudate &>/dev/null; then
    FIND=gnufind
fi

SHA256SUM=$(dirname ${ASSET_ROOT})/SHA256SUM
SHA512SUM=$(dirname ${ASSET_ROOT})/SHA512SUM
rm -f $SHA256SUM
rm -f $SHA512SUM
echo "Writing artifact hashes to SHA256SUM/SHA512SUM files in folder: $ASSET_ROOT"
cd $ASSET_ROOT
for file in $(find ${ASSET_ROOT} -type f -not -path '*\.sha[25][51][62]' -not -path '*\.docker_*' \( -path '*bin/linux*' -o -path '*bin/windows*' -o -path '*bin/darwin*' -o -name '*tar\.gz' \) ); do
    filepath=$(realpath --relative-base=${ASSET_ROOT} $file )
    sha256sum "$filepath" | tee -a $SHA256SUM > "$file.sha256" || return 1
    sha512sum "$filepath" | tee -a $SHA512SUM > "$file.sha512" || return 1
done

mv $SHA256SUM $SHA512SUM "$ASSET_ROOT"
sha256sum SHA256SUM > "SHA256SUM.sha256" || return 1
sha512sum SHA256SUM > "SHA256SUM.sha512" || return 1
sha256sum SHA512SUM > "SHA512SUM.sha256" || return 1
sha512sum SHA512SUM > "SHA512SUM.sha512" || return 1

cat SHA256SUM
cd -
