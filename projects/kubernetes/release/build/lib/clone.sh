#!/usr/bin/env bash

function build::clone::release() {
    local -r clone_url="$1"
    local -r repository="$2"
    local -r tag="$3"

    if [ ! -d $MAKE_ROOT/$repository ]; then
        git clone $clone_url $repository
    fi
    if [[ $tag != "" ]]; then
        git -C $repository checkout $tag
    fi
}
