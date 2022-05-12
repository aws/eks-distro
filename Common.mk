# Disable built-in rules and variables
MAKEFLAGS+=--no-builtin-rules --warn-undefined-variables
SHELL=bash
.SHELLFLAGS:=-eu -o pipefail -c
.SUFFIXES:
.SECONDEXPANSION:

RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)

MINIMAL_VARIANT_VERSIONS=1-22 1-23
RELEASE_VARIANT?=$(if $(filter $(RELEASE_BRANCH),$(MINIMAL_VARIANT_VERSIONS)),minimal,standard)
IS_BUILDING_MINIMAL=$(filter minimal, $(RELEASE_VARIANT))

GIT_HASH=eks-$(RELEASE_BRANCH)-$(RELEASE)

COMPONENT?=$(REPO_OWNER)/$(REPO)
MAKE_ROOT=$(BASE_DIRECTORY)/projects/$(COMPONENT)
PROJECT_PATH?=$(subst $(BASE_DIRECTORY)/,,$(MAKE_ROOT))
BUILD_LIB=${BASE_DIRECTORY}/build/lib
OUTPUT_BIN_DIR?=$(OUTPUT_DIR)/bin/$(REPO)

#################### AWS ###########################
AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
ARTIFACT_BUCKET?=my-s3-bucket # TODO: in eks-a we use ARTIFACTS_BUCKET
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
CLONE_URL?=$(call GET_CLONE_URL,$(REPO_OWNER),$(REPO))
#HELM_CLONE_URL=$(call GET_CLONE_URL,$(HELM_SOURCE_OWNER),$(HELM_SOURCE_REPOSITORY))
HELM_CLONE_URL=https://github.com/$(HELM_SOURCE_OWNER)/$(HELM_SOURCE_REPOSITORY).git
ifeq ($(CODEBUILD_CI),true)
	ARTIFACTS_PATH?=$(CODEBUILD_SRC_DIR)/$(PROJECT_PATH)/$(CODEBUILD_BUILD_NUMBER)-$(CODEBUILD_RESOLVED_SOURCE_VERSION)/artifacts
	UPLOAD_DRY_RUN=false
	BUILD_IDENTIFIER=$(CODEBUILD_BUILD_NUMBER)
else
	ARTIFACTS_PATH?=$(MAKE_ROOT)/_output/tar
	UPLOAD_DRY_RUN=$(if $(findstring postsubmit,$(JOB_TYPE)),false,true)
	ifeq ($(CI),true)
		BUILD_IDENTIFIER=$(PROW_JOB_ID)
	else
		BUILD_IDENTIFIER:=$(shell date "+%F-%s")
	endif
endif
####################################################

#################### GIT ###########################
GIT_CHECKOUT_TARGET?=$(REPO)/eks-distro-checkout-$(GIT_TAG)
GIT_PATCH_TARGET?=$(REPO)/eks-distro-patched
REPO_NO_CLONE?=false
PATCHES_DIR=$(or $(wildcard $(PROJECT_ROOT)/patches),$(wildcard $(MAKE_ROOT)/patches))
####################################################

#################### RELEASE BRANCHES ##############
HAS_RELEASE_BRANCHES?=false
RELEASE_BRANCH?=
SUPPORTED_K8S_VERSIONS:=$(shell cat $(BASE_DIRECTORY)/release/SUPPORTED_RELEASE_BRANCHES)
BINARIES_ARE_RELEASE_BRANCHED?=true
IS_RELEASE_BRANCH_BUILD=$(filter true,$(HAS_RELEASE_BRANCHES))
IS_UNRELEASE_BRANCH_TARGET=$(and $(filter false,$(BINARIES_ARE_RELEASE_BRANCHED)),$(filter binaries attribution checksums,$(MAKECMDGOALS)))
TARGETS_ALLOWED_WITH_NO_RELEASE_BRANCH?=build release clean help
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
else ifneq ($(and $(IS_RELEASE_BRANCH_BUILD), $(filter-out $(TARGETS_ALLOWED_WITH_NO_RELEASE_BRANCH),$(MAKECMDGOALS))),)
	# if project has release branches and not calling one of the above targets
