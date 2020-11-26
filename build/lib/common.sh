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

  "${TAR}" czf "${tarfile}" -C "${stagingdir}" $repository --owner=0 --group=0
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
    sha256sum "$file" > "$file.sha256"
    sha512sum "$file" > "$file.sha512"
  done
  cd -
}
