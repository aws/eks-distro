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

PROJECT="$1"
TARGET="$2"
IMAGE_REPO="${3:-}"
RELEASE_BRANCH="${4:-}"
ARTIFACTS_BUCKET="${5:-}"

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

source "${SCRIPT_ROOT}/common.sh"

echo "****************************************************************"
echo "A docker container with the name eks-d-builder will be launched."
echo "It will be left running to support running consecutive runs."
echo "Run 'make stop-docker-builder' when you are done to stop it."
echo "****************************************************************"

if ! docker ps -f name=eks-d-builder | grep -w eks-d-builder; then
	build::docker::retry_pull public.ecr.aws/eks-distro-build-tooling/builder-base:latest

    NETRC=""
    if [ -f $HOME/.netrc ]; then
        NETRC="--mount type=bind,source=$HOME/.netrc,target=/root/.netrc"
    fi

	docker run -d --name eks-d-builder --privileged $NETRC -e GOPROXY=$GOPROXY --entrypoint sleep \
		public.ecr.aws/eks-distro-build-tooling/builder-base:latest  infinity 
fi

EXTRA_INCLUDES=""
PROJECT_DEPENDENCIES=$(make --no-print-directory -C $MAKE_ROOT/projects/$PROJECT var-value-PROJECT_DEPENDENCIES RELEASE_BRANCH=$RELEASE_BRANCH)
if [ -n "$PROJECT_DEPENDENCIES" ]; then
	DEPS=(${PROJECT_DEPENDENCIES// / })
	for dep in "${DEPS[@]}"; do
		DEP_PRODUCT="$(cut -d/ -f1 <<< $dep)"
		DEP_ORG="$(cut -d/ -f2 <<< $dep)"
		DEP_REPO="$(cut -d/ -f3 <<< $dep)"

		if [[ "$DEP_PRODUCT" == "eksd" ]]; then
			continue
		fi

		EXTRA_INCLUDES+=" --include=projects/$DEP_ORG/$DEP_REPO/***"
	done
fi

rsync -e 'docker exec -i' -t -rm --exclude='.git/***' \
	--exclude="projects/$PROJECT/_output/***" --exclude="projects/$PROJECT/$(basename $PROJECT)/***" \
	--include="projects/$PROJECT/***" $EXTRA_INCLUDES \
	--include='*/' --exclude='projects/***' $MAKE_ROOT/ eks-d-builder:/eks-distro

# Need so git properly finds the root of the repo
CURRENT_HEAD="$(cat $MAKE_ROOT/.git/HEAD | awk '{print $2}')"
docker exec -it eks-d-builder mkdir -p /eks-distro/.git/{refs,objects} /eks-distro/.git/$(dirname $CURRENT_HEAD)
docker cp $MAKE_ROOT/.git/HEAD eks-d-builder:/eks-distro/.git
docker cp $MAKE_ROOT/.git/$CURRENT_HEAD eks-d-builder:/eks-distro/.git/$CURRENT_HEAD

docker exec -it eks-d-builder make $TARGET -C /eks-distro/projects/$PROJECT RELEASE_BRANCH=$RELEASE_BRANCH IMAGE_REPO=$IMAGE_REPO ARTIFACTS_BUCKET=$ARTIFACTS_BUCKET