$(error When running targets for this project other than `build` or `release` a `RELEASE_BRANCH` is required)
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
BASE_IMAGE_NAME?=$(if $(IS_BUILDING_MINIMAL),eks-distro-minimal-base,eks-distro-base)
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
IMAGE=$(IMAGE_REPO)/$(call IF_OVERRIDE_VARIABLE,$(IMAGE_COMPONENT_VARIABLE),$(IMAGE_COMPONENT)):$(IMAGE_TAG)
LATEST_IMAGE=$(IMAGE:$(lastword $(subst :, ,$(IMAGE)))=$(LATEST_TAG))

IMAGE_USERADD_USER_ID?=1000
IMAGE_USERADD_USER_NAME?=

# Branch builds should look at the current branch latest image for cache as well as main branch latest for cache to cover the cases
# where its the first build from a new release branch
IMAGE_IMPORT_CACHE?=type=registry,ref=$(LATEST_IMAGE) type=registry,ref=$(subst $(LATEST),latest,$(LATEST_IMAGE))

BUILD_OCI_TARS?=false

LOCAL_IMAGE_TARGETS=$(foreach image,$(IMAGE_NAMES),$(image)/images/amd64) $(if $(filter true,$(HAS_HELM_CHART)),helm/build,) 
IMAGE_TARGETS=$(foreach image,$(IMAGE_NAMES),$(if $(filter true,$(BUILD_OCI_TARS)),$(call IMAGE_TARGETS_FOR_NAME,$(image)),$(image)/images/push)) $(if $(filter true,$(HAS_HELM_CHART)),helm/push,) 
####################################################

#################### HELM ##########################
HAS_HELM_CHART?=false
HELM_SOURCE_OWNER?=$(REPO_OWNER)
HELM_SOURCE_REPOSITORY?=$(REPO)
HELM_GIT_TAG?=$(GIT_TAG)
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
pos = $(words $(call _pos,$1,$2))

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
FULL_FETCH_BINARIES_TARGETS=$(addprefix $(BINARY_DEPS_DIR)/linux-amd64/, $(1)) $(addprefix $(BINARY_DEPS_DIR)/linux-arm64/, $(1))

# $1 - targets
# $2 - platforms
BINARY_TARGETS_FROM_FILES_PLATFORMS=$(foreach platform, $(2), $(foreach target, $(1), \
		$(OUTPUT_BIN_DIR)/$(subst /,-,$(platform))/$(if $(findstring windows,$(platform)),$(target).exe,$(target))))

# This "function" is used to construt the git clone URL for projects.
# Indenting the block results in the URL getting prefixed with a
# space, hence no indentation below.
# $1 - repo owner
# $2 - repo
GET_CLONE_URL=$(shell source $(BUILD_LIB)/common.sh && build::common::get_clone_url $(1) $(2) $(AWS_REGION) $(CODEBUILD_CI))

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
# if the pattern ends in the same as a previous pattern, binary must be built seperately
# if the go mod path has changed from the main, must be built seperately
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
# which will store the mapping of uniq go_mod paths to first target file for repsective go mod
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

BINARY_TARGETS?=$(call BINARY_TARGETS_FROM_FILES_PLATFORMS, $(BINARY_TARGET_FILES), $(BINARY_PLATFORMS))
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

#### CGO ############
CGO_CREATE_BINARIES?=false
CGO_SOURCE=$(OUTPUT_DIR)/source
IS_ON_BUILDER_BASE?=$(shell if [ -f /buildkit.sh ]; then echo true; fi;)
BUILDER_PLATFORM?=$(shell echo $$(go env GOHOSTOS)/$$(go env GOHOSTARCH))
needs-cgo-builder=$(and $(if $(filter true,$(CGO_CREATE_BINARIES)),true,),$(if $(filter-out $(1),$(BUILDER_PLATFORM)),true,))
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
FETCH_BINARIES_TARGETS?=
####################################################

