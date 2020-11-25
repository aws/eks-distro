#!/usr/bin/env bash

function build::version::create_env_file() {
    local -r tag="$1"
    local -r version_file="$2"
    local -r release_file="$3"
    local -r repository="$4"

    git -C $repository checkout $tag
    local -r source_date_epoch=$(git -C $repository show -s --format=format:%ct HEAD)

    cd $repository
    source "${MAKE_ROOT}/$repository/hack/lib/init.sh"
    source "${MAKE_ROOT}/$repository/hack/lib/version.sh"
    kube::version::get_version_vars
    kube::version::save_version_vars $version_file
    cd -

    local -r version_file_cleaned=$version_file.tmp
    local -r release_version=$(cat $release_file)
    local -r kube_git_version="${tag}-eks-distro-${release_version}"

    cat $version_file | sed -e "s/${tag}/${kube_git_version}/g"| grep -v "KUBE_GIT_TREE_STATE" > $version_file_cleaned

    cat << EOF >> $version_file_cleaned
SOURCE_DATE_EPOCH='${source_date_epoch}'
KUBE_GIT_TREE_STATE='archive'
EOF
    mv $version_file_cleaned $version_file
}
