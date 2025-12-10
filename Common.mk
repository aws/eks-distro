# Disable built-in rules and variables
MAKEFLAGS+=--no-builtin-rules --warn-undefined-variables
SHELL=bash
.SHELLFLAGS:=-eu -o pipefail -c
.SUFFIXES:
.SECONDEXPANSION:

RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
PROD_ECR_REG?=public.ecr.aws/eks-distro
DEV_ECR_REG?=public.ecr.aws/h1r8a7l5

GIT_HASH=eks-$(RELEASE_BRANCH)-$(RELEASE)

COMPONENT?=$(REPO_OWNER)/$(REPO)
MAKE_ROOT=$(BASE_DIRECTORY)/projects/$(COMPONENT)
PROJECT_PATH?=$(subst $(BASE_DIRECTORY)/,,$(MAKE_ROOT))
BUILD_LIB=${BASE_DIRECTORY}/build/lib
OUTPUT_BIN_DIR?=$(OUTPUT_DIR)/bin/$(REPO)
BUILD_ARTIFACTS?=true

#################### AWS ###########################
AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
ARTIFACT_BUCKET?=my-s3-bucket
ARTIFACTS_BUCKET?=$(ARTIFACT_BUCKET)
IMAGE_REPO?=$(if $(AWS_ACCOUNT_ID),$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com,localhost:5000)
####################################################

#################### LATEST TAG ####################
# codebuild
BRANCH_NAME?=main
# prow
PULL_BASE_REF?=main
LATEST=latest
ifneq ($(BRANCH_NAME),main)
	LATEST=$(BRANCH_NAME)
endif
ifneq ($(PULL_BASE_REF),main)
	LATEST=$(PULL_BASE_REF)
endif
####################################################

#################### CODEBUILD #####################
CODEBUILD_CI?=false
CI?=false
JOB_TYPE?=
CODEBUILD_BUILD_IMAGE?=
CLONE_URL?=$(call GET_CLONE_URL,$(REPO_OWNER),$(REPO))
#HELM_CLONE_URL=$(call GET_CLONE_URL,$(HELM_SOURCE_OWNER),$(HELM_SOURCE_REPOSITORY))
HELM_CLONE_URL=https://github.com/$(HELM_SOURCE_OWNER)/$(HELM_SOURCE_REPOSITORY).git
ARTIFACTS_PATH?=$(MAKE_ROOT)/_output/tar
ifeq ($(CODEBUILD_CI),true)
	UPLOAD_DRY_RUN=false
	BUILD_IDENTIFIER=$(CODEBUILD_BUILD_NUMBER)
else
	UPLOAD_DRY_RUN=$(if $(findstring postsubmit,$(JOB_TYPE)),false,true)
	ifeq ($(CI),true)
		BUILD_IDENTIFIER=$(PROW_JOB_ID)
	else
		BUILD_IDENTIFIER:=$(shell date "+%F-%s")
	endif
endif
EXCLUDE_FROM_STAGING_BUILDSPEC?=false
BUILDSPECS?=buildspec.yml
BUILDSPEC_VARS_KEYS?=
BUILDSPEC_VARS_VALUES?=
####################################################

#################### GIT ###########################
GIT_CHECKOUT_TARGET?=$(REPO)/eks-distro-checkout-$(GIT_TAG)
GIT_PATCH_TARGET?=$(REPO)/eks-distro-patched
REPO_NO_CLONE?=false
PATCHES_DIR=$(or $(wildcard $(PROJECT_ROOT)/patches),$(wildcard $(MAKE_ROOT)/patches))
REPO_SPARSE_CHECKOUT?=
####################################################

#################### RELEASE BRANCHES ##############
HAS_RELEASE_BRANCHES?=false
RELEASE_BRANCH?=
SUPPORTED_K8S_VERSIONS:=$(shell cat $(BASE_DIRECTORY)/release/SUPPORTED_RELEASE_BRANCHES)
# Comma-separated list of Kubernetes versions to skip building artifacts for
SKIPPED_K8S_VERSIONS?=
BINARIES_ARE_RELEASE_BRANCHED?=true
IS_RELEASE_BRANCH_BUILD=$(filter true,$(HAS_RELEASE_BRANCHES))
IS_UNRELEASE_BRANCH_TARGET=$(and $(filter false,$(BINARIES_ARE_RELEASE_BRANCHED)),$(filter binaries attribution checksums,$(MAKECMDGOALS)))
TARGETS_ALLOWED_WITH_NO_RELEASE_BRANCH?=build release clean clean-go-cache help
MAKECMDGOALS_WITHOUT_VAR_VALUE=$(foreach t,$(MAKECMDGOALS),$(if $(findstring var-value-,$(t)),,$(t)))
ifneq ($(and $(IS_RELEASE_BRANCH_BUILD),$(or $(RELEASE_BRANCH),$(IS_UNRELEASE_BRANCH_TARGET))),)
	RELEASE_BRANCH_SUFFIX=$(if $(filter true,$(BINARIES_ARE_RELEASE_BRANCHED)),/$(RELEASE_BRANCH),)

	ARTIFACTS_PATH:=$(ARTIFACTS_PATH)$(RELEASE_BRANCH_SUFFIX)
	OUTPUT_DIR?=_output$(RELEASE_BRANCH_SUFFIX)
	PROJECT_ROOT?=$(MAKE_ROOT)$(RELEASE_BRANCH_SUFFIX)
	ARTIFACTS_UPLOAD_PATH?=$(PROJECT_PATH)$(RELEASE_BRANCH_SUFFIX)

	# Deps are always released branched
	BINARY_DEPS_DIR?=_output/$(RELEASE_BRANCH)/dependencies

	# include release branch info in latest tag
	LATEST_TAG?=$(GIT_TAG)-eks-$(RELEASE_BRANCH)-$(LATEST)
else ifneq ($(and $(IS_RELEASE_BRANCH_BUILD), $(filter-out $(TARGETS_ALLOWED_WITH_NO_RELEASE_BRANCH),$(MAKECMDGOALS_WITHOUT_VAR_VALUE))),)
	# if project has release branches and not calling one of the above targets
$(error When running targets for this project other than `$(TARGETS_ALLOWED_WITH_NO_RELEASE_BRANCH)` a `RELEASE_BRANCH` is required)
else ifneq ($(IS_RELEASE_BRANCH_BUILD),)
	# project has release branches and one was not specified, trigger target for all
	BUILD_TARGETS=build/release-branches/all
	RELEASE_TARGETS=release/release-branches/all

	# avoid warnings when trying to read GIT_TAG file which wont exist when no release_branch is given
	GIT_TAG=non-existent
	OUTPUT_DIR=non-existent
else
	PROJECT_ROOT?=$(MAKE_ROOT)
	ARTIFACTS_UPLOAD_PATH?=$(PROJECT_PATH)
	OUTPUT_DIR?=_output
	LATEST_TAG?=$(LATEST)
endif

####################################################

#################### BASE IMAGES ###################
BASE_IMAGE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-minimal-base
BASE_IMAGE_TAG_FILE?=$(BASE_DIRECTORY)/$(shell echo $(BASE_IMAGE_NAME) | tr '[:lower:]' '[:upper:]' | tr '-' '_')_TAG_FILE
BASE_IMAGE_TAG?=$(shell cat $(BASE_IMAGE_TAG_FILE))
BASE_IMAGE?=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG)
BUILDER_IMAGE?=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME)-builder:$(BASE_IMAGE_TAG)
EKS_DISTRO_BASE_IMAGE=$(BASE_IMAGE_REPO)/eks-distro-base:$(shell cat $(BASE_DIRECTORY)/EKS_DISTRO_BASE_TAG_FILE)
####################################################

#################### IMAGES ########################
IMAGE_COMPONENT?=$(COMPONENT)
IMAGE_OUTPUT_DIR?=/tmp
IMAGE_OUTPUT_NAME?=$(IMAGE_NAME)
IMAGE_TARGET?=

IMAGE_NAMES?=$(REPO)

# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
IMAGE_TAG?=$(GIT_TAG)-$(GIT_HASH)
# For projects with multiple containers this is defined to override the default
# ex: CLUSTER_API_CONTROLLER_IMAGE_COMPONENT
IMAGE_COMPONENT_VARIABLE=$(call TO_UPPER,$(IMAGE_NAME))_IMAGE_COMPONENT
IMAGE_REPO_COMPONENT=$(call IF_OVERRIDE_VARIABLE,$(IMAGE_COMPONENT_VARIABLE),$(IMAGE_COMPONENT))
IMAGE=$(IMAGE_REPO)/$(IMAGE_REPO_COMPONENT):$(IMAGE_TAG)
LATEST_IMAGE=$(IMAGE:$(lastword $(subst :, ,$(IMAGE)))=$(LATEST_TAG))

IMAGE_USERADD_USER_ID?=1000
IMAGE_USERADD_USER_NAME?=

# Cache should be loaded from a number of potential sources
# Pulls cache from the oldest (first in the list) kube version for cases where component versions match.
# It uses the oldest, because that's the one that should be built first during the release and so be available
# for the other release branches as a layer cache when they build the project in question. 
# - latest tag from repo, if there the latest prod image cache matches what we are about to build, that should take precedent
# - latest tag from dev repo

COMMA=,

# $1 - release branch
CACHE_IMPORT_IMAGES=$(foreach reg,$(PROD_ECR_REG) $(DEV_ECR_REG),type=registry$(COMMA)ref=$(reg)/$(call IF_OVERRIDE_VARIABLE,$(IMAGE_COMPONENT_VARIABLE),$(IMAGE_COMPONENT)):$(GIT_TAG)-eks-$(1)-latest)

OLDEST_BRANCH_WITH_SAME_GIT_TAG=$(firstword $(foreach branch,$(SUPPORTED_K8S_VERSIONS),$(if $(filter $(GIT_TAG),$(shell cat ./$(branch)/GIT_TAG)),$(branch))))

IMAGE_IMPORT_CACHE?=$(call CACHE_IMPORT_IMAGES,$(OLDEST_BRANCH_WITH_SAME_GIT_TAG))

BUILD_OCI_TARS?=false

LOCAL_IMAGE_TARGETS=$(if $(filter-out true,$(BUILD_ARTIFACTS)),,$(foreach image,$(IMAGE_NAMES),$(image)/images/amd64) $(if $(filter true,$(HAS_HELM_CHART)),helm/build,))
IMAGE_TARGETS=$(if $(filter-out true,$(BUILD_ARTIFACTS)),,$(foreach image,$(IMAGE_NAMES),$(if $(filter true,$(BUILD_OCI_TARS)),$(call IMAGE_TARGETS_FOR_NAME,$(image)),$(image)/images/push)) $(if $(filter true,$(HAS_HELM_CHART)),helm/push,)) 

############# WINDOWS #############################
# similar to https://github.com/kubernetes-csi/livenessprobe/blob/master/release-tools/prow.sh#L78
WINDOWS_IMAGE_VERSIONS=1809 20H2 ltsc2022

# if multiple platforms requested, remove windows since it will be
# built by itself with a different dockerfile
IMAGE_PLATFORMS_WITHOUT_WINDOWS=$(or $(subst windows/amd64,,$(IMAGE_PLATFORMS)),$(IMAGE_PLATFORMS))

# <image>.<osversion</windows/images/push
WINDOWS_IMAGE_BUILD_TARGETS_FOR_IMAGE=$(if $(findstring windows/amd64,$(IMAGE_PLATFORMS)) \
	,$(foreach ver,$(WINDOWS_IMAGE_VERSIONS),$(IMAGE_NAME).$(ver)/windows/images/push),)
####################################################

# If running in the builder base on prow or codebuild, grab the current tag to be used when building with cgo
CURRENT_BUILDER_BASE_TAG=$(or $(and $(wildcard /config/BUILDER_BASE_TAG_FILE),$(shell cat /config/BUILDER_BASE_TAG_FILE)),latest)
CURRENT_BUILDER_BASE_IMAGE=$(if $(CODEBUILD_BUILD_IMAGE),$(CODEBUILD_BUILD_IMAGE),$(BASE_IMAGE_REPO)/builder-base:$(CURRENT_BUILDER_BASE_TAG))

####################################################

#################### HELM ##########################
HAS_HELM_CHART?=false
HELM_SOURCE_OWNER?=$(REPO_OWNER)
HELM_SOURCE_REPOSITORY?=$(REPO)
HELM_SOURCE_IMAGE_REPO?=$(IMAGE_REPO)
HELM_GIT_TAG?=$(GIT_TAG)
HELM_TAG?=$(GIT_TAG)-$(GIT_HASH)
HELM_USE_UPSTREAM_IMAGE?=false
# HELM_DIRECTORY must be a relative path from project root to the directory that contains a chart
HELM_DIRECTORY?=.
HELM_DESTINATION_REPOSITORY?=$(IMAGE_COMPONENT)
HELM_IMAGE_LIST?=
HELM_GIT_CHECKOUT_TARGET?=$(HELM_SOURCE_REPOSITORY)/eks-distro-checkout-$(HELM_GIT_TAG)
HELM_GIT_PATCH_TARGET?=$(HELM_SOURCE_REPOSITORY)/eks-distro-helm-patched
####################################################

#### HELPERS ########
# https://riptutorial.com/makefile/example/23643/zipping-lists
# Used to generate binary targets based on BINARY_TARGET_FILES
list-rem = $(wordlist 2,$(words $1),$1)

pairmap = $(and $(strip $2),$(strip $3),$(call \
    $1,$(firstword $2),$(firstword $3)) $(call \
    pairmap,$1,$(call list-rem,$2),$(call list-rem,$3)))

trimap = $(and $(strip $2),$(strip $3),$(strip $4),$(call \
    $1,$(firstword $2),$(firstword $3),$(firstword $4)) $(call \
    trimap,$1,$(call list-rem,$2),$(call list-rem,$3),$(call list-rem,$4)))

_pos = $(if $(filter $1,$2),$(call _pos,$1,\
       $(call list-rem,$2),x $3),$3)
pos = $(words $(call _pos,$1,$2,))

# TODO: this exist in the gmsl, https://gmsl.sourceforge.io/
# look into introducting gmsl for things like this
# this function gets called a few dozen times and the alternative of using shell with tr takes
# noticeablely longer
TO_UPPER = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst \
	f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst \
	m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst \
	t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$(subst -,_,$(1))))))))))))))))))))))))))))

TO_LOWER = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst \
	F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst \
	M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst \
	T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$(subst _,-,$(1))))))))))))))))))))))))))))

# $1 - potential override variable name
# $2 - value if variable not set
# returns value of override var if one is set, otherwise returns $(2)
# intentionally no tab/space since it would come out in the result of calling this func
IF_OVERRIDE_VARIABLE=$(if $(filter undefined,$(origin $1)),$(2),$(value $(1)))

# $1 - image name
IMAGE_TARGETS_FOR_NAME=$(addsuffix /images/push, $(1)) $(addsuffix /images/amd64, $(1)) $(addsuffix /images/arm64, $(1))

# $1 - binary file name
FULL_FETCH_BINARIES_TARGETS=$(foreach platform,$(BINARY_PLATFORMS),$(addprefix $(BINARY_DEPS_DIR)/$(subst /,-,$(platform))/, $(1)))

# Based on PROJECT_DEPENDENCIES, generate fetch binaries targets, only projects with s3 artifacts will be fetched
PROJECT_DEPENDENCIES_TARGETS=$(foreach dep,$(PROJECT_DEPENDENCIES), \
	$(eval project_path_parts:=$(subst /, ,$(dep))) \
	$(eval project_path:=$(BASE_DIRECTORY)/projects/$(word 2,$(project_path_parts))/$(word 3,$(project_path_parts))) \
	$(if $(or $(findstring eksd,$(dep)), \
		$(and \
			$(if $(wildcard $(project_path)),true,$(error Non-existent dependency: $(dep))), \
			$(filter true,$(shell $(MAKE) -C $(project_path) var-value-HAS_S3_ARTIFACTS)) \
		)),$(call FULL_FETCH_BINARIES_TARGETS,$(dep)),))

# $1 - targets
# $2 - platforms
BINARY_TARGETS_FROM_FILES_PLATFORMS=$(foreach platform, $(2), $(foreach target, $(1), \
		$(OUTPUT_BIN_DIR)/$(subst /,-,$(platform))/$(if $(findstring windows,$(platform)),$(target).exe,$(target))))

# This "function" is used to construct the git clone URL for projects.
# Indenting the block results in the URL getting prefixed with a
# space, hence no indentation below.
# $1 - repo owner
# $2 - repo
GET_CLONE_URL=$(shell source $(BUILD_LIB)/common.sh && build::common::get_clone_url $(1) $(2) $(AWS_REGION))