#################### LICENSES ######################
LICENSE_PACKAGE_FILTER?=$(SOURCE_PATTERNS)
HAS_LICENSES?=true
ATTRIBUTION_TARGETS?=$(call pairmap,ATTRIBUTION_TARGET_FROM_BINARY_GO_MOD,$(BINARY_TARGET_FILES),$(GO_MOD_PATHS))
GATHER_LICENSES_TARGETS?=$(call pairmap,LICENSE_TARGET_FROM_BINARY_GO_MOD,$(BINARY_TARGET_FILES),$(GO_MOD_PATHS))
LICENSES_OUTPUT_DIR?=$(OUTPUT_DIR)
LICENSES_TARGETS_FOR_PREREQ=$(if $(filter true,$(HAS_LICENSES)),$(GATHER_LICENSES_TARGETS) \
	$(foreach target,$(ATTRIBUTION_TARGETS),_output/$(target)),)
####################################################

#################### TARBALLS ######################
HAS_S3_ARTIFACTS?=false

SIMPLE_CREATE_TARBALLS?=true
TAR_FILE_PREFIX?=$(REPO)
FAKE_ARM_BINARIES_FOR_VALIDATION?=$(if $(filter linux/arm64,$(BINARY_PLATFORMS)),false,true)
FAKE_ARM_IMAGES_FOR_VALIDATION?=false
####################################################

#################### OTHER #########################
KUSTOMIZE_TARGET=$(OUTPUT_DIR)/kustomize
GIT_DEPS_DIR?=$(OUTPUT_DIR)/gitdependencies
SPECIAL_TARGET_SECONDARY=$(strip $(call FULL_FETCH_BINARIES_TARGETS, $(FETCH_BINARIES_TARGETS)) $(GO_MOD_DOWNLOAD_TARGETS))
####################################################

#################### TARGETS FOR OVERRIDING ########
BUILD_TARGETS?=validate-checksums attribution $(if $(IMAGE_NAMES),local-images,) $(if $(filter true,$(HAS_S3_ARTIFACTS)),upload-artifacts,) attribution-pr
RELEASE_TARGETS?=validate-checksums $(if $(IMAGE_NAMES),images,) $(if $(filter true,$(HAS_S3_ARTIFACTS)),upload-artifacts,)
####################################################

define BUILDCTL
	$(BUILD_LIB)/buildkit.sh \
		build \
		--frontend dockerfile.v0 \
		--opt platform=$(IMAGE_PLATFORMS) \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--opt build-arg:BUILDER_IMAGE=$(BUILDER_IMAGE) \
		--opt build-arg:RELEASE_BRANCH=$(RELEASE_BRANCH) \
		$(foreach BUILD_ARG,$(IMAGE_BUILD_ARGS),--opt build-arg:$(BUILD_ARG)=$($(BUILD_ARG))) \
		--progress plain \
		--local dockerfile=$(DOCKERFILE_FOLDER) \
		--local context=$(IMAGE_CONTEXT_DIR) \
		--opt target=$(IMAGE_TARGET) \
		--output type=$(IMAGE_OUTPUT_TYPE),oci-mediatypes=true,\"name=$(IMAGE)\",$(IMAGE_OUTPUT) # \
		# TODO: look into buildctl caching
		# $(if $(filter push=true,$(IMAGE_OUTPUT)),--export-cache type=inline,) \
		# $(foreach IMPORT_CACHE,$(IMAGE_IMPORT_CACHE),--import-cache $(IMPORT_CACHE))

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
	git clone $(CLONE_URL) $(REPO)
endif

$(GIT_CHECKOUT_TARGET): | $(REPO)
	@rm -f $(REPO)/eks-distro-*
	(cd $(REPO) && $(BASE_DIRECTORY)/build/lib/wait_for_tag.sh $(GIT_TAG))
	git -C $(REPO) checkout -f $(GIT_TAG)
	touch $@

