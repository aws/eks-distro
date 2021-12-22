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
RELEASE_BRANCH="$3"
IMAGE_REPO="${4:-}"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

echo "****************************************************************"
echo "A docker container with the name eks-d-builder will be launched."
echo "It will be left running to support running consecutive runs."
echo "Run 'make stop-docker-builder' when you are done to stop it."
echo "****************************************************************"

if ! docker ps -f name=eks-d-builder | grep -w eks-d-builder; then
	docker pull public.ecr.aws/eks-distro-build-tooling/builder-base:latest
	docker run -d --name eks-d-builder --privileged -e GOPROXY=$GOPROXY --entrypoint sleep \
		public.ecr.aws/eks-distro-build-tooling/builder-base:latest  infinity 
fi

rsync -e 'docker exec -i' -rm --exclude='.git/logs/***' \
	--exclude="projects/$PROJECT/_output/***" --exclude="projects/$PROJECT/$(basename $PROJECT)/***" \
	--include="projects/$PROJECT/***" \
	--include='*/' --exclude='projects/***' ./ eks-d-builder:/eks-distro

docker exec -it eks-d-builder make $TARGET -C /eks-distro/projects/$PROJECT RELEASE_BRANCH=$RELEASE_BRANCH IMAGE_REPO=$IMAGE_REPO
