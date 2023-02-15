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
source "${SCRIPT_ROOT}/common.sh"

IMAGE_NAME="$1"
IMAGE="$2"
LATEST_IMAGE="$3"
WINDOWS_IMAGE_VERSIONS="$4"

echo "Creating windows manifest for $IMAGE_NAME"

# this metadate file contains the linux/amd+arm images
if [ ! -f /tmp/$IMAGE_NAME-metadata.json ]; then
    echo "No metadata file for image: /tmp/$IMAGE_NAME-metadata.json!"
    exit 1
fi

# need to remove mediaType from descri since buildx segfaults when it is set
jq -r '."containerimage.descriptor"  | {size, digest}' /tmp/$IMAGE_NAME-metadata.json > /tmp/$IMAGE_NAME-descr-final.json

CREATE_ARGS="-f /tmp/$IMAGE_NAME-descr-final.json "
VERSIONS=(${WINDOWS_IMAGE_VERSIONS// / })
for version in "${VERSIONS[@]}"; do
    if [ ! -f /tmp/$IMAGE_NAME-$version-metadata.json ]; then
        echo "No metadata file for image: /tmp/$IMAGE_NAME-$version-metadata.json!"
        exit 1
    fi

    BASE_IMAGE=$(jq -r '."containerimage.buildinfo".attrs."build-arg:BASE_IMAGE"' /tmp/$IMAGE_NAME-$version-metadata.json)

    # need to remove mediaType from descri since buildx segfaults when it is set
    jq -r '."containerimage.descriptor"  | {size, digest}' /tmp/$IMAGE_NAME-$version-metadata.json > /tmp/$IMAGE_NAME-$version-descr.json
    build::common::echo_and_run retry docker buildx imagetools inspect --raw $BASE_IMAGE | jq '.manifests[0] | {platform}' | jq add -s - /tmp/$IMAGE_NAME-$version-descr.json > /tmp/$IMAGE_NAME-$version-descr-final.json
    cat /tmp/$IMAGE_NAME-$version-descr-final.json
    CREATE_ARGS+="-f /tmp/$IMAGE_NAME-$version-descr-final.json "
done


build::common::echo_and_run retry docker buildx imagetools create --dry-run $CREATE_ARGS -t $IMAGE -t $LATEST_IMAGE > /tmp/$IMAGE_NAME-manfiest-final.json

cat  /tmp/$IMAGE_NAME-manfiest-final.json

if [ "$(jq '.manifests[].platform.os' /tmp/$IMAGE_NAME-manfiest-final.json |  grep -w -c windows)" != "${#VERSIONS[@]}" ]; then
    echo "image manifest does not contain correct number of windows images!"
    exit 1
fi

if [ "$(jq '.manifests[].platform.os' /tmp/$IMAGE_NAME-manfiest-final.json |  grep -w -c linux)" != "2" ]; then
    echo "image manifest does not contain correct number of linux images!"
    exit 1
fi

if [ "$(jq '.manifests[].platform | select( has("os.version") == true ) | ."os.version"' /tmp/$IMAGE_NAME-manfiest-final.json | wc -l | xargs)" != "${#VERSIONS[@]}" ]; then
    echo "windows images do not have os.version set!"
    exit 1
fi

build::common::echo_and_run retry docker buildx imagetools create $CREATE_ARGS -t $IMAGE -t $LATEST_IMAGE

build::common::echo_and_run retry docker buildx imagetools inspect $IMAGE

# Public ecr's tagging appears to have some delay when retagging existing tags, like latest
# retry the diff to give it time to make sure the latest manifest has been updated to new verion
function validate_latest() {
    if ! diff <(retry docker buildx imagetools inspect $IMAGE --raw) <(retry docker buildx imagetools inspect $LATEST_IMAGE --raw); then
        echo "image manifest and latest manifest do not match!"
        return 1
    fi
}

retry validate_latest

rm -rf /tmp/$IMAGE_NAME-*.json