$(GIT_PATCH_TARGET): $(GIT_CHECKOUT_TARGET)
	git -C $(REPO) config user.email prow@amazonaws.com
	git -C $(REPO) config user.name "Prow Bot"
	git -C $(REPO) am --committer-date-is-author-date $(PATCHES_DIR)/*
	@touch $@


## GO mod download targets
$(REPO)/%ks-distro-go-mod-download: REPO_SUBPATH=$(if $(filter e,$*),,$(*:%/e=%))
$(REPO)/%ks-distro-go-mod-download: $(if $(PATCHES_DIR),$(GIT_PATCH_TARGET),$(GIT_CHECKOUT_TARGET))
	$(BASE_DIRECTORY)/build/lib/go_mod_download.sh $(MAKE_ROOT) $(REPO) $(GIT_TAG) $(GOLANG_VERSION) "$(REPO_SUBPATH)"
	@touch $@

ifneq ($(REPO),$(HELM_SOURCE_REPOSITORY))
$(HELM_SOURCE_REPOSITORY):
	git clone $(HELM_CLONE_URL) $(HELM_SOURCE_REPOSITORY)

$(HELM_GIT_CHECKOUT_TARGET): | $(HELM_SOURCE_REPOSITORY)
	@echo rm -f $(HELM_SOURCE_REPOSITORY)/eks-distro-*
	(cd $(HELM_SOURCE_REPOSITORY) && $(BASE_DIRECTORY)/build/lib/wait_for_tag.sh $(HELM_GIT_TAG))
	git -C $(HELM_SOURCE_REPOSITORY) checkout -f $(HELM_GIT_TAG)
	touch $@
endif

$(HELM_GIT_PATCH_TARGET): $(HELM_GIT_CHECKOUT_TARGET)
	git -C $(HELM_SOURCE_REPOSITORY) config user.email prow@amazonaws.com
	git -C $(HELM_SOURCE_REPOSITORY) config user.name "Prow Bot"
	git -C $(HELM_SOURCE_REPOSITORY) am --committer-date-is-author-date $(wildcard $(MAKE_ROOT)/helm/patches)/*
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
	if [ "$(call needs-cgo-builder,$(PLATFORM))" == "true" ]; then \
		$(MAKE) binary-builder/cgo/$(PLATFORM:linux/%=%) IMAGE_OUTPUT=dest=$(OUTPUT_BIN_DIR)/$(*D) CGO_TARGET=$@ IMAGE_BUILD_ARGS="GOPROXY COMPONENT CGO_TARGET"; \
	else \
		$(BASE_DIRECTORY)/build/lib/simple_create_binaries.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_PATH) $(REPO) $(GOLANG_VERSION) $(PLATFORM) "$(SOURCE_PATTERN)" \
			"$(GOBUILD_COMMAND)" "$(EXTRA_GOBUILD_FLAGS)" "$(GO_LDFLAGS)" $(CGO_ENABLED) "$(CGO_LDFLAGS)" "$(GO_MOD_PATH)" "$(BINARY_TARGET_FILES_BUILD_TOGETHER)"; \
	fi
endif

.PHONY: binaries
binaries: $(BINARY_TARGETS)

$(KUSTOMIZE_TARGET):
	@mkdir -p $(OUTPUT_DIR)
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s -- $(OUTPUT_DIR)

.PHONY: clone-repo
clone-repo: $(REPO)

.PHONY: checkout-repo
checkout-repo: $(GIT_CHECKOUT_TARGET)

.PHONY: patch-repo
patch-repo: $(GIT_PATCH_TARGET)

## File/Folder Targets

$(OUTPUT_DIR)/images/%:
	@mkdir -p $(@D)

$(OUTPUT_DIR)/%TTRIBUTION.txt:
	@mkdir -p $(OUTPUT_DIR)
	@cp $(ATTRIBUTION_TARGETS) $(OUTPUT_DIR)


## License Targets
# if there is only one go mod path then licenses are gathered to _output, `%` will equal `a`
# multiple go mod paths are in use and licenses are gathered and stored in sub folders, `%` will equal `<binary>/a`
# GO_MOD_TARGET_FOR_BINARY_<binary> variables are created earlier in the makefile when determining which binaries can be built together vs alone
$(OUTPUT_DIR)/%ttribution/go-license.csv: BINARY_TARGET=$(if $(filter .,$(*D)),,$(*D))
$(OUTPUT_DIR)/%ttribution/go-license.csv: GO_MOD_PATH=$(if $(BINARY_TARGET),$(GO_MOD_TARGET_FOR_BINARY_$(call TO_UPPER,$(BINARY_TARGET))),$(word 1,$(UNIQ_GO_MOD_PATHS)))
$(OUTPUT_DIR)/%ttribution/go-license.csv: LICENSE_PACKAGE_FILTER=$(GO_MOD_$(subst /,_,$(GO_MOD_PATH))_LICENSE_PACKAGE_FILTER)
$(OUTPUT_DIR)/%ttribution/go-license.csv: $$(call GO_MOD_DOWNLOAD_TARGET_FROM_GO_MOD_PATH,$$(GO_MOD_PATH))	
	$(BASE_DIRECTORY)/build/lib/gather_licenses.sh $(REPO) $(MAKE_ROOT)/$(OUTPUT_DIR)/$(BINARY_TARGET) "$(LICENSE_PACKAGE_FILTER)" $(GO_MOD_PATH) $(GOLANG_VERSION)

.PHONY: gather-licenses
gather-licenses: $(GATHER_LICENSES_TARGETS)

## Attribution Targets
# if there is only one go mod path so only one attribution is created, the file will be named ATTRIBUTION.txt and licenses will be stored in _output, `%` will equal `A`
# if multiple attributions are being generated, the file will be <binary>_ATTRIBUTION.txt and licenses will be stored in _output/<binary>, `%` will equal `<BINARY>_A`
%TTRIBUTION.txt: LICENSE_OUTPUT_PATH=$(OUTPUT_DIR)$(if $(filter A,$(*F)),,/$(call TO_LOWER,$(*F:%_A=%)))
%TTRIBUTION.txt: $$(LICENSE_OUTPUT_PATH)/attribution/go-license.csv
	@rm -f $(@F)
	$(BASE_DIRECTORY)/build/lib/create_attribution.sh $(MAKE_ROOT) $(GOLANG_VERSION) $(MAKE_ROOT)/$(LICENSE_OUTPUT_PATH) $(@F) $(RELEASE_BRANCH)

.PHONY: attribution
attribution: $(and $(filter true,$(HAS_LICENSES)),$(ATTRIBUTION_TARGETS))

.PHONY: attribution-pr
attribution-pr: attribution
	$(BASE_DIRECTORY)/build/update-attribution-files/create_pr.sh

#### Tarball Targets

.PHONY: tarballs
tarballs: $(LICENSES_TARGETS_FOR_PREREQ)
ifeq ($(SIMPLE_CREATE_TARBALLS),true)
	$(BASE_DIRECTORY)/build/lib/simple_create_tarballs.sh $(TAR_FILE_PREFIX) $(MAKE_ROOT)/$(OUTPUT_DIR) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(GIT_TAG) "$(BINARY_PLATFORMS)" $(ARTIFACTS_PATH) $(GIT_HASH)
endif

.PHONY: upload-artifacts
upload-artifacts: s3-artifacts
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) false $(UPLOAD_DRY_RUN)

.PHONY: s3-artifacts
s3-artifacts: tarballs
# Images (oci tarballs) always go to the kubernetes bin directly to match upstream, thats why kubernetes is passed as the first arg below instead of $(REPO) like when copying other artifacts
	if [ -d $(ARTIFACTS_PATH) ]; then \
		$(BASE_DIRECTORY)/release/copy_artifacts.sh $(REPO) $(ARTIFACTS_PATH) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG); \
		$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(ARTIFACTS_PATH) $(GIT_TAG) $(FAKE_ARM_BINARIES_FOR_VALIDATION); \
	fi
	if [ -d $(MAKE_ROOT)/$(OUTPUT_DIR)/images ]; then \
		$(BASE_DIRECTORY)/release/copy_artifacts.sh kubernetes $(MAKE_ROOT)/$(OUTPUT_DIR)/images $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG); \
		$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_DIR)/images $(GIT_TAG) $(FAKE_ARM_IMAGES_FOR_VALIDATION); \
	fi

### Checksum Targets

.PHONY: checksums
checksums: $(BINARY_TARGETS)
ifneq ($(strip $(BINARY_TARGETS)),)
	$(BASE_DIRECTORY)/build/lib/update_checksums.sh $(MAKE_ROOT) $(PROJECT_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR)
endif

.PHONY: validate-checksums
validate-checksums: $(BINARY_TARGETS)
ifneq ($(strip $(BINARY_TARGETS)),)
	$(BASE_DIRECTORY)/build/lib/validate_checksums.sh $(MAKE_ROOT) $(PROJECT_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(FAKE_ARM_BINARIES_FOR_VALIDATION)
endif

#### Image Helpers

ifneq ($(IMAGE_NAMES),)
.PHONY: local-images images
local-images: $(LOCAL_IMAGE_TARGETS)
images: $(IMAGE_TARGETS)
endif

.PHONY: %/images/push %/images/amd64 %/images/arm64
%/images/push %/images/amd64 %/images/arm64: IMAGE_NAME=$*
%/images/push %/images/amd64 %/images/arm64: DOCKERFILE_FOLDER?=./docker/linux
%/images/push %/images/amd64 %/images/arm64: IMAGE_CONTEXT_DIR?=.
%/images/push %/images/amd64 %/images/arm64: IMAGE_BUILD_ARGS?=

# Build image using buildkit for all platforms, by default pushes to registry defined in IMAGE_REPO.
%/images/push: IMAGE_PLATFORMS?=linux/amd64,linux/arm64
%/images/push: IMAGE_OUTPUT_TYPE?=image
%/images/push: IMAGE_OUTPUT?=push=true

# Build image using buildkit only builds linux/amd64 oci and saves to local tar.
%/images/amd64: IMAGE_PLATFORMS?=linux/amd64

# Build image using buildkit only builds linux/arm64 oci and saves to local tar.
%/images/arm64: IMAGE_PLATFORMS?=linux/arm64

%/images/amd64 %/images/arm64: IMAGE_OUTPUT_TYPE?=oci
%/images/amd64 %/images/arm64: IMAGE_OUTPUT?=dest=$(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).tar

%/images/push: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ)
	$(BUILDCTL)

%/images/amd64: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ)
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)

%/images/arm64: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ)
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)

## CGO Targets
.PHONY: %/cgo/amd64 %/cgo/arm64 prepare-cgo-folder

prepare-cgo-folder:
	@mkdir -p $(CGO_SOURCE)/eks-distro/
	rsync -rm  --exclude='.git/***' \
		--exclude='***/_output/***' --exclude='projects/$(COMPONENT)/$(REPO)/***' \
		--include='projects/$(COMPONENT)/***' --include='*/' --exclude='projects/***'  \
		$(BASE_DIRECTORY)/ $(CGO_SOURCE)/eks-distro/
	@mkdir -p $(OUTPUT_BIN_DIR)/$(subst /,-,$(IMAGE_PLATFORMS))
	# Need so git properly finds the root of the repo
	@mkdir -p $(CGO_SOURCE)/eks-distro/.git/{refs,objects}
	@cp $(BASE_DIRECTORY)/.git/HEAD $(CGO_SOURCE)/eks-distro/.git

%/cgo/amd64 %/cgo/arm64: IMAGE_OUTPUT_TYPE?=local
%/cgo/amd64 %/cgo/arm64: DOCKERFILE_FOLDER?=$(BUILD_LIB)/docker/linux/cgo
%/cgo/amd64 %/cgo/arm64: IMAGE_NAME=binary-builder
%/cgo/amd64 %/cgo/arm64: IMAGE_BUILD_ARGS?=GOPROXY COMPONENT
%/cgo/amd64 %/cgo/arm64: IMAGE_CONTEXT_DIR?=$(CGO_SOURCE)
%/cgo/amd64 %/cgo/arm64: BUILDER_IMAGE=$(BASE_IMAGE_REPO)/builder-base:latest

%/cgo/amd64: IMAGE_PLATFORMS=linux/amd64
%/cgo/arm64: IMAGE_PLATFORMS=linux/arm64

%/cgo/amd64: prepare-cgo-folder
	$(BUILDCTL)

%/cgo/arm64: prepare-cgo-folder
	$(BUILDCTL)

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

# Build helm chart
.PHONY: helm/build
helm/build: $(LICENSES_TARGETS_FOR_PREREQ)
helm/build: $(if $(filter true,$(REPO_NO_CLONE)),,$(HELM_GIT_CHECKOUT_TARGET))
helm/build: $(if $(wildcard $(MAKE_ROOT)/helm/patches),$(HELM_GIT_PATCH_TARGET),)
	$(BUILD_LIB)/helm_copy.sh $(HELM_SOURCE_REPOSITORY) $(HELM_DESTINATION_REPOSITORY) $(HELM_DIRECTORY) $(OUTPUT_DIR)
	$(BUILD_LIB)/helm_require.sh $(IMAGE_REPO) $(HELM_DESTINATION_REPOSITORY) $(OUTPUT_DIR) $(IMAGE_TAG) $(LATEST) $(HELM_IMAGE_LIST)
	$(BUILD_LIB)/helm_replace.sh $(HELM_DESTINATION_REPOSITORY) $(OUTPUT_DIR)
	$(BUILD_LIB)/helm_build.sh $(OUTPUT_DIR) $(HELM_DESTINATION_REPOSITORY)

# Build helm chart and push to registry defined in IMAGE_REPO.
.PHONY: helm/push
helm/push: helm/build
	$(BUILD_LIB)/helm_push.sh $(IMAGE_REPO) $(HELM_DESTINATION_REPOSITORY) $(IMAGE_TAG) $(OUTPUT_DIR)

## Fetch Binary Targets
$(BINARY_DEPS_DIR)/linux-%:
	$(BUILD_LIB)/fetch_binaries.sh $(BINARY_DEPS_DIR) $* $(ARTIFACTS_BUCKET) $(LATEST) $(RELEASE_BRANCH)


## Build Targets
.PHONY: build
build: FAKE_ARM_IMAGES_FOR_VALIDATION=true
build: $(BUILD_TARGETS)

.PHONY: release
release: $(RELEASE_TARGETS)

.PHONY: %/release-branches/all
%/release-branches/all:
	@for version in $(SUPPORTED_K8S_VERSIONS) ; do \
		$(MAKE) $* RELEASE_BRANCH=$$version; \
	done;

###  Clean Targets

.PHONY: clean-repo
clean-repo:
	@rm -rf $(REPO)	$(HELM_SOURCE_REPOSITORY)

.PHONY: clean
clean: $(if $(filter true,$(REPO_NO_CLONE)),,clean-repo)
	@rm -rf _output	

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
		"$(HAS_S3_ARTIFACTS)" "$(HAS_LICENSES)" "$(REPO_NO_CLONE)" "$(call FULL_FETCH_BINARIES_TARGETS,$(FETCH_BINARIES_TARGETS))" \
		"$(HAS_HELM_CHART)"

## --------------------------------------
## Update Helpers
## --------------------------------------
#@ Update Helpers

.PHONY: run-target-in-docker
run-target-in-docker: # Run `MAKE_TARGET` using builder base docker container
	$(BUILD_LIB)/run_target_docker.sh $(COMPONENT) $(MAKE_TARGET) $(IMAGE_REPO) $(RELEASE_BRANCH) $(ARTIFACTS_BUCKET)

.PHONY: update-attribution-checksums-docker
update-attribution-checksums-docker: # Update attribution and checksums using the builder base docker container
	$(BUILD_LIB)/update_checksum_docker.sh $(COMPONENT) $(IMAGE_REPO) $(RELEASE_BRANCH)

.PHONY: stop-docker-builder
stop-docker-builder: # Clean up builder base docker container
	docker rm -f -v eks-d-builder

.PHONY: generate
generate: # Update UPSTREAM_PROJECTS.yaml
	$(BUILD_LIB)/generate_projects_list.sh $(BASE_DIRECTORY)
