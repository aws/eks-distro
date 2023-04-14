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


if [ -n "${OUTPUT_DEBUG_LOG:-}" ]; then
    set -x
fi


function build::common::ensure_tar() {
  if [[ -n "${TAR:-}" ]]; then
    return
  fi

  # Find gnu tar if it is available, bomb out if not.
  TAR=tar
  if which gtar &>/dev/null; then
      TAR=gtar
  elif which gnutar &>/dev/null; then
      TAR=gnutar
  fi
  if ! "${TAR}" --version | grep -q GNU; then
    echo "  !!! Cannot find GNU tar. Build on Linux or install GNU tar"
    echo "      on Mac OS X (brew install gnu-tar)."
    return 1
  fi
}

# Build a release tarball.  $1 is the output tar name.  $2 is the base directory
# of the files to be packaged.  This assumes that ${2}/kubernetes is what is
# being packaged.
function build::common::create_tarball() {
  build::common::ensure_tar

  local -r tarfile=$1
  local -r stagingdir=$2
  local -r repository=$3

  build::common::echo_and_run "${TAR}" czf "${tarfile}" -C "${stagingdir}" $repository --owner=0 --group=0
}

# Generate shasum of tarballs. $1 is the directory of the tarballs.
function build::common::generate_shasum() {

  local -r tarpath=$1

  echo "Writing artifact hashes to shasum files..."

  if [ ! -d "$tarpath" ]; then
    echo "  Unable to find tar directory $tarpath"
    exit 1
  fi

  cd $tarpath
  for file in $(find . -name '*.tar.gz'); do
    filepath=$(basename $file)
    sha256sum "$filepath" > "$file.sha256"
    sha512sum "$filepath" > "$file.sha512"
  done
  cd -
}


function build::gather_licenses() {
  local -r outputdir=$1
  local -r patterns=$2
  local -r golang_version=$3

  # Force deps to only be pulled form vendor directories
  # this is important in a couple cases where license files
  # have to be manually created
  export GOFLAGS=-mod=vendor
  # force platform to be linux to ensure all deps are picked up
  export GOOS=linux 
  export GOARCH=amd64 

  # the version of go used here must be the version go-licenses was installed with
  # by default we use 1.16, but due to changes in 1.17, there are some changes that require using 1.17
  if [ "$golang_version" == "1.20" ]; then
    build::common::use_go_version 1.20
  elif [ "$golang_version" == "1.19" ]; then
    build::common::use_go_version 1.19
  elif [ "$golang_version" == "1.18" ]; then
    build::common::use_go_version 1.18
  elif [ "$golang_version" == "1.17" ]; then
    build::common::use_go_version 1.17
  else
    build::common::use_go_version 1.16
  fi

  if ! command -v go-licenses &> /dev/null
  then
    echo " go-licenses not found.  If you need license or attribution file handling"
    echo " please refer to the doc in docs/development/attribution-files.md"
    exit
  fi

  mkdir -p "${outputdir}/attribution"
  # attribution file generated uses the output go-deps and go-license to gather the necessary
  # data about each dependency to generate the amazon approved attribution.txt files
  # go-deps is needed for module versions
  # go-licenses are all the dependencies found from the module(s) that were passed in via patterns
  build::common::echo_and_run go list -deps=true -json ./... | jq -s ''  > "${outputdir}/attribution/go-deps.json"

  # go-licenses can be a bit noisy with its output and lot of it can be confusing 
  # the following messages are safe to ignore since we do not need the license url for our process
  NOISY_MESSAGES="cannot determine URL for|Error discovering license URL|unsupported package host|contains non-Go code|has empty version|vendor.*\.s$"

  build::common::echo_and_run go-licenses save --force $patterns --save_path "${outputdir}/LICENSES" 2> >(grep -vE "$NOISY_MESSAGES")
  
  build::common::echo_and_run go-licenses csv $patterns 2> >(grep -vE "$NOISY_MESSAGES") > "${outputdir}/attribution/go-license.csv"  

  if cat "${outputdir}/attribution/go-license.csv" | grep -q "^vendor\/golang.org\/x"; then
      echo " go-licenses created a file with a std golang package (golang.org/x/*)"
      echo " prefixed with vendor/.  This most likely will result in an error"
      echo " when generating the attribution file and is probably due to"
      echo " to a version mismatch between the current version of go "
      echo " and the version of go that was used to build go-licenses"
      exit 1
  fi

  if cat "${outputdir}/attribution/go-license.csv" | grep -e ",LGPL-" -e ",GPL-"; then
    echo " one of the dependencies is licensed as LGPL or GPL"
    echo " which is prohibited at Amazon"
    echo " please look into removing the dependency"
    exit 1
  fi

  # go-license is pretty eager to copy src for certain license types
  # when it does, it applies strange permissions to the copied files
  # which makes deleting them later awkward
  # this behavior may change in the future with the following PR
  # https://github.com/google/go-licenses/pull/28
  # We can delete these additional files because we are running go mod vendor
  # prior to this call so we know the source is the same as upstream
  # go-licenses is copying this code because it doesnt know if its be modified or not
  chmod -R 777 "${outputdir}/LICENSES"
  find "${outputdir}/LICENSES" -type f \( -name '*.yml' -o -name '*.go' -o -name '*.mod' -o -name '*.sum' -o -name '*gitignore' \) -delete

  # most of the packages show up the go-license.csv file as the module name
  # from the go.mod file, storing that away since the source dirs usually get deleted
  MODULE_NAME=$(go mod edit -json | jq -r '.Module.Path')
  if [ ! -f ${outputdir}/attribution/root-module.txt ]; then
  	echo $MODULE_NAME > ${outputdir}/attribution/root-module.txt
  fi
}