# $1 - binary file name
# $2 - go mod path for binary
# returns full target path for given binary + go mod path
# if the go mod path is `.` then do not prefix attribution dir, otherwise use binary name
LICENSE_TARGET_FROM_BINARY_GO_MOD=$(call LICENSE_OUTPUT_FROM_BINARY_GO_MOD,$(1),$(2))attribution/go-license.csv

# $1 - binary file name
# $2 - go mod path for binary
# return $1 if the go mod path is not the first, unless there is an override var for the binary
ATTRIBUTION_PREFIX_FROM_BINARY_GO_MOD=$(or \
	$(call IF_OVERRIDE_VARIABLE,$(call TO_UPPER,$(1))_ATTRIBUTION_OVERRIDE,), \
	$(if $(strip $(filter-out $(word 1,$(GO_MOD_PATHS)),$(2))),$(1),))

# $1 - binary file name
# $2 - go mod path for binary
# returns full path to create attribution/licenses directory
LICENSE_OUTPUT_FROM_BINARY_GO_MOD=$(LICENSES_OUTPUT_DIR)/$(call ADD_TRAILING_CHAR,$(call ATTRIBUTION_PREFIX_FROM_BINARY_GO_MOD,$(1),$(2)),/)

# $1 - binary file name
# $2 - go mod path for binary
# returns attribution target for given binary + go mod path
ATTRIBUTION_TARGET_FROM_BINARY_GO_MOD=$(if $(and $(IS_RELEASE_BRANCH_BUILD),$(filter \
	true,$(BINARIES_ARE_RELEASE_BRANCHED))),$(RELEASE_BRANCH)/,)$(call ADD_TRAILING_CHAR,$(call TO_UPPER,$(call ATTRIBUTION_PREFIX_FROM_BINARY_GO_MOD,$(1),$(2))),_)ATTRIBUTION.txt

# $1 - go mod path
GO_MOD_DOWNLOAD_TARGET_FROM_GO_MOD_PATH=$(REPO)/$(if $(filter-out .,$(1)),$(1)/,)eks-distro-go-mod-download

# $1 - binary file name
GO_MOD_TARGET_FOR_BINARY_VAR_NAME= \
	GO_MOD_TARGET_FOR_BINARY_$(call TO_UPPER,$(call IF_OVERRIDE_VARIABLE,$(call TO_UPPER,$(1))_ATTRIBUTION_OVERRIDE,$(1)))

# $1 - value
# $2 - char
# if value is non empty, add trailing $2
# intentionally no tab/space since it would come out in the result of calling this func
ADD_TRAILING_CHAR=$(if $(1),$(1)$(2),)

# check if pass variable has length of 1
IS_ONE_WORD=$(if $(filter 1,$(words $(1))),true,false)

####################################################

#################### BINARIES ######################
# if the pattern ends in the same as a previous pattern, binary must be built separately
# if the go mod path has changed from the main, must be built separately
# if binary is already in the BINARY_TARGET_FILES_BUILD_ALONE list do not add, but properly add source pattern and go mod
# $1 - binary file name
# $2 - source pattern
# $3 - go mod path for binary
setup_build_alone_vs_together = \
	$(eval type:=$(if $(or \
			$(call IF_OVERRIDE_VARIABLE,_UNIQ_PATTERN_$(notdir $(2)),), \
			$(filter-out $(word 1,$(GO_MOD_PATHS)),$(3)), \
			$(filter $(1),$(BINARY_TARGET_FILES_BUILD_ALONE))) \
		,ALONE,TOGETHER)) \
	$(if $(filter $(1),$(BINARY_TARGET_FILES_BUILD_ALONE)),,$(eval BINARY_TARGET_FILES_BUILD_$(type)+=$(1))) \
	$(eval SOURCE_PATTERNS_BUILD_$(type)+=$(2)) \
	$(eval GO_MOD_PATHS_BUILD_$(type)+=$(3)) \
	$(eval _UNIQ_PATTERN_$(notdir $(2)):=1)

# Setup vars UNIQ_GO_MOD_PATHS UNIQ_GO_MOD_TARGET_FILES
# which will store the mapping of uniq go_mod paths to first target file for respective go mod
# $1 - binary file name
# $2 - source pattern
# $3 - go mod path for binary
setup_uniq_go_mod_license_filters = \
	$(if $(call IF_OVERRIDE_VARIABLE,GO_MOD_$(subst /,_,$(3))_LICENSE_PACKAGE_FILTER,),, \
			$(eval UNIQ_GO_MOD_PATHS+=$(3)) \
			$(eval UNIQ_GO_MOD_TARGET_FILES+=$(1))) \
			$(eval $(call GO_MOD_TARGET_FOR_BINARY_VAR_NAME,$(1))=$(3)) \
	$(eval GO_MOD_$(subst /,_,$(3))_LICENSE_PACKAGE_FILTER+=$(call IF_OVERRIDE_VARIABLE,LICENSE_PACKAGE_FILTER,$(2)))

BINARY_PLATFORMS?=linux/amd64 linux/arm64
SIMPLE_CREATE_BINARIES?=true

BINARY_TARGETS?=$(if $(filter-out true,$(BUILD_ARTIFACTS)),,$(call BINARY_TARGETS_FROM_FILES_PLATFORMS, $(BINARY_TARGET_FILES), $(BINARY_PLATFORMS)))
BINARY_TARGET_FILES?=
SOURCE_PATTERNS?=$(foreach _,$(BINARY_TARGET_FILES),.)
GO_MOD_PATHS?=$(foreach _,$(BINARY_TARGET_FILES),.)

# There may not any that need building alone, defining empty vars in case not set from above
BINARY_TARGET_FILES_BUILD_ALONE?=
SOURCE_PATTERNS_BUILD_ALONE?=
GO_MOD_PATHS_BUILD_ALONE?=
UNIQ_GO_MOD_PATHS?=
$(call trimap,setup_build_alone_vs_together,$(BINARY_TARGET_FILES),$(SOURCE_PATTERNS),$(GO_MOD_PATHS))
$(call trimap,setup_uniq_go_mod_license_filters,$(BINARY_TARGET_FILES),$(SOURCE_PATTERNS),$(GO_MOD_PATHS))

GO_MOD_DOWNLOAD_TARGETS?=$(foreach path, $(UNIQ_GO_MOD_PATHS), $(call GO_MOD_DOWNLOAD_TARGET_FROM_GO_MOD_PATH,$(path)))

VENDOR_UPDATE_SCRIPT?=
#### CGO ############
CGO_CREATE_BINARIES?=false
CGO_SOURCE=$(OUTPUT_DIR)/source
IS_ON_BUILDER_BASE?=$(shell if [ -f /buildkit.sh ]; then echo true; fi;)
BUILDER_PLATFORM?=$(shell echo $$(go env GOHOSTOS)/$$(go env GOHOSTARCH))
needs-cgo-builder=$(and $(if $(filter true,$(CGO_CREATE_BINARIES)),true,),$(if $(filter-out $(1),$(BUILDER_PLATFORM)),true,))
USE_DOCKER_FOR_CGO_BUILD?=false
DOCKER_USE_ID_FOR_LINUX=$(shell if [ "$$(uname -s)" = "Linux" ] && [ -n "$${USER:-}" ]; then echo "-u $$(id -u $${USER}):$$(id -g $${USER})"; fi)
GO_MOD_CACHE=$(shell source $(BUILD_LIB)/common.sh && build::common::use_go_version $(GOLANG_VERSION) > /dev/null 2>&1 && go env GOMODCACHE)
GO_BUILD_CACHE=$(shell source $(BUILD_LIB)/common.sh && build::common::use_go_version $(GOLANG_VERSION) > /dev/null 2>&1 && go env GOCACHE)
CGO_TARGET?=
######################

#### BUILD FLAGS ####
ifeq ($(CGO_CREATE_BINARIES),true)
	CGO_ENABLED=1
	GO_LDFLAGS?=-s -w -buildid= $(EXTRA_GO_LDFLAGS)
	CGO_LDFLAGS?=-Wl,--build-id=none
	EXTRA_GOBUILD_FLAGS?=-gcflags=-trimpath=$(MAKE_ROOT) -asmflags=-trimpath=$(MAKE_ROOT)
