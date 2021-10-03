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

PROJECT_ROOT="$1"
RELEASE_BRANCH="$2"
RELEASE="$3"
GIT_TAG="$4"
ARTIFACTS_FOLDER="$5"
FAKE_ARM="${6:-}"
FIND_FILTER="${7:-}"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
FIND_FOLDER=kubernetes-$RELEASE_BRANCH/releases/$RELEASE/artifacts/$ARTIFACTS_FOLDER

cd $MAKE_ROOT

if $FAKE_ARM; then
	echo "Faking arm images since in presubmit we do not build arm images"
	echo "This message should not be displayed when running a prod release build!"
	for file in $(find $FIND_FOLDER -type f $FIND_FILTER -not -path '*\.tar\.gz*' -path '*linux*'); do
		ARM_FILE=${file/amd64/arm64}
		if [ ! -f $ARM_FILE ]; then
			echo "Fake ARM file created at $ARM_FILE"
			mkdir -p $(dirname $ARM_FILE)
			cp -rf $file $ARM_FILE
		fi
	done
fi

find $FIND_FOLDER -type f $FIND_FILTER | sort > /tmp/actual-$ARTIFACTS_FOLDER-files

export RELEASE_BRANCH=$RELEASE_BRANCH
export RELEASE=$RELEASE
export GIT_TAG=$GIT_TAG
export KUBERNETES_GIT_TAG=$(cat projects/kubernetes/kubernetes/$RELEASE_BRANCH/GIT_TAG)
envsubst '$RELEASE_BRANCH:$RELEASE:$GIT_TAG:$KUBERNETES_GIT_TAG' \
	< $PROJECT_ROOT/expected_artifacts_$ARTIFACTS_FOLDER \
	> /tmp/expected-$ARTIFACTS_FOLDER-files


if ! diff /tmp/expected-$ARTIFACTS_FOLDER-files /tmp/actual-$ARTIFACTS_FOLDER-files; then
	echo "Artifacts directory does not matched expected!"
	echo "******************* Actual ******************"
	cat /tmp/actual-$ARTIFACTS_FOLDER-files
	echo "*********************************************"
	exit 1
fi

for file in $(find $FIND_FOLDER -type f $FIND_FILTER -path '*\.docker_image_name'); do	
	if [[ "$(cat $file)" != *:$GIT_TAG-eks-$RELEASE_BRANCH-$RELEASE ]]; then
		echo "$file does not have correct content! Should be: IMAGE_REPO/IMAGE_NAME:$GIT_TAG-eks-$RELEASE_BRANCH-$RELEASE"
		exit 1
	fi
done

for file in $(find $FIND_FOLDER -type f $FIND_FILTER -path '*\.docker_tag'); do
	if [[ "$(cat $file)" != $GIT_TAG-eks-$RELEASE_BRANCH-$RELEASE ]]; then
		echo "$file does not have correct content! Should be: $GIT_TAG-eks-$RELEASE_BRANCH-$RELEASE"
		exit 1
	fi
done
