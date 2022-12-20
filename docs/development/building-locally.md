# Building locally

All projects in this repo follow a common building (and updating) process.  Make targets are standardized across the repo.
Projects can be built on a Mac or Linux host, as well as using the builder-base docker image used in prow for building.

## Pre-requisites for building on host

* Multiple versions of golang are required to build the various projects.  There is a helper 
[script](../../build/lib/install_go_versions.sh) modeled from the builder-base to install all golang versions locally.  
* If intending on generating checksums or attribution files, patch versions of golang must match. Validate versions in above script match those in [builder-base](https://github.com/aws/eks-distro-build-tooling/blob/main/builder-base/install.sh#L172). If not,
please send a PR updating script in this repo.
* Gathering licenses and generating attribution files requires additional setup outlined [here](attribution-files.md).
* For building container images, buildctl is used instead of docker to match our prow builds.  Running `local-images` targets 
will export images to a tar, but if running `images` targets which push images, a registry is required.  By default,
an ECR repo in the currently logged in AWS account will be used.  A common alternative is to run docker registry locally and override
this default behavior. This can be done with `IMAGE_REPO=localhost:5000 make images`. To run buildkit and the docker registry run from the repo root:
	* `make run-buildkit-and-registry`
	* `export BUILDKIT_HOST=docker-container://buildkitd`
	* `make stop-build-and-registry` to cleanup

## Typical build targets

Each project folder contains a Makefile with the following build targets.  A number of projects container multiple `release-branches` based
on Kubernetes version.  When working with these projects and running any of the following targets, you can override the default with
`RELEASE_BRANCH<1-X> make <target>`.

* `binaries` - clones repo, checks out git tag and builds binaries.
* `local-images` - builds container images and writes to `/tmp/{project}.tar`.
* `images` - builds container images and pushes to configured registry. For a few projects (coredns, etcd, kubernetes) local oci tars are also built
	to be uploaded to s3.
* `gather-licenses` - copies licenses from all project dependencies and puts in `_output/LICENSES` to be included in tarballs and container images.
* `attribution` - regenerate the ATTRIBUTION.txt file, golang versions are important here so make sure you have the same versions as the builder-base.
	There is a periodic job which runs every day to keep these up to date, builds will not fail due to these not being 100% accurate.
* `checksums` - update CHECKSUMS file based on currently built binaries.  Builds should be reproducible across Mac and Linux hosts.
	This should be run when bumping GIT_TAG, changing patches or changing build flags, otherwise should not be changed. 
	Builds will fail if these do not match, but the correct checksums will be outputted to make updating easier.
* `build` - run via prow presubmit, clones repo, build binary(s), gather licenses, build container images, build tarballs and generate attribution file.
	Uses `local-images` to build images which does not push to a registry.
* `release` - run via prow postsubmit, same as `build` except runs `images` to push to a remote registry and `upload-artifacts` to push tars/binaries
	to s3.

## Running in builder-base

It may be easier to ensure building matches that in prow to use the builder-base locally.  There are make target helpers in the root Makefile for this workflow.

* To run a target within a specific project:
	* `make run-target-in-docker MAKE_TARGET=<target> PROJECT=<project> RELEASE_BRANCH=<1-X>`
	* any of the above targets can be used for `<target>`
	* `<project>` will be in the format `org/repo`, ex: `coredns/coredns`
	* A container is launched using the `builder-base:latest` image and the current source tree is copied into it.
	  If also building locally, you may want to run `make clean` to avoid copying unnecessary files into the container.
	* The container will be named `eks-d-builder` and can be accessed to manually run targets or cleanup:
		* `docker exec -it eks-d-builder bash`
	* Subsequent calls to `make run-target-in-docker` will use the same running container.  To stop the container:
		* `make stop-docker-builder`
* Attribution and Checksum generation may be easier to run in docker to avoid needing specific golang versions locally.  Specific make targets exists for these:
	* `make run-attribution-checksums-in-docker RELEASE_BRANCH=<1-X>`
	* This will build, generate attribution and checksums and then copy the resulting files out of the container to host project location.