else
	CGO_ENABLED=0
	GO_LDFLAGS?=-s -w -buildid= -extldflags -static $(EXTRA_GO_LDFLAGS)
	CGO_LDFLAGS?=
	EXTRA_GOBUILD_FLAGS?=
endif
EXTRA_GO_LDFLAGS?=
GOBUILD_COMMAND?=build
######################

############### BINARIES DEPS ######################
BINARY_DEPS_DIR?=$(OUTPUT_DIR)/dependencies
PROJECT_DEPENDENCIES?=
HANDLE_DEPENDENCIES_TARGET=handle-dependencies
####################################################

#################### LICENSES ######################
HAS_LICENSES?=true
ATTRIBUTION_TARGETS?=$(if $(filter-out true,$(BUILD_ARTIFACTS)),,$(call pairmap,ATTRIBUTION_TARGET_FROM_BINARY_GO_MOD,$(BINARY_TARGET_FILES),$(GO_MOD_PATHS)))
GATHER_LICENSES_TARGETS?=$(if $(filter-out true,$(BUILD_ARTIFACTS)),,$(call pairmap,LICENSE_TARGET_FROM_BINARY_GO_MOD,$(BINARY_TARGET_FILES),$(GO_MOD_PATHS)))
LICENSES_OUTPUT_DIR?=$(OUTPUT_DIR)
LICENSES_TARGETS_FOR_PREREQ=$(if $(filter true,$(HAS_LICENSES)),$(GATHER_LICENSES_TARGETS) \
	$(foreach target,$(ATTRIBUTION_TARGETS),_output/$(target)),)
####################################################

#################### COPY ARTIFACTS MODE ###########
ifneq ($(filter-out true,$(BUILD_ARTIFACTS)),)
ifneq ($(COPY_ARTIFACTS_SCRIPT),)

.PHONY: copy-artifacts
copy-artifacts:
	@echo -e $(call TARGET_START_LOG)
	@echo "Copying artifacts from source..."
	@mkdir -p $(OUTPUT_DIR)
	@$(COPY_ARTIFACTS_SCRIPT)
	@echo -e $(call TARGET_END_LOG)

endif
endif
####################################################

#################### TARBALLS ######################
HAS_S3_ARTIFACTS?=false

SIMPLE_CREATE_TARBALLS?=true
TAR_FILE_PREFIX?=$(REPO)
FAKE_ARM_BINARIES_FOR_VALIDATION?=$(if $(filter linux/arm64,$(BINARY_PLATFORMS)),false,true)
FAKE_ARM_IMAGES_FOR_VALIDATION?=false
IMAGE_FORMAT?=
IMAGE_OS?=
####################################################

#################### OTHER #########################
KUSTOMIZE_TARGET=$(OUTPUT_DIR)/kustomize
GIT_DEPS_DIR?=$(OUTPUT_DIR)/gitdependencies
SPECIAL_TARGET_SECONDARY=$(strip $(PROJECT_DEPENDENCIES_TARGETS) $(GO_MOD_DOWNLOAD_TARGETS))
SKIP_CHECKSUM_VALIDATION?=false
IN_DOCKER_TARGETS=all-attributions all-attributions-checksums all-checksums attribution attribution-checksums binaries checksums clean clean-go-cache
####################################################

#################### LOGGING #######################
DATE_CMD=TZ=utc $(shell if [ "$$(uname -s)" = "Darwin" ] && command -v gdate &> /dev/null; then echo gdate; else echo date; fi)
DATE_NANO=$(shell if [ "$$(uname -s)" = "Linux" ] || command -v gdate &> /dev/null; then echo %3N; fi)
TARGET_START_LOG?=$(eval _START_TIME:=$(shell $(DATE_CMD) +%s.$(DATE_NANO)))\\n------------------- $(shell $(DATE_CMD) +"%Y-%m-%dT%H:%M:%S.$(DATE_NANO)%z") Starting target=$@ -------------------
TARGET_END_LOG?="------------------- `$(DATE_CMD) +'%Y-%m-%dT%H:%M:%S.$(DATE_NANO)%z'` Finished target=$@ duration=`echo $$($(DATE_CMD) +%s.$(DATE_NANO)) - $(_START_TIME) | bc` seconds -------------------\\n"
####################################################

#################### TARGETS FOR OVERRIDING ########
BUILD_TARGETS?=validate-checksums attribution $(if $(IMAGE_NAMES),local-images,) $(if $(filter true,$(HAS_HELM_CHART)),helm/build,) $(if $(filter true,$(HAS_S3_ARTIFACTS)),upload-artifacts,) attribution-pr
RELEASE_TARGETS?=validate-checksums $(if $(IMAGE_NAMES),images,) $(if $(filter true,$(HAS_HELM_CHART)),helm/push,) $(if $(filter true,$(HAS_S3_ARTIFACTS)),upload-artifacts,)
####################################################

define BUILDCTL
		$(BUILD_LIB)/buildkit.sh \
			build \
			--frontend dockerfile.v0 \
			--opt platform=$(IMAGE_PLATFORMS_WITHOUT_WINDOWS:,=) \
			--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
			--opt build-arg:BUILDER_IMAGE=$(BUILDER_IMAGE) \
			$(foreach BUILD_ARG,$(IMAGE_BUILD_ARGS),--opt build-arg:$(BUILD_ARG)=$($(BUILD_ARG))) \
			--progress plain \
			--local dockerfile=$(DOCKERFILE_FOLDER) \
			--local context=$(IMAGE_CONTEXT_DIR) \
			$(if $(filter push=true,$(IMAGE_OUTPUT)),--export-cache type=inline,) \
			$(foreach IMPORT_CACHE,$(IMAGE_IMPORT_CACHE),--import-cache $(IMPORT_CACHE)) \
			$(if $(IMAGE_METADATA_FILE),--metadata-file $(IMAGE_METADATA_FILE),) \
			--opt target=$(IMAGE_TARGET) \
			--output type=$(IMAGE_OUTPUT_TYPE),oci-mediatypes=true,\"name=$(ALL_IMAGE_TAGS)\",$(IMAGE_OUTPUT)
endef

define CGO_DOCKER
	source $(BUILD_LIB)/common.sh && build::docker::retry_pull --platform $(IMAGE_PLATFORMS) $(BUILDER_IMAGE); \
	INTERACTIVE="$(shell if [ -t 0 ]; then echo '-it'; fi)"; \
	docker run --rm $$INTERACTIVE -w /eks-distro/projects/$(COMPONENT) $(DOCKER_USE_ID_FOR_LINUX) \
		--mount type=bind,source=$(BASE_DIRECTORY),target=/eks-distro \
		--mount type=bind,source=$(GO_MOD_CACHE),target=/mod-cache \
		-e GOPROXY=$(GOPROXY) -e GOMODCACHE=/mod-cache \
		--platform $(IMAGE_PLATFORMS) \
		--init $(BUILDER_IMAGE) make $(CGO_TARGET) BINARY_PLATFORMS=$(IMAGE_PLATFORMS)
endef

define SIMPLE_CREATE_BINARIES_SHELL
	$(BASE_DIRECTORY)/build/lib/simple_create_binaries.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_PATH) $(REPO) $(GOLANG_VERSION) $(PLATFORM) "$(SOURCE_PATTERN)" \
		"$(GOBUILD_COMMAND)" "$(EXTRA_GOBUILD_FLAGS)" "$(GO_LDFLAGS)" $(CGO_ENABLED) "$(CGO_LDFLAGS)" "$(GO_MOD_PATH)" "$(BINARY_TARGET_FILES_BUILD_TOGETHER)"
endef

# $1 - make target
# $2 - target directory
define CGO_CREATE_BINARIES_SHELL
	$(MAKE) binary-builder/cgo/$(PLATFORM:linux/%=%) IMAGE_OUTPUT=dest=$(OUTPUT_BIN_DIR)/$(2) CGO_TARGET=$(1) IMAGE_BUILD_ARGS="GOPROXY COMPONENT CGO_TARGET"
endef

define WRITE_LOCAL_IMAGE_TAG
	echo $(IMAGE_TAG) > $(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).docker_tag
	echo $(IMAGE) > $(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).docker_image_name	
endef

# Do not binary deps + go mod download file as intermediate files
ifneq ($(SPECIAL_TARGET_SECONDARY),)
.SECONDARY: $(SPECIAL_TARGET_SECONDARY)
endif

