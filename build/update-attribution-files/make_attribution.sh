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

set -e
set -o errexit
set -o nounset
set -o pipefail
shopt -s globstar

PROJECT="$1"
TARGET="$2"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
PROJECT_ROOT=$MAKE_ROOT/$PROJECT

OUTPUT_DIR=$MAKE_ROOT/_output
mkdir -p $OUTPUT_DIR
touch $OUTPUT_DIR/total_summary.txt

function build::attribution::generate(){
    make -C $PROJECT_ROOT $TARGET

    if ls $PROJECT_ROOT/_output/**/summary.txt 1> /dev/null 2>&1; then
        for summary in $PROJECT_ROOT/_output/**/summary.txt; do
            sed -i "s/+.*=/ =/g" $summary
            awk -F" => " '{ count[$1]+=$2} END { for (item in count) printf("%s => %d\n", item, count[item]) }' \
                $summary $OUTPUT_DIR/total_summary.txt | sort > $OUTPUT_DIR/total_summary.tmp && mv $OUTPUT_DIR/total_summary.tmp $OUTPUT_DIR/total_summary.txt
        done
    fi
}


# Some projects have specific folders for different kubernetes release
# dynamically find all versions to avoid having to update with every release
RELEASE_FOLDER=$(find $PROJECT_ROOT -type d -name "1-*")

if [ -z "${RELEASE_FOLDER}" ]; then
    build::attribution::generate
else
    LAST_GIT_TAG=""
    LAST_RELEASE_BRANCH=""
    for release in $(cat $MAKE_ROOT/release/SUPPORTED_RELEASE_BRANCHES) ; do
        export RELEASE_BRANCH="$release"

        GIT_TAG="$(cat $PROJECT_ROOT/$release/GIT_TAG)"
        if [ "$GIT_TAG" != "$LAST_GIT_TAG" ]; then
            # clean before regenerating to ensure there are no intermediate files left around
            make -C $PROJECT_ROOT clean clean-go-cache
            build::attribution::generate $release
        else
            # if the git_tags match across release branches, save the output state to avoid
            # rebuilding/regenerating
            if [[ $TARGET == *"checksums"* ]]; then
                echo "Copying $LAST_RELEASE_BRANCH CHECKSUMS to $release"
                mkdir -p $PROJECT_ROOT/_output/$release
                sed "s/$LAST_RELEASE_BRANCH/$release/" $PROJECT_ROOT/$LAST_RELEASE_BRANCH/CHECKSUMS > $PROJECT_ROOT/$release/CHECKSUMS
            fi

            if [[ $TARGET == *"attribution"* ]]; then
                echo "Copying $LAST_RELEASE_BRANCH ATTRIBUTION to $release"
                mkdir -p $PROJECT_ROOT/_output/$release
                cp -rf $PROJECT_ROOT/$LAST_RELEASE_BRANCH/*TTRIBUTION.txt $PROJECT_ROOT/$release
            fi        
            
            if [[ $TARGET == "update-go-mods" ]]; then
                echo "Copying $LAST_RELEASE_BRANCH go.mod and go.sum to $release"
                mkdir -p $PROJECT_ROOT/_output/$release

                # Because some projects (etcd) have nested go.mod/sum, we need to account for that like it does in the makefile
                # I think we have to duplicate what we're doing there, but since BINARY_TARGET_FILES is not in scope I'm trying this instead --
                # find the file and copy it to the same place in the other branches . However this isn't yet working how I expect it to
                # because it doesn't overwrite the go.mod file in subsequent release branch dirs and I'm getting an error that it's trying to 
                # copy over the file in the LAST_RELEASE_BRANCH instead of in the target $release as I expect 

                # Another option could be to just run build::attribution::generate I believe. However that isn't working as expected either. 
                # E.g. I only see ETCDCTL_ATTRIBUTION.txt and not SERVER_ATTRIBUTION.txt. Per BINARY_TARGET_FILES in projects/etcd-io/etcd/Makefile
                # the targets should be BINARY_TARGET_FILES=etcd etcdctl when I believe they should be BINARY_TARGET_FILES=server etcdctl to 
                # correclty line up with the dirs in 1-22+ for etcd. I don't currently know what side effects this would have though. I changed it
                # and tried to run the attributions locally, but I get the error that I'm missing generate-attribution which is built into 
                # the builder base. I can run this in that container but I am not sure if there's a better way to get my changes into the container
                # short of checking out hte branch manually and trying to generate it from there.

                # I take it etcd is like this because it is the only one that lists separate go.mod/sum files and so we have to do all this stuff namespaced
                # 1.21 doesn't have that problem and I see in the overrides that this change was introduced in 1-22 for etcd ver 3.5 

                # Order of next steps
                # - fix this line so it's correclty copying over
                # - run the attributions in the builder base to see if the change to binary_target_files works as I expect it to
                #   and SERVER_ATTRIBUTION.txt is generated correctly for each etcd branch.

                find $PROJECT_ROOT/$LAST_RELEASE_BRANCH -name "go.*" -exec cp -f {} $(echo {} | sed 's/$LAST_RELEASE_BRANCH/$release/g') \;
            fi     
        fi
        LAST_GIT_TAG="$GIT_TAG"
        LAST_RELEASE_BRANCH="$release"
    done
fi

make -C $PROJECT_ROOT clean clean-go-cache
