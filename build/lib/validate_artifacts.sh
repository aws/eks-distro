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
set -f # do not expand find_filter

PROJECT_ROOT="$1"
RELEASE_BRANCH="$2"
RELEASE="$3"
GIT_TAG="$4"
ARTIFACTS_FOLDER="$5"
FAKE_ARM_ARTIFACTS_FOR_VALIDATION="${6:-}"
FIND_FILTER="${7:-}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
FIND_FOLDER=$REPO_ROOT/kubernetes-$RELEASE_BRANCH/releases/$RELEASE/artifacts/$ARTIFACTS_FOLDER
KUBERNETES_GIT_TAG=$(cat $REPO_ROOT/projects/kubernetes/kubernetes/$RELEASE_BRANCH/GIT_TAG)

ACTUAL_FILES=$(mktemp)

if [[ $ARTIFACTS_FOLDER == 'kubernetes' ]]; then
	FIND_FOLDER=$FIND_FOLDER/$KUBERNETES_GIT_TAG
else
	FIND_FOLDER=$FIND_FOLDER/$GIT_TAG
fi

for file in $(find ${FIND_FOLDER} -type f | sort); do
    filepath=$(realpath --relative-base=$FIND_FOLDER $file)
	echo $filepath >> $ACTUAL_FILES
done

EXPECTED_FILES=$(mktemp)

export GIT_TAG=$GIT_TAG

envsubst '$GIT_TAG' \
	< $PROJECT_ROOT/expected_artifacts_$ARTIFACTS_FOLDER \
	> $EXPECTED_FILES

if $FAKE_ARM_ARTIFACTS_FOR_VALIDATION; then
	sed -i '/arm64/d' $EXPECTED_FILES
fi

if ! diff $EXPECTED_FILES $ACTUAL_FILES; then
	echo "Artifacts directory does not matched expected!"
	echo "******************* Actual ******************"
	cat $ACTUAL_FILES
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