function build::non-golang::gather_licenses(){
  local -r project="$1"
  local -r git_tag="$2"
  local -r output_dir="$3"
  project_org="$(cut -d '/' -f1 <<< ${project})"
  project_name="$(cut -d '/' -f2 <<< ${project})"
  git clone https://github.com/${project_org}/${project_name}
  cd $project_name
  git checkout $git_tag
  cd ..
  build::non-golang::copy_licenses $project_name $output_dir/LICENSES/github.com/${project_org}/${project_name}
  rm -rf $project_name
}

function build::non-golang::copy_licenses(){
  local -r source_dir="$1"
  local -r destination_dir="$2"
  (cd $source_dir; find . \( -name "*COPYING*" -o -name "*COPYRIGHT*" -o -name "*LICEN[C|S]E*" -o -name "*NOTICE*" \)) |
  while read file
  do
    license_dest=$destination_dir/$(dirname $file)
    mkdir -p $license_dest
    cp -r "${source_dir}/${file}" $license_dest/$(basename $file)
  done
}

function build::generate_attribution(){
  local -r project_root=$1
  local -r golang_version=$2
  local -r output_directory=${3:-"${project_root}/_output"}
  local -r attribution_file=${4:-"${project_root}/ATTRIBUTION.txt"}

  local -r root_module_name=$(cat ${output_directory}/attribution/root-module.txt)
  local -r go_path=$(build::common::get_go_path $golang_version)
  local -r golang_version_tag=$($go_path/go version | grep -o "go[0-9].* ")

  if cat "${output_directory}/attribution/go-license.csv" | grep -e ",LGPL-" -e ",GPL-"; then
    echo " one of the dependencies is licensed as LGPL or GPL"
    echo " which is prohibited at Amazon"
    echo " please look into removing the dependency"
    exit 1
  fi

  build::common::echo_and_run generate-attribution $root_module_name $project_root $golang_version_tag $output_directory 
  cp -f "${output_directory}/attribution/ATTRIBUTION.txt" $attribution_file
}

function build::common::get_go_path() {
  local -r version=$1

  # This is the path where the specific go binary versions reside in our builder-base image
  local -r gorootbinarypath="/go/go${version}/bin"
  # This is the path that will most likely be correct if running locally
  local -r gopathbinarypath="$GOPATH/go${version}/bin"
  if [ -d "$gorootbinarypath" ]; then
    echo $gorootbinarypath
  elif [ -d "$gopathbinarypath" ]; then
    echo $gopathbinarypath
  else
    # not in builder-base, probably running in dev environment
    # return default go installation
    local -r which_go=$(which go)
    echo "$(dirname $which_go)"
  fi
}

function build::common::use_go_version() {
  local -r version=$1

  local -r gobinarypath=$(build::common::get_go_path $version)
  echo "Adding $gobinarypath to PATH"
  # Adding to the beginning of PATH to allow for builds on specific version if it exists
  export PATH=${gobinarypath}:$PATH
  export GOCACHE=$(go env GOCACHE)/$version
}

# Use a seperate build cache for each project/version to ensure there are no
# shared bits which can mess up the final checksum calculation
# this is mostly needed for create checksums locally since in the builds
# different versions of the same project are not built in the same container
function build::common::set_go_cache() {
  local -r project=$1
  local -r git_tag=$2
  export GOCACHE=$(go env GOCACHE)/$project/$git_tag
}

function build::common::re_quote() {
    local -r to_escape=$1
    sed 's/[][()\.^$\/?*+]/\\&/g' <<< "$to_escape"
}
function build::common::wait_for_tag() {
  local -r tag=$1
  sleep_interval=20
  for i in {1..60}; do
    echo "Checking for tag ${tag}..."
    git rev-parse --verify --quiet "${tag}" && echo "Tag ${tag} exists!" && break
    git fetch --tags > /dev/null 2>&1
    echo "Tag ${tag} does not exist!"
    echo "Waiting for tag ${tag}..."
    sleep $sleep_interval
    if [ "$i" = "60" ]; then
      exit 1
    fi
  done
}

function build::common::wait_for_tarball() {
  local -r tarball_url=$1
  sleep_interval=20
  for i in {1..60}; do
    echo "Checking for URL ${tarball_url}..."
    local -r http_code=$(curl -I -L -s -o /dev/null -w "%{http_code}" $tarball_url)
    if [[ "$http_code" == "200" ]]; then 
      echo "Tarball exists!" && break
    fi
    echo "Tarball does not exist!"
    echo "Waiting for tarball to be uploaded to ${tarball_url}"
    sleep $sleep_interval
    if [ "$i" = "60" ]; then
      exit 1
    fi
  done
}

function build::common::get_clone_url() {
  local -r org=$1
  local -r repo=$2
  local -r aws_region=$3

  echo "https://github.com/${org}/${repo}.git"
}

function retry() {
  local n=1
  local max=120
  local delay=5
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        >&2 echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

function build::docker::retry_pull() {
  retry docker pull "$@"
}

function build::common::echo_and_run() {
  >&2 echo "($(pwd)) \$ $*"
  "$@"
}