#### Source repo + binary Targets
ifneq ($(REPO_NO_CLONE),true)
$(REPO):
	@echo -e $(call TARGET_START_LOG)
ifneq ($(filter-out true,$(BUILD_ARTIFACTS)),)
	@echo "Skipping repo pull for $(REPO)"
else
ifneq ($(REPO_SPARSE_CHECKOUT),)
	@echo "Cloning repo $(REPO) with sparse checkout"
	source $(BUILD_LIB)/common.sh && retry git clone --depth 1 --filter=blob:none --sparse -b $(GIT_TAG) $(CLONE_URL) $(REPO)
	git -C $(REPO) sparse-checkout set $(REPO_SPARSE_CHECKOUT) --cone --skip-checks
else
	@echo "Cloning repo $(REPO)"
	source $(BUILD_LIB)/common.sh && retry git clone $(CLONE_URL) $(REPO)
endif
endif
	@echo -e $(call TARGET_END_LOG)
endif

$(GIT_CHECKOUT_TARGET): | $(REPO)
	@echo -e $(call TARGET_START_LOG)
	@if [ "$(BUILD_ARTIFACTS)" = "false" ]; then \
  		echo "Skipping checkout for $(REPO)"; \
	else \
		rm -f $(REPO)/eks-distro-*; \
		(cd $(REPO) && $(BASE_DIRECTORY)/build/lib/wait_for_tag.sh $(GIT_TAG)); \
		git -C $(REPO) checkout --quiet -f $(GIT_TAG); \
		touch $@; \
	fi
	@echo -e $(call TARGET_END_LOG)

