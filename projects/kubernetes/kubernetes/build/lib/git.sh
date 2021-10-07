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


function build::git::patch() {
    local -r source_dir="$1"
    local -r git_ref="$2"
    local -r patch_dir="$3"

    git -C $source_dir config user.email "prow@amazonaws.com"
    git -C $source_dir config user.name "Prow Bot"
    git -C $source_dir checkout $git_ref
    git -C $source_dir apply --verbose $patch_dir/*
    git -C $source_dir add .
    git -C $source_dir commit -m "EKS Distro build of $git_ref"
}
