#!/usr/bin/env bash

function build::git::clone() {
    local -r clone_url="$1"
    local -r repository="$2"

    if [ ! -d $repository ]; then
        git clone $clone_url $repository
    fi
}

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