$(GIT_PATCH_TARGET): $(GIT_CHECKOUT_TARGET)
	@echo -e $(call TARGET_START_LOG)
	@if [ "$(BUILD_ARTIFACTS)" = "false" ]; then \
		echo "Skipping patches for $(REPO)"; \
	else \
		git -C $(REPO) config user.email prow@amazonaws.com; \
		git -C $(REPO) config user.name "Prow Bot"; \
		if [ -n "$(PATCHES_DIR)" ]; then git -C $(REPO) am --committer-date-is-author-date $(PATCHES_DIR)/*; fi; \
		touch $@; \
	fi
	@echo -e $(call TARGET_END_LOG)


## GO mod download targets
$(REPO)/%ks-distro-go-mod-download: REPO_SUBPATH=$(if $(filter e,$*),,$(*:%/e=%))
$(REPO)/%ks-distro-go-mod-download: $(if $(PATCHES_DIR),$(GIT_PATCH_TARGET),$(GIT_CHECKOUT_TARGET))
	@echo -e $(call TARGET_START_LOG)
	@if [ "$(BUILD_ARTIFACTS)" = "false" ]; then \
		echo "Skipping go mod download for $(REPO)"; \
	else \
  		$(BASE_DIRECTORY)/build/lib/go_mod_download.sh $(MAKE_ROOT) $(REPO) $(GIT_TAG) $(GOLANG_VERSION) "$(REPO_SUBPATH)"; \
  		touch $@; \
	fi
	@echo -e $(call TARGET_END_LOG)

ifneq ($(REPO),$(HELM_SOURCE_REPOSITORY))
$(HELM_SOURCE_REPOSITORY):
	git clone $(HELM_CLONE_URL) $(HELM_SOURCE_REPOSITORY)
endif

ifneq ($(GIT_TAG),$(HELM_GIT_TAG))
$(HELM_GIT_CHECKOUT_TARGET): | $(HELM_SOURCE_REPOSITORY)
	@echo rm -f $(HELM_SOURCE_REPOSITORY)/eks-distro-*
	(cd $(HELM_SOURCE_REPOSITORY) && $(BASE_DIRECTORY)/build/lib/wait_for_tag.sh $(HELM_GIT_TAG))
	git -C $(HELM_SOURCE_REPOSITORY) checkout -f $(HELM_GIT_TAG)
	touch $@
endif

$(HELM_GIT_PATCH_TARGET): $(HELM_GIT_CHECKOUT_TARGET)
	git -C $(HELM_SOURCE_REPOSITORY) config user.email prow@amazonaws.com
	git -C $(HELM_SOURCE_REPOSITORY) config user.name "Prow Bot"
	git -C $(HELM_SOURCE_REPOSITORY) am --committer-date-is-author-date $(wildcard $(PROJECT_ROOT)/helm/patches)/*
	@touch $@

ifeq ($(SIMPLE_CREATE_BINARIES),true)
# GO_MOD_TARGET_FOR_BINARY_<binary> variables are created earlier in the makefile when determining which binaries can be built together vs alone
# if target is included in BINARY_TARGET_FILES_BUILD_TOGETHER list, use SOURCE_PATTERNS_BUILD_TOGETHER, otherewise use source pattern at the same index as binary_target in binary_target_files
$(OUTPUT_BIN_DIR)/%: PLATFORM=$(subst -,/,$(*D))
$(OUTPUT_BIN_DIR)/%: BINARY_TARGET=$(@F:%.exe=%)
$(OUTPUT_BIN_DIR)/%: SOURCE_PATTERN=$(if $(filter $(BINARY_TARGET),$(BINARY_TARGET_FILES_BUILD_TOGETHER)),$(SOURCE_PATTERNS_BUILD_TOGETHER),$(word $(call pos,$(BINARY_TARGET),$(BINARY_TARGET_FILES)),$(SOURCE_PATTERNS)))
$(OUTPUT_BIN_DIR)/%: OUTPUT_PATH=$(if $(and $(if $(filter false,$(call IS_ONE_WORD,$(BINARY_TARGET_FILES_BUILD_TOGETHER))),$(filter $(BINARY_TARGET),$(BINARY_TARGET_FILES_BUILD_TOGETHER)))),$(@D)/,$@)
$(OUTPUT_BIN_DIR)/%: GO_MOD_PATH=$($(call GO_MOD_TARGET_FOR_BINARY_VAR_NAME,$(BINARY_TARGET)))
$(OUTPUT_BIN_DIR)/%: $$(call GO_MOD_DOWNLOAD_TARGET_FROM_GO_MOD_PATH,$$(GO_MOD_PATH))
	@echo -e $(call TARGET_START_LOG)
	$(if $(filter true,$(call needs-cgo-builder,$(PLATFORM))),$(call CGO_CREATE_BINARIES_SHELL,$@,$(*D)),$(call SIMPLE_CREATE_BINARIES_SHELL))
	@echo -e $(call TARGET_END_LOG)
endif

.PHONY: binaries
ifneq ($(filter-out true,$(BUILD_ARTIFACTS)),)
binaries: copy-artifacts
else
binaries: $(BINARY_TARGETS)
endif

$(KUSTOMIZE_TARGET):
	@mkdir -p $(OUTPUT_DIR)
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s -- $(OUTPUT_DIR)

.PHONY: clone-repo
clone-repo: $(REPO)

.PHONY: checkout-repo
checkout-repo: $(if $(PATCHES_DIR),$(GIT_PATCH_TARGET),$(GIT_CHECKOUT_TARGET))

.PHONY: patch-repo
patch-repo: checkout-repo

## File/Folder Targets

$(OUTPUT_DIR)/images/%:
	@mkdir -p $(@D)

$(OUTPUT_DIR)/%TTRIBUTION.txt: SOURCE_FILE=$(@:_output/%=%) # we want to keep the release branch part which is in the OUTPUT var, hardcoding _output
$(OUTPUT_DIR)/%TTRIBUTION.txt:
	@mkdir -p $(OUTPUT_DIR)
	@cp $(SOURCE_FILE) $(OUTPUT_DIR)


## License Targets
# if there is only one go mod path then licenses are gathered to _output, `%` will equal `a`
# multiple go mod paths are in use and licenses are gathered and stored in sub folders, `%` will equal `<binary>/a`
# GO_MOD_TARGET_FOR_BINARY_<binary> variables are created earlier in the makefile when determining which binaries can be built together vs alone
$(OUTPUT_DIR)/%ttribution/go-license.csv: BINARY_TARGET=$(if $(filter .,$(*D)),,$(*D))
$(OUTPUT_DIR)/%ttribution/go-license.csv: GO_MOD_PATH=$(if $(BINARY_TARGET),$(GO_MOD_TARGET_FOR_BINARY_$(call TO_UPPER,$(BINARY_TARGET))),$(word 1,$(UNIQ_GO_MOD_PATHS)))
$(OUTPUT_DIR)/%ttribution/go-license.csv: LICENSE_PACKAGE_FILTER=$(GO_MOD_$(subst /,_,$(GO_MOD_PATH))_LICENSE_PACKAGE_FILTER)
$(OUTPUT_DIR)/%ttribution/go-license.csv: $$(call GO_MOD_DOWNLOAD_TARGET_FROM_GO_MOD_PATH,$$(GO_MOD_PATH))
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/build/lib/gather_licenses.sh $(REPO) $(MAKE_ROOT)/$(OUTPUT_DIR)/$(BINARY_TARGET) "$(LICENSE_PACKAGE_FILTER)" $(GO_MOD_PATH) $(GOLANG_VERSION)
	@echo -e $(call TARGET_END_LOG)

.PHONY: gather-licenses
gather-licenses: $(GATHER_LICENSES_TARGETS)

## Attribution Targets
# if there is only one go mod path so only one attribution is created, the file will be named ATTRIBUTION.txt and licenses will be stored in _output, `%` will equal `A`
# if multiple attributions are being generated, the file will be <binary>_ATTRIBUTION.txt and licenses will be stored in _output/<binary>, `%` will equal `<BINARY>_A`
%TTRIBUTION.txt: LICENSE_OUTPUT_PATH=$(OUTPUT_DIR)$(if $(filter A,$(*F)),,/$(call TO_LOWER,$(*F:%_A=%)))
%TTRIBUTION.txt: $$(LICENSE_OUTPUT_PATH)/attribution/go-license.csv
ifneq ($(filter-out true,$(BUILD_ARTIFACTS)),)
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping attribution generation for $(REPO)/$(RELEASE_BRANCH)"
	@echo -e $(call TARGET_END_LOG)
else
	@echo -e $(call TARGET_START_LOG)
	@rm -f $(@F)
	$(BASE_DIRECTORY)/build/lib/create_attribution.sh $(MAKE_ROOT) $(GOLANG_VERSION) $(MAKE_ROOT)/$(LICENSE_OUTPUT_PATH) $(@F) $(RELEASE_BRANCH)
	@echo -e $(call TARGET_END_LOG)
endif

.PHONY: attribution
attribution: $(and $(filter true,$(HAS_LICENSES)),$(ATTRIBUTION_TARGETS))

.PHONY: attribution-pr
attribution-pr: attribution
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/build/update-attribution-files/create_pr.sh
	@echo -e $(call TARGET_END_LOG)

.PHONY: all-attributions
all-attributions:
	$(BASE_DIRECTORY)/build/update-attribution-files/make_attribution.sh projects/$(COMPONENT) attribution


#### Tarball Targets

.PHONY: tarballs
ifneq ($(filter-out true,$(BUILD_ARTIFACTS)),)
tarballs: copy-artifacts
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/build/lib/simple_create_tarballs.sh $(TAR_FILE_PREFIX) $(MAKE_ROOT)/$(OUTPUT_DIR) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(GIT_TAG) "$(BINARY_PLATFORMS)" $(ARTIFACTS_PATH) $(GIT_HASH)
	@echo -e $(call TARGET_END_LOG)
else
tarballs: $(LICENSES_TARGETS_FOR_PREREQ)
ifeq ($(SIMPLE_CREATE_TARBALLS),true)
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/build/lib/simple_create_tarballs.sh $(TAR_FILE_PREFIX) $(MAKE_ROOT)/$(OUTPUT_DIR) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(GIT_TAG) "$(BINARY_PLATFORMS)" $(ARTIFACTS_PATH) $(GIT_HASH)
	@echo -e $(call TARGET_END_LOG)
endif
endif

.PHONY: upload-artifacts
upload-artifacts: s3-artifacts
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACTS_BUCKET) false $(UPLOAD_DRY_RUN)
	@echo -e $(call TARGET_END_LOG)

# Images (oci tarballs) always go to the kubernetes bin directly to match upstream. Beacuse of this we copy/sync artifacts from both the $(REPO) artifacts dir and the kubernetes artifacts dir
# if both folders exists
.PHONY: s3-artifacts
s3-artifacts: tarballs
	@echo -e $(call TARGET_START_LOG)
	if [ -d $(ARTIFACTS_PATH) ]; then \
		$(BASE_DIRECTORY)/release/copy_artifacts.sh $(REPO) $(ARTIFACTS_PATH) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG); \
		$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(ARTIFACTS_PATH) $(GIT_TAG) $(FAKE_ARM_BINARIES_FOR_VALIDATION); \
	fi
	if [ -d $(MAKE_ROOT)/$(OUTPUT_DIR)/images ]; then \
		$(BASE_DIRECTORY)/release/copy_artifacts.sh kubernetes $(MAKE_ROOT)/$(OUTPUT_DIR)/images $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG); \
		$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_DIR)/images $(GIT_TAG) $(FAKE_ARM_IMAGES_FOR_VALIDATION); \
	fi
	@echo -e $(call TARGET_END_LOG)

### Checksum Targets

.PHONY: checksums
checksums: $(BINARY_TARGETS)
ifneq ($(strip $(BINARY_TARGETS)),)
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/build/lib/update_checksums.sh $(MAKE_ROOT) $(PROJECT_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR)
	@echo -e $(call TARGET_END_LOG)
endif

.PHONY: validate-checksums
validate-checksums: $(BINARY_TARGETS)
ifneq ($(and $(strip $(BINARY_TARGETS)), $(filter false, $(SKIP_CHECKSUM_VALIDATION))),)
	@echo -e $(call TARGET_START_LOG)
	$(BASE_DIRECTORY)/build/lib/validate_checksums.sh $(MAKE_ROOT) $(PROJECT_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(FAKE_ARM_BINARIES_FOR_VALIDATION)
	@echo -e $(call TARGET_END_LOG)
endif

.PHONY: attribution-checksums
attribution-checksums: attribution checksums

.PHONY: all-checksums
all-checksums:
	$(BASE_DIRECTORY)/build/update-attribution-files/make_attribution.sh projects/$(COMPONENT) checksums

.PHONY: all-attributions-checksums
all-attributions-checksums:
	$(BASE_DIRECTORY)/build/update-attribution-files/make_attribution.sh projects/$(COMPONENT) "attribution checksums"


#### Image Helpers

ifneq ($(IMAGE_NAMES),)
.PHONY: local-images images
ifneq ($(filter-out true,$(BUILD_ARTIFACTS)),)
local-images: copy-artifacts
images: copy-artifacts
else
local-images: clean-job-caches $(LOCAL_IMAGE_TARGETS)
images: $(IMAGE_TARGETS)
endif
endif

.PHONY: clean-job-caches
# space is very limited in presubmit jobs, the image builds can push the total used space over the limit.
# go-build cache and pkg mod cache handled by target above
# prune is handled by buildkit.sh
clean-job-caches: $(and $(findstring presubmit,$(JOB_TYPE)),$(filter true,$(PRUNE_BUILDCTL)),clean-go-cache)

.PHONY: %/images/push %/images/amd64 %/images/arm64
%/images/push %/images/amd64 %/images/arm64: IMAGE_NAME=$*
%/images/push %/images/amd64 %/images/arm64: DOCKERFILE_FOLDER?=./docker/linux
%/images/push %/images/amd64 %/images/arm64: IMAGE_CONTEXT_DIR?=$(OUTPUT_DIR)
%/images/push %/images/amd64 %/images/arm64: IMAGE_BUILD_ARGS?=
%/images/push %/images/amd64 %/images/arm64: ALL_IMAGE_TAGS?=$(IMAGE),$(LATEST_IMAGE)
%/images/push %/images/amd64 %/images/arm64: IMAGE_METADATA_FILE?=

# Build image using buildkit for all platforms, by default pushes to registry defined in IMAGE_REPO.
%/images/push: IMAGE_PLATFORMS?=linux/amd64,linux/arm64
%/images/push: IMAGE_OUTPUT_TYPE?=image
%/images/push: IMAGE_OUTPUT?=push=true
# if building windows containers produce metadata file and push by digest
%/images/push: IMAGE_METADATA_FILE=$(if $(findstring windows/amd64,$(IMAGE_PLATFORMS)),/tmp/$(IMAGE_NAME)-metadata.json,)
%/images/push: IMAGE_OUTPUT=push=true$(if $(findstring windows/amd64,$(IMAGE_PLATFORMS)),$(COMMA)push-by-digest=true,)
%/images/push: ALL_IMAGE_TAGS=$(if $(findstring windows/amd64,$(IMAGE_PLATFORMS)),$(IMAGE_REPO)/$(IMAGE_REPO_COMPONENT),$(IMAGE)$(COMMA)$(LATEST_IMAGE))
# Build image using buildkit only builds linux/amd64 oci and saves to local tar.
%/images/amd64: IMAGE_PLATFORMS?=linux/amd64

# Build image using buildkit only builds linux/arm64 oci and saves to local tar.
%/images/arm64: IMAGE_PLATFORMS?=linux/arm64

%/images/amd64 %/images/arm64: IMAGE_OUTPUT_TYPE?=oci
%/images/amd64 %/images/arm64: IMAGE_OUTPUT?=dest=$(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).tar

%/images/push: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ) $(HANDLE_DEPENDENCIES_TARGET) $$(WINDOWS_IMAGE_BUILD_TARGETS_FOR_IMAGE)
	@echo -e $(call TARGET_START_LOG)
	$(BUILDCTL)
	@if [ -n "$(WINDOWS_IMAGE_BUILD_TARGETS_FOR_IMAGE)" ]; then \
		$(BUILD_LIB)/create_windows_manifest_list.sh $(IMAGE_NAME) $(IMAGE) $(LATEST_IMAGE) "$(WINDOWS_IMAGE_VERSIONS)"; \
	fi
	@echo -e $(call TARGET_END_LOG)

%/images/amd64: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ) $(HANDLE_DEPENDENCIES_TARGET)
	@echo -e $(call TARGET_START_LOG)
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)
	@echo -e $(call TARGET_END_LOG)

%/images/arm64: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ) $(HANDLE_DEPENDENCIES_TARGET)
	@echo -e $(call TARGET_START_LOG)
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)
	@echo -e $(call TARGET_END_LOG)

%/windows/images/push: IMAGE_NAME=$(word 1,$(subst ., ,$*))
%/windows/images/push: WINDOWS_OS_VERSION=$(word 2,$(subst ., ,$*))
%/windows/images/push: DOCKERFILE_FOLDER=./docker/windows
%/windows/images/push: BASE_IMAGE_NAME=eks-distro-windows-base-$(WINDOWS_OS_VERSION)
%/windows/images/push: BASE_IMAGE=$(BASE_IMAGE_REPO)/eks-distro-windows-base:$(BASE_IMAGE_TAG)
%/windows/images/push: IMAGE_PLATFORMS=windows/amd64
%/windows/images/push: IMAGE_METADATA_FILE=/tmp/$(IMAGE_NAME)-$(WINDOWS_OS_VERSION)-metadata.json
%/windows/images/push: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ) $(HANDLE_DEPENDENCIES_TARGET)
	@echo -e $(call TARGET_START_LOG)
	$(BUILDCTL)
	@echo -e $(call TARGET_END_LOG)

## CGO Targets
.PHONY: %/cgo/amd64 %/cgo/arm64 prepare-cgo-folder

# .git folder needed so git properly finds the root of the repo
prepare-cgo-folder:
	@mkdir -p $(CGO_SOURCE)/eks-distro/
	rsync -rm  --exclude='.git/***' \
		--exclude='***/_output/***' --exclude='projects/$(COMPONENT)/$(REPO)/***' \
		--include='projects/$(COMPONENT)/***' --include='*/' --exclude='projects/***'  \
		$(BASE_DIRECTORY)/ $(CGO_SOURCE)/eks-distro/
	@mkdir -p $(OUTPUT_BIN_DIR)/$(subst /,-,$(IMAGE_PLATFORMS))
	@mkdir -p $(CGO_SOURCE)/eks-distro/.git/{refs,objects}
	@cp $(BASE_DIRECTORY)/.git/HEAD $(CGO_SOURCE)/eks-distro/.git

%/cgo/amd64 %/cgo/arm64: IMAGE_OUTPUT_TYPE?=local
%/cgo/amd64 %/cgo/arm64: DOCKERFILE_FOLDER?=$(BUILD_LIB)/docker/linux/cgo
%/cgo/amd64 %/cgo/arm64: IMAGE_NAME=binary-builder
%/cgo/amd64 %/cgo/arm64: IMAGE_BUILD_ARGS?=GOPROXY COMPONENT
%/cgo/amd64 %/cgo/arm64: IMAGE_CONTEXT_DIR?=$(CGO_SOURCE)
%/cgo/amd64 %/cgo/arm64: BUILDER_IMAGE=$(GOLANG_GCC_BUILDER_IMAGE)

%/cgo/amd64: IMAGE_PLATFORMS=linux/amd64
%/cgo/arm64: IMAGE_PLATFORMS=linux/arm64

%/cgo/amd64: prepare-cgo-folder
	$(if $(filter true, $(USE_DOCKER_FOR_CGO_BUILD)),$(CGO_DOCKER),$(BUILDCTL))

%/cgo/arm64: prepare-cgo-folder
	$(if $(filter true, $(USE_DOCKER_FOR_CGO_BUILD)),$(CGO_DOCKER),$(BUILDCTL))

# As an attempt to see if using docker is more stable for cgo builds in Codebuild
binary-builder/cgo/%: USE_DOCKER_FOR_CGO_BUILD=$(shell command -v docker &> /dev/null && docker info > /dev/null 2>&1 && echo "true")

## Useradd targets
%-useradd/images/export: IMAGE_OUTPUT_TYPE=local
%-useradd/images/export: IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/files/$*
%-useradd/images/export: IMAGE_OUTPUT?=dest=$(IMAGE_OUTPUT_DIR)
%-useradd/images/export: IMAGE_BUILD_ARGS=IMAGE_USERADD_USER_ID IMAGE_USERADD_USER_NAME
%-useradd/images/export: DOCKERFILE_FOLDER=$(BUILD_LIB)/docker/linux/useradd
%-useradd/images/export: IMAGE_PLATFORMS=linux/amd64
%-useradd/images/export:
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)

## Helm Targets
.PHONY: helm/pull 
helm/pull: 
	$(BUILD_LIB)/helm_pull.sh $(HELM_PULL_LOCATION) $(HELM_REPO_URL) $(HELM_PULL_NAME) $(REPO) $(HELM_DIRECTORY) $(CHART_VERSION) $(COPY_CRDS)

# Build helm chart
.PHONY: helm/build
helm/build: $(LICENSES_TARGETS_FOR_PREREQ)
helm/build: $(if $(filter true,$(REPO_NO_CLONE)),,$(HELM_GIT_CHECKOUT_TARGET))
helm/build: $(if $(wildcard $(PROJECT_ROOT)/helm/patches),$(HELM_GIT_PATCH_TARGET),)
	$(BUILD_LIB)/helm_copy.sh $(HELM_SOURCE_REPOSITORY) $(HELM_DESTINATION_REPOSITORY) $(HELM_DIRECTORY) $(OUTPUT_DIR)
	$(BUILD_LIB)/helm_require.sh $(HELM_SOURCE_IMAGE_REPO) $(HELM_DESTINATION_REPOSITORY) $(OUTPUT_DIR) $(IMAGE_TAG) $(HELM_TAG) $(PROJECT_ROOT) $(LATEST) $(HELM_USE_UPSTREAM_IMAGE) $(HELM_IMAGE_LIST)
	$(BUILD_LIB)/helm_replace.sh $(HELM_DESTINATION_REPOSITORY) $(OUTPUT_DIR)
	$(BUILD_LIB)/helm_build.sh $(OUTPUT_DIR) $(HELM_DESTINATION_REPOSITORY)

# Build helm chart and push to registry defined in IMAGE_REPO.
.PHONY: helm/push
helm/push: helm/build
	$(BUILD_LIB)/helm_push.sh $(IMAGE_REPO) $(HELM_DESTINATION_REPOSITORY) $(HELM_TAG) $(GIT_TAG) $(OUTPUT_DIR) $(LATEST)

## Fetch Binary Targets
.PHONY: handle-dependencies 
handle-dependencies: $(call PROJECT_DEPENDENCIES_TARGETS)

$(BINARY_DEPS_DIR)/linux-%:
	$(BUILD_LIB)/fetch_binaries.sh $(BINARY_DEPS_DIR) $* $(ARTIFACTS_BUCKET) $(LATEST) $(RELEASE_BRANCH)


## Build Targets
.PHONY: build
build: FAKE_ARM_IMAGES_FOR_VALIDATION=true
build: $(BUILD_TARGETS)

.PHONY: release
release: $(RELEASE_TARGETS)

# Iterate over release branch versions, avoiding branches explicitly marked as skipped
.PHONY: %/release-branches/all
%/release-branches/all:
	@for version in $(SUPPORTED_K8S_VERSIONS) ; do \
	    if ! [[ "$(SKIPPED_K8S_VERSIONS)" =~ $$version  ]]; then \
			$(MAKE) $* RELEASE_BRANCH=$$version; \
		fi \
	done;

###  Clean Targets

.PHONY: clean-go-cache
clean-go-cache:
	@echo -e $(call TARGET_START_LOG)
# When go downloads pkg to the module cache, GOPATH/pkg/mod, it removes the write permissions
# prevent accident modifications since files/checksums are tightly controlled
# adding the perms necessary to perform the delete
	@chmod -fR 777 $(GO_MOD_CACHE) &> /dev/null || :
	$(foreach folder,$(GO_MOD_CACHE) $(GO_BUILD_CACHE),$(if $(wildcard $(folder)),du -hs $(folder) && rm -rf $(folder);,))
# When building go bins using mods which have been downloaded by go mod download/vendor which will exist in the go_mod_cache
# there is additional checksum (?) information that is not preserved in the vendor directory within the project folder
# This additional information gets written out into the resulting binary. If we did not run go mod vendor, which we do 
# for all project builds, we could get checksum mismatches on the final binaries due to sometimes having the mod previously
# downloaded in the go_mod_cahe.  Running go mod vendor always ensures that the go mod has always been downloaded
# to the go_mod_cache directory. If we clear the go_mod_cache we need to delete the go_mod_download sentinel file
# so the next time we run build go mods will be redownloaded
	$(foreach file,$(GO_MOD_DOWNLOAD_TARGETS),$(if $(wildcard $(file)),rm -f $(file);,))
	@echo -e $(call TARGET_END_LOG)

.PHONY: clean-repo
clean-repo:
	@rm -rf $(REPO)	$(HELM_SOURCE_REPOSITORY)

.PHONY: clean-output
clean-output:
	$(if $(wildcard _output),du -hs _output && rm -rf _output,)

.PHONY: clean
clean: $(if $(filter true,$(REPO_NO_CLONE)),,clean-repo) clean-output

## --------------------------------------
## Help
## --------------------------------------
#@  Helpers
.PHONY: help
help: # Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% \/a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-55s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 4) } ' $(MAKEFILE_LIST)

.PHONY: help-list
help-list: 
	@awk 'BEGIN {FS = ":.*#";} /^[$$()% \/a-zA-Z0-9_-]+:.*?#/ { printf "%s: ##%s\n", $$1, $$2 } /^#@/ { printf "\n##@%s\n", substr($$0, 4) } ' $(MAKEFILE_LIST)

.PHONY: add-generated-help-block
add-generated-help-block: # Add or update generated help block to document project make file and support shell auto completion
add-generated-help-block:
	$(BUILD_LIB)/generate_help_body.sh $(MAKE_ROOT) "$(BINARY_TARGET_FILES)" "$(BINARY_PLATFORMS)" "${BINARY_TARGETS}" \
		$(REPO) $(if $(PATCHES_DIR),true,false) "$(LOCAL_IMAGE_TARGETS)" "$(IMAGE_TARGETS)" "$(BUILD_TARGETS)" "$(RELEASE_TARGETS)" \
		"$(HAS_S3_ARTIFACTS)" "$(HAS_LICENSES)" "$(REPO_NO_CLONE)" "$(PROJECT_DEPENDENCIES_TARGETS)" \
		"$(HAS_HELM_CHART)" "$(IN_DOCKER_TARGETS)"

## --------------------------------------
## Update Helpers
## --------------------------------------
#@ Update Helpers

.PHONY: run-target-in-docker
run-target-in-docker: # Run `MAKE_TARGET` using builder base docker container
	$(BUILD_LIB)/run_target_docker.sh $(COMPONENT) $(MAKE_TARGET) $(IMAGE_REPO) "$(RELEASE_BRANCH)" $(ARTIFACTS_BUCKET)

.PHONY: stop-docker-builder
stop-docker-builder: # Clean up builder base docker container
	docker rm -f -v eks-d-builder

.PHONY: generate
generate: # Update UPSTREAM_PROJECTS.yaml
	$(BUILD_LIB)/generate_projects_list.sh $(BASE_DIRECTORY)

.PHONY: update-go-mods
update-go-mods: # Update locally checked-in go sum to assist in vuln scanning
update-go-mods: DEST_PATH=$(if $(IS_RELEASE_BRANCH_BUILD),$(RELEASE_BRANCH)/$$gomod,$$gomod)
update-go-mods: checkout-repo
	@if [ "$(REPO)" = "kubernetes" ]; then \
		echo "Skipping update-go-mods for kubernetes repository"; \
	else \
		for gomod in $(GO_MOD_PATHS); do \
			mkdir -p $(DEST_PATH); \
			cp $(REPO)/$$gomod/go.{mod,sum} $(DEST_PATH); \
		done; \
	fi

.PHONY: all-update-go-mods
all-update-go-mods:
	$(BASE_DIRECTORY)/build/update-attribution-files/make_attribution.sh projects/$(COMPONENT) update-go-mods

update-internal-build-files: setup-internal-build-files

.PHONY: setup-internal-build-files
setup-internal-build-files:
ifneq ($(and $(filter-out true,$(BUILD_ARTIFACTS)),$(COPY_ARTIFACTS_SCRIPT)),)
	@$(MAKE) copy-artifacts
else
	@echo "this project is not setup for internal builds"
endif

.PHONY: update-vendor-for-dep-patch
update-vendor-for-dep-patch: # After bumping dep in go.mod file, uses generic vendor update script or one provided from upstream project
update-vendor-for-dep-patch: checkout-repo
	$(BUILD_LIB)/update_vendor.sh $(PROJECT_ROOT) $(REPO) $(GIT_TAG) $(GOLANG_VERSION) $(VENDOR_UPDATE_SCRIPT)

.PHONY: patch-for-dep-update
patch-for-dep-update: # After bumping dep in go.mod file and updating vendor, generates patch
patch-for-dep-update: checkout-repo
	$(BUILD_LIB)/patch_for_dep_update.sh $(REPO) $(GIT_TAG) $(PROJECT_ROOT)/patches

.PHONY: %/create-ecr-repo
%/create-ecr-repo: IMAGE_NAME=$*
%/create-ecr-repo:
	cmd=( ecr ); \
	if [[ "${IMAGE_REPO}" =~ ^public\.ecr\.aws/ ]]; then \
		cmd=( ecr-public --region us-east-1 ); \
	fi; \
	repo=$(IMAGE_REPO_COMPONENT); \
	if [ "$(IMAGE_NAME)" = "__helm__" ]; then \
		repo="$(HELM_DESTINATION_REPOSITORY)"; \
	fi; \
	if ! aws $${cmd[*]} describe-repositories --repository-name "$$repo" > /dev/null 2>&1; then \
		aws $${cmd[*]} create-repository --repository-name "$$repo"; \
	fi;

.PHONY: create-ecr-repos
create-ecr-repos: # Create repos in ECR for project images for local testing
create-ecr-repos: $(foreach image,$(IMAGE_NAMES),$(image)/create-ecr-repo) $(if $(filter true,$(HAS_HELM_CHART)),__helm__/create-ecr-repo,)

.PHONY: var-value-%
var-value-%:
	@echo $($*)

.PHONY: check-for-supported-release-branch
check-for-supported-release-branch:
	@if [ -d $(MAKE_ROOT)/$(RELEASE_BRANCH) ]; then \
		echo "Supported version to build"; \
		exit 0; \
	else \
		echo "Not a supported version to build"; \
		exit 1; \
	fi

## --------------------------------------
## Docker Helpers
## --------------------------------------
# $1 - target
define RUN_IN_DOCKER_TARGET
.PHONY: run-$(1)-in-docker
run-$(1)-in-docker: MAKE_TARGET=$(1)
run-$(1)-in-docker: run-target-in-docker
endef

$(foreach target,$(IN_DOCKER_TARGETS),$(eval $(call RUN_IN_DOCKER_TARGET,$(target))))
