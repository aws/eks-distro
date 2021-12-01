# Adding new projects

All projects in this repo follow a common set of processes and organization.

* container images base off of one of the eks-distro-base [variants](https://gallery.ecr.aws/eks-distro-build-tooling/)
* reproducible builds with checked in CHECKSUMS file for validation during build/release
* projects uploading to s3 define an `expected_artifacts` file for validation during build/release
* ATTRIBUTION.txt files are generated using `go-licenses` and checked into the repo
* ATTRIBUTION.txt and LICENSES, gathered from dependencies of project, are added to tarballs and container images
* (some) projects have different versions for different Kubernetes versions, referred to as `release branches`

## Typical folder structure

The following example assumes a RELEASE_BRANCH folder, but for projects without release branches those files
would be in the project root.

```
+-- projects/<upstream_org>/<upstream_repo>
|
	+-- _output (generated)
	+-- <upstream_repo> (generated)
	+-- 1-21
	|
		+-- ATTRIBUTION.txt
		+-- CHECKSUMS
		+-- GIT_TAG
		+-- GOLANG_VERSION
	+-- build
	|
		+-- create_binaries.sh
	+-- docker/linux
	|
		+-- Dockerfile
	+-- expected_artifacts_<upstream_repo> (if s3 artifacts)
	+-- Makefile	
```

## New project

When add a new project, start by copying a Makefile from one of the simpler projects, such as [metrics-server](../../projects/kubernetes-sigs/metrics/Makefile).

The key pieces to setup in the Makefile  are:

* GIT_TAG - This should contain the tag in the upstream repo which is to be built. The 
	Makefile should get this from the GIT_TAG file either in the project root or
	the release branch.
* GOLANG_VERSION - This should contain the version of golang which the upstream repo uses for 
	building this project.  This can be a chore to figure out, typically we go with the verison
	in the go.mod file, however, sometimes you need to look in the upstream Dockerfile 
	or Makefile.  The Makefile should get this from the GOLANG_VERSION file either in the project root or the release branch.
* REPO - upstream repo name.
* COMPONENT - upstream org/repo.
* LICENSE_PACKAGE_FILTER - This should be the pattern used to gather dependencies for this
	specific project.  Typically this will be `.` or `./cmd/<project-name>`. If not set, will default to `SOURCE_PATTERNS`.
	For more refer to [attribution-files](attribution-files.md).
* BINARY_TARGET_FILES - The binary file names to be built, automatically appended with $(OUTPUT_BIN_DIR) and generated for each
	$(BINARY_PLATFORMS).  Passed to `go build -o`.
* SOURCE_PATTERNS - The patterns to pass to `go build`.  Must follow the same ordering as $(BINARY_TARGET_FILES)
* IMAGE_NAMES (optional) - When building multiple images define them via `IMAGE_NAMES` and `local-images` and `images` will automatically
	be created to build the	`amd64` platform in `local-images` and `push` for images.  If not set, weill default to `REPO`.
	These names need to match `IMAGE_NAME` in the below variable `<IMAGE_NAME>_IMAGE`.
* <IMAGE_NAME>_IMAGE_COMPONENT (optional) - Common Makefile will use this if set to override the default 
	component in the `IMAGE` variable.  By default `IMAGE` will be set to `$(IMAGE_REPO)/$(COMPONENT):$(IMAGE_TAG)`

### Scripts

#### create-binaries.sh 

The only required script when adding a new project.  By default, the common
`binaries` target will call create-binaries.sh from the project build directory with the following args
* $TAG - GIT_TAG 
* $BIN_PATH - intended output directory
* $OS - OS to pass to go build via GOOS
* $ARCH - ARCH to pass to go build via GOARCH

It will be called once per os/arch combination we are building for.  By default this is `linux/amd64 linux/arm64`, but
can be overridden in a project Makefile via `BINARY_PLATFORMS`.

### Dockerfile

For projects building container images, docker/linux/Dockerfile is required. `DOCKERFILE_FOLDER` can be used to override
the directory containing the Dockerfile when necessary. This may be necessary if building multiple container images
in the same project.  Refer to [external-snapshotter](../../projects/kubernetes-csi/external-snapshotter/Makefile) as
an example of this.

By default the base image will be `eks-distro-base`, but this can be overridden by setting `BASE_IMAGE_NAME` in
the Makefile.  This base image name should be one of the `eks-distro-base` variants.

Since we building outside of docker, most Dockerfiles look like:

```
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG TARGETARCH
ARG TARGETOS

COPY LICENSES /LICENSES
COPY ATTRIBUTION.txt /ATTRIBUTION.txt
COPY bin/$TARGETOS/$TARGETARCH/<binary> /usr/local/bin/<binary>
ENTRYPOINT ["/usr/local/bin/<binary>"]
CMD ["/usr/local/bin/<binary>"]
```

### Gitignore

During every build process, the upstream Github repository for the project is cloned into the respective project directory under `projects/<upstream_org>/<upstream_repo>`. Hence, it is standard practice to have a `.gitignore` in each project directory with the upstream repository, to prevent Git from tracking the cloned repository. Also, each build generates the `_output` folder which stores the binaries, tarballs and other related artifacts generated by the build. To avoid checking these in, the `_output` folder is also added to `.gitignore`.

### Other files

After setting up the Makefile and create-binaries.sh, we need to generate the CHECKSUMS and ATTRIBUTION.txt.
Please refer to [building-locally](building-locally.md) for resources for generating these two files.


## Other scenarios

### s3-artifacts/tarballs 

Some projects deliver tarballs to s3 and to support this there are additional targets necessary. [aws-iam-authenticator](../../projects/kubernetes-sigs/aws-iam-authenticator/Makefile)
is a good example for reference of this. Setting `HAS_S3_ARTIFACTS` to true in the project's Makefile
will automatically add the necessary pre-reqs to the `build` and `release` targets.


Projects with this requirement need to supply the `expected_artifacts_<repo>` file in their root.

### oci tars

Some projects (etcd, coredns, kubernetes) upload oci tars of the container images to s3.  Set `BUILD_OCI_TARS` to have these built during the `images` target.

### multiple containers

For projects which build multiple containers, DOCKERFILE_FOLDER generally needs overridden and additional <IMAGE_NAME>_NAME variables need to be set
in the Makefile, one per container image to be built. Refer to [external-snapshotter](../../projects/kubernetes-csi/external-snapshotter/Makefile) as
an example of this.

### additional pre-reqs for image builds

Sometimes projects need to run additional targets before building images. [release](../../projects/kubernetes/release/Makefile) is a good example to refer
to for this situation. To add additional pre-reqs to the image builds:

```
$(call IMAGE_TARGETS_FOR_NAME, kube-proxy-base): <new_pre_preq>
```

### fixing licenses

As documented in [attribution-files](attribution-files.md) there are situations where licenses need to be fixed before running attribution generation.
[release](../../projects/kubernetes/release/Makefile) is also an example of this. To handle these cases, projects generally add the following to the Makefile:

```
FIX_LICENSES_TARGET=<location of missing license under vendor directory>

$(FIX_LICENSES_TARGET):
	<wget the license from Github and place it in the vendor directory
	 at the appropriate location>
```

### patching

Kubernetes is the only project which currently requires patches. To support these, the Common.mk will automatically add the following
if a `patches` directory exists.

```
GIT_PATCH_TARGET=$(REPO)/eks-anywhere-patched

$(BINARY_TARGETS): | $(GIT_PATCH_TARGET)

$(GIT_PATCH_TARGET): $(GIT_CHECKOUT_TARGET)
	git -C $(REPO) am $(MAKE_ROOT)/patches/*
	@touch $@ 

```


### kubernetes

[kubernetes](../../projects/kubernetes/kubernetes/Makefile) is an example of just about all of the above uncommon situations in one Makefile. Use
as a reference if new project requires uncommon setup.