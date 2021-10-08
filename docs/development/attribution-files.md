# Attribution.txt file handling in EKS-D

## Overview

All projects distributed as part of EKS-D must be delivered with `ATTRIBUTION.txt` files 
along with all the Licenses for each of its dependencies. For projects distributed via
tarballs, there is a folder named `Licenses` and an `ATTRIBUTION.txt` file in the root folder
next to the build binaries. For container images, the `Licenses` folder and `ATTRIBUTION.txt`
file is added to the `/` folder of the container.  

When adding new project and an `ATTRIBUTION.txt` file, it must be reviewed by the `Amazon Open Source Team`.
These files are checked in under each of the project folders within this repo. When
project versions are updated, the `ATTRIBUTION.txt` must be regenerated based on the new dependencies
and checked in. These do not have to be reviewed by the `Open Source Team`, as long as the changes are just dependency
version updates.

The `Licenses` folders are generated dynamically during the build process using the `go-licenses` tool
to pull them based on the dependencies used by each project.

The `generate-attribution` script is built into the builder-base image used to build all projects.  
Please refer to the [Readme](https://github.com/aws/eks-distro-build-tooling/blob/main/generate-attribution/Readme.md) 
for more information on the process it follows to generate the `ATTRIBUTION.txt` files.

## Adding a new project

When adding a new project, modeling attribution handling from existing project
should be fairly straight forward. There are a couple of potential gotchas to
look out for.

1. `go-licenses` requires "patterns" to be passed in, which are the go file(s) that are
to be searched for dependencies. In most cases, determining these patterns is straightforward.
Investigate the build script being called from the upstream repo and look for the `go build ...`
call. Many times it will be a single file, ex: [coredns](#TODO) `./coredns.go'.  
Sometimes it may be a number of files, such as for [containernetworking/plugins](projects/containernetworking/plugins/build/ceate_binaries.sh)
1. `go-licenses` will occasionally produce a `go-license.csv` file with a root module name
that does not match the go.mod module name. In this case, a `sed` call to manipulate the file to rename
the module should be used before calling generate_attribution, ex [livenessprobe](#TODO)
1. In very rare cases, upstream licenses are handled a bit differently, and `go-licenses` will error out
with something like `Failed to find license....`. These must be investigated on a case by case. There
are a couple of existing examples. [kubernetes](#TODO) has a dependency that is dual licensed, so `go-licenses`
is unable to find a valid license. In this case, it was determined that the license that applies is the Apache2,
and it is manually copied into place before the call to the generate-attribution. [external-snapshotter](#TODO) 
vendors a sub-package, which does not have a LICENSE file in the folder, but the repo's applies.  
In this case, the repo's LICENSE is copied into place within the vendor folder before the call to generate-attribution. 


## Running locally

If trying to generate these files outside of CI and have them match what CI produces, you will need the following:

1. `go get github.com/google/go-licenses`
1. The `golang` version is included in the attribution file, so the different golang versions used to build 
the various projects are required. Run `build/lib/install_go_versions.sh` to install all golang versions locally.
Patch versions must match so validate versions in above scripts match those in [builder-base](https://github.com/aws/eks-distro-build-tooling/blob/main/builder-base/install.sh#L172).
1. Follow the [Readme](https://github.com/aws/eks-distro-build-tooling/blob/main/generate-attribution/Readme.md) 
to set up the `generate-attribution` script.
