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

function build::version::kube_git_version() {
    local -r tag="$1"
    local -r release_file="$2"
    local -r release_branch="$3"
    local -r release_version=$(cat $release_file)
    echo "${tag}-eks-${release_branch}-${release_version}"
}

function build::version::create_env_file() {
    local -r tag="$1"
    local -r version_file="$2"
    local -r release_file="$3"
    local -r repository="$4"
    local -r release_branch="$5"

    local -r source_date_epoch=$(git -C $repository show -s --format=format:%ct $tag^{commit})
    export KUBE_GIT_COMMIT=$(git  -C $repository rev-list -n 1 $tag)
    export KUBE_GIT_VERSION=$tag
    
    cd $repository
    # make sure the tree is clean, there are a couple cases during the license generation
    # were we copy things into the tree that should be ignored
    git restore .

    source "${MAKE_ROOT}/$repository/hack/lib/init.sh"
    source "${MAKE_ROOT}/$repository/hack/lib/version.sh"
    kube::version::get_version_vars
    kube::version::save_version_vars $version_file
    cd -

    local -r version_file_cleaned=$version_file.tmp
    local -r kube_git_version=$(build::version::kube_git_version $tag $release_file $release_branch)

    cat $version_file | sed -e "s/${tag}/${kube_git_version}/g"| grep -v "KUBE_GIT_TREE_STATE" > $version_file_cleaned

    cat << EOF >> $version_file_cleaned
SOURCE_DATE_EPOCH='${source_date_epoch}'
KUBE_GIT_TREE_STATE='archive'
EOF
    mv $version_file_cleaned $version_file
}
