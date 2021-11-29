# Disable built-in rules and variables
MAKEFLAGS+=--no-builtin-rules --warn-undefined-variables
.SHELLFLAGS:=-eu -o pipefail -c
.SUFFIXES:

RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)

GIT_HASH=eks-${RELEASE_BRANCH}-${RELEASE}

COMPONENT?=$(REPO_OWNER)/$(REPO)
MAKE_ROOT=$(BASE_DIRECTORY)/projects/$(COMPONENT)
BUILD_LIB=${BASE_DIRECTORY}/build/lib
OUTPUT_BIN_DIR?=$(OUTPUT_DIR)/bin/$(REPO)

#################### AWS ###########################
AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
ARTIFACT_BUCKET?=my-s3-bucket # TODO: in eks-a we use ARTIFACTS_BUCKET
IMAGE_REPO?=$(if $(AWS_ACCOUNT_ID),$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com,localhost:5000)
####################################################

#################### CODEBUILD #####################
ifdef CODEBUILD_SRC_DIR
	ARTIFACTS_PATH?=$(CODEBUILD_SRC_DIR)/$(PROJECT_PATH)/$(CODEBUILD_BUILD_NUMBER)-$(CODEBUILD_RESOLVED_SOURCE_VERSION)/artifacts
	CLONE_URL=https://git-codecommit.$(AWS_REGION).amazonaws.com/v1/repos/$(REPO_OWNER).$(REPO)
else
	ARTIFACTS_PATH?=$(MAKE_ROOT)/_output/tar
	CLONE_URL=https://github.com/$(COMPONENT).git	
endif
####################################################
#################### GIT ###########################
GIT_CHECKOUT_TARGET?=$(REPO)/eks-distro-checkout-$(GIT_TAG)
GIT_PATCH_TARGET?=$(REPO)/eks-distro-patched
GO_MOD_DOWNLOAD_TARGETS?=$(REPO)/eks-distro-go-mod-download
####################################################

#################### RELEASE BRANCHES ##############
HAS_RELEASE_BRANCHES?=false
RELEASE_BRANCH?=
SUPPORTED_K8S_VERSIONS=1-18 1-19 1-20 1-21
BINARIES_ARE_RELEASE_BRANCHED?=true
ifneq ($(and $(filter true,$(HAS_RELEASE_BRANCHES)),$(RELEASE_BRANCH)),)
	RELEASE_BRANCH_SUFFIX=/$(RELEASE_BRANCH)

	ARTIFACTS_PATH:=$(ARTIFACTS_PATH)$(if $(filter true,$(BINARIES_ARE_RELEASE_BRANCHED)),$(RELEASE_BRANCH_SUFFIX),)
	# Deps are always released branched
	BINARY_DEPS_DIR=$(OUTPUT_DIR)$(if $(filter-out true,$(BINARIES_ARE_RELEASE_BRANCHED)),$(RELEASE_BRANCH_SUFFIX),)/dependencies
	OUTPUT_DIR?=_output$(if $(filter true,$(BINARIES_ARE_RELEASE_BRANCHED)),$(RELEASE_BRANCH_SUFFIX),)
	PROJECT_ROOT?=$(MAKE_ROOT)$(RELEASE_BRANCH_SUFFIX)

else ifneq ($(and $(filter true,$(HAS_RELEASE_BRANCHES)), \
	$(filter-out build release clean,$(MAKECMDGOALS))),)
	# if project has release branches and not calling one of the above targets
$(error When running targets for this project other than `build` or `release` a `RELEASE_BRANCH` is required)
else ifeq ($(HAS_RELEASE_BRANCHES),true)
	# project has release branches and one was not specified, trigger target for all
	BUILD_TARGETS=build/release-branches/all
	RELEASE_TARGETS=release/release-branches/all

	# avoid warnings when trying to read GIT_TAG file which wont exist when no release_branch is given
	GIT_TAG=non-existent
else
	PROJECT_ROOT?=$(MAKE_ROOT)
	OUTPUT_DIR?=_output
endif

####################################################

#################### BASE IMAGES ###################
BASE_IMAGE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-base
BASE_IMAGE_TAG_FILE?=$(BASE_DIRECTORY)/$(shell echo $(BASE_IMAGE_NAME) | tr '[:lower:]' '[:upper:]' | tr '-' '_')_TAG_FILE
BASE_IMAGE_TAG?=$(shell cat $(BASE_IMAGE_TAG_FILE))
BASE_IMAGE?=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG)
BUILDER_IMAGE?=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME)-builder:$(BASE_IMAGE_TAG)
####################################################

#################### IMAGES ########################
IMAGE_COMPONENT?=$(COMPONENT)
IMAGE_DESCRIPTION?=$(COMPONENT)
IMAGE_OUTPUT_DIR?=/tmp
IMAGE_OUTPUT_NAME?=$(IMAGE_NAME)
IMAGE_TARGET?=

# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
IMAGE_TAG?=$(GIT_TAG)-$(GIT_HASH)
# For projects with multiple containers this is defined to override the default
# ex: CLUSTER_API_CONTROLLER_IMAGE_COMPONENT
IMAGE_COMPONENT_VARIABLE=$(shell echo '$(IMAGE_NAME)' | tr '[:lower:]' '[:upper:]' | tr '-' '_' )_IMAGE_COMPONENT
IMAGE=$(IMAGE_REPO)/$(if $(value $(IMAGE_COMPONENT_VARIABLE)),$(value $(IMAGE_COMPONENT_VARIABLE)),$(IMAGE_COMPONENT)):$(IMAGE_TAG)

IMAGE_USERADD_USER_ID?=1000
IMAGE_USERADD_USER_NAME?=

####################################################

#################### BINARIES ######################
BINARY_PLATFORMS?=linux/amd64 linux/arm64
SIMPLE_CREATE_BINARIES?=true

BINARY_TARGETS?=$(call BINARY_TARGETS_FROM_FILES_PLATFORMS, $(BINARY_TARGET_FILES), $(BINARY_PLATFORMS))
BINARY_TARGET_FILES?=
SOURCE_PATTERNS?=.

#### BUILD FLAGS ####
CGO_ENABLED=0
GO_LDFLAGS?=-s -w -buildid= -extldflags -static $(EXTRA_GO_LDFLAGS)
CGO_LDFLAGS?=
EXTRA_GOBUILD_FLAGS?=
EXTRA_GO_LDFLAGS?=
GOBUILD_COMMAND?=build
######################

#### HELPERS ########
# https://riptutorial.com/makefile/example/23643/zipping-lists
# Used to generate binary targets based on BINARY_TARGET_FILES
list-rem = $(wordlist 2,$(words $1),$1)

pairmap = $(and $(strip $2),$(strip $3),$(call \
    $1,$(firstword $2),$(firstword $3)) $(call \
    pairmap,$1,$(call list-rem,$2),$(call list-rem,$3)))
######################

####################################################

############### BINARIES DEPS ######################
BINARY_DEPS_DIR?=$(OUTPUT_DIR)/dependencies
FETCH_BINARIES_TARGETS?=
####################################################

#################### LICENSES ######################
LICENSE_PACKAGE_FILTER?=$(SOURCE_PATTERNS)
REPO_SUBPATH?=
HAS_LICENSES?=true
ATTRIBUTION_TARGETS?=$(if $(wildcard $(RELEASE_BRANCH)/ATTRIBUTION.txt),$(RELEASE_BRANCH)/ATTRIBUTION.txt,ATTRIBUTION.txt)
GATHER_LICENSES_TARGETS?=$(OUTPUT_DIR)/attribution/go-license.csv
LICENSES_OUTPUT_DIR?=$(OUTPUT_DIR)
LICENSES_TARGETS_FOR_PREREQ=$(if $(filter true,$(HAS_LICENSES)),$(GATHER_LICENSES_TARGETS) $(OUTPUT_DIR)/ATTRIBUTION.txt,)
####################################################

#################### TARBALLS ######################
HAS_S3_ARTIFACTS?=false

SIMPLE_CREATE_TARBALLS?=true
TAR_FILE_PREFIX?=$(REPO)
FAKE_ARM_BINARIES_FOR_VALIDATION?=$(if $(filter linux/arm64,$(BINARY_PLATFORMS)),false,true)
FAKE_ARM_IMAGES_FOR_VALIDATION?=false
####################################################

#################### TARGETS FOR OVERRIDING ########
BUILD_TARGETS?=validate-checksums local-images attribution attribution-pr $(if $(filter true,$(HAS_S3_ARTIFACTS)),s3-artifacts,)
RELEASE_TARGETS?=validate-checksums images $(if $(filter true,$(HAS_S3_ARTIFACTS)),s3-artifacts,)
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
		--output type=$(IMAGE_OUTPUT_TYPE),oci-mediatypes=true,\"name=$(IMAGE)\",$(IMAGE_OUTPUT)
endef 

define WRITE_LOCAL_IMAGE_TAG
	echo $(IMAGE_TAG) > $(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).docker_tag
	echo $(IMAGE) > $(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).docker_image_name	
endef

define IMAGE_TARGETS_FOR_NAME
	$(addsuffix /images/push, $(1)) $(addsuffix /images/amd64, $(1)) $(addsuffix /images/arm64, $(1))
endef

define FULL_FETCH_BINARIES_TARGETS
	$(addprefix $(BINARY_DEPS_DIR)/linux-amd64/, $(1)) $(addprefix $(BINARY_DEPS_DIR)/linux-arm64/, $(1))
endef

define BINARY_TARGETS_FROM_FILES_PLATFORMS
	$(foreach platform, $(2), $(foreach target, $(1), \
		$(OUTPUT_BIN_DIR)/$(subst /,-,$(platform))/$(if $(findstring windows,$(platform)),$(target).exe,$(target))))
endef

define BINARY_TARGET_BODY_ALL_PLATFORMS
	$(eval $(foreach platform, $(BINARY_PLATFORMS), \
		$(call BINARY_TARGET_BODY,$(platform),$(if $(findstring windows,$(platform)),$(1).exe,$(1)),$(2))))
endef

define BINARY_TARGET_BODY
	$(OUTPUT_BIN_DIR)/$(subst /,-,$(1))/$(2): $(GO_MOD_DOWNLOAD_TARGETS)
		$(BASE_DIRECTORY)/build/lib/simple_create_binaries.sh $$(MAKE_ROOT) \
			$$(MAKE_ROOT)/$(OUTPUT_BIN_DIR)/$(subst /,-,$(1))/$(2) $$(REPO) $$(GOLANG_VERSION) $(1) $(3) \
			"$$(GOBUILD_COMMAND)" "$$(EXTRA_GOBUILD_FLAGS)" "$$(GO_LDFLAGS)" $$(CGO_ENABLED) "$$(CGO_LDFLAGS)" $$(REPO_SUBPATH)

endef


## --------------------------------------
## Help
## --------------------------------------
##@ Helpers
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Source repo + binary Targets

$(REPO):
	git clone $(CLONE_URL) $(REPO)

$(GIT_CHECKOUT_TARGET): | $(REPO)
	@rm -f $(REPO)/eks-distro-*
	(cd $(REPO) && $(BASE_DIRECTORY)/build/lib/wait_for_tag.sh $(GIT_TAG))
	git -C $(REPO) checkout -f $(GIT_TAG)
	touch $@

$(GIT_PATCH_TARGET): $(GIT_CHECKOUT_TARGET)
	git -C $(REPO) config user.email prow@amazonaws.com
	git -C $(REPO) config user.name "Prow Bot"
	git -C $(REPO) am --committer-date-is-author-date $(PROJECT_ROOT)/patches/*
	@touch $@

%eks-distro-go-mod-download: $(if $(wildcard $(PROJECT_ROOT)/patches),$(GIT_PATCH_TARGET),$(GIT_CHECKOUT_TARGET))
	$(BASE_DIRECTORY)/build/lib/go_mod_download.sh $(MAKE_ROOT) $(REPO) $(GIT_TAG) $(GOLANG_VERSION) $(REPO_SUBPATH)
	@touch $@

ifeq ($(SIMPLE_CREATE_BINARIES),true)
$(call pairmap,BINARY_TARGET_BODY_ALL_PLATFORMS,$(BINARY_TARGET_FILES),$(SOURCE_PATTERNS))
endif

.PHONY: binaries
binaries: ## Build binaries by calling build/lib/simple_create_binaries.sh unless SIMPLE_CREATE_BINARIES=false, then calls build/create_binaries.sh from the project root.
binaries: $(BINARY_TARGETS)

## File/Folder Targets

$(OUTPUT_DIR)/images/%:
	@mkdir -p $(@D)

$(OUTPUT_DIR)/ATTRIBUTION.txt:
	@cp $(ATTRIBUTION_TARGETS) $(OUTPUT_DIR)


##@ License Targets

## Gather licenses for project based on dependencies in REPO.
$(GATHER_LICENSES_TARGETS): $(GO_MOD_DOWNLOAD_TARGETS)
	$(BASE_DIRECTORY)/build/lib/gather_licenses.sh $(REPO) $(MAKE_ROOT)/$(LICENSES_OUTPUT_DIR) "$(LICENSE_PACKAGE_FILTER)" $(REPO_SUBPATH)

# Match all variables of ATTRIBUTION.txt `ATTRIBUTION.txt` `{RELEASE_BRANCH}/ATTRIBUTION.txt` `CAPD_ATTRIBUTION.txt`
%TTRIBUTION.txt: $(GATHER_LICENSES_TARGETS)
	$(BASE_DIRECTORY)/build/lib/create_attribution.sh $(MAKE_ROOT) $(GOLANG_VERSION) $(MAKE_ROOT)/$(LICENSES_OUTPUT_DIR) $(@F) $(RELEASE_BRANCH)

.PHONY: gather-licenses
gather-licenses: ## Helper to call $(GATHER_LICENSES_TARGETS) which gathers all licenses
gather-licenses: $(GATHER_LICENSES_TARGETS)

.PHONY: attribution
attribution: ## Generates attribution from licenses gathered during `gather-licenses`.
attribution: $(ATTRIBUTION_TARGETS)

.PHONY: attribution-pr
attribution-pr: ## Generates PR to update attribution files for projects
attribution-pr:
	$(BASE_DIRECTORY)/build/update-attribution-files/create_pr.sh

##@ Tarball Targets

.PHONY: tarballs
tarballs: ## Create tarballs by calling build/lib/simple_create_tarballs.sh unless SIMPLE_CREATE_TARBALLS=false, then calls build/create_tarballs.sh from project directory
tarballs: $(LICENSES_TARGETS_FOR_PREREQ)
ifeq ($(SIMPLE_CREATE_TARBALLS),true)
	$(BASE_DIRECTORY)/build/lib/simple_create_tarballs.sh $(TAR_FILE_PREFIX) $(MAKE_ROOT)/$(OUTPUT_DIR) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(GIT_TAG) "$(BINARY_PLATFORMS)" $(ARTIFACTS_PATH) $(GIT_HASH)
endif

.PHONY: upload-artifacts
upload-artifacts: s3-artifacts
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET)
	
.PHONY: s3-artifacts
s3-artifacts: tarballs
	for folder in $(ARTIFACTS_PATH) $(OUTPUT_DIR)/images; do \
		if [ -d $$folder ]; then \
			$(BASE_DIRECTORY)/release/copy_artifacts.sh $(REPO) $$folder $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG); \
			$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $$folder $(GIT_TAG) $(FAKE_ARM_IMAGES_FOR_VALIDATION); \
		fi \
	done

##@ Checksum Targets
	
.PHONY: checksums
checksums: ## Update checksums file based on currently built binaries.
checksums: $(BINARY_TARGETS)
	$(BASE_DIRECTORY)/build/lib/update_checksums.sh $(MAKE_ROOT) $(PROJECT_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR)

.PHONY: validate-checksums
validate-checksums: ## Validate checksums of currently built binaries against checksums file.
validate-checksums: $(BINARY_TARGETS)
	$(BASE_DIRECTORY)/build/lib/validate_checksums.sh $(MAKE_ROOT) $(PROJECT_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(FAKE_ARM_BINARIES_FOR_VALIDATION)

## Image Targets


#	IMAGE_NAME is dynamically set based on target prefix. \
#	BASE_IMAGE BUILDER_IMAGE RELEASE_BRANCH are automatically passed as build-arg(s) to buildctl. args: \
#	DOCKERFILE_FOLDER: folder containing dockerfile, defaults ./docker/linux \
#	IMAGE_BUILD_ARGS:  additional build-args passed to buildctl, set to name of variable defined in makefile \
#	IMAGE_CONTEXT_DIR: context directory for buildctl, default: .

.PHONY: %/images/push %/images/amd64 %/images/arm64
%/images/push %/images/amd64 %/images/arm64: IMAGE_NAME=$*
%/images/push %/images/amd64 %/images/arm64: DOCKERFILE_FOLDER?=./docker/linux
%/images/push %/images/amd64 %/images/arm64: IMAGE_CONTEXT_DIR?=.
%/images/push %/images/amd64 %/images/arm64: IMAGE_BUILD_ARGS?=

%/images/push: ## Build image using buildkit for all platforms, by default pushes to registry defined in IMAGE_REPO.
%/images/push: IMAGE_PLATFORMS?=linux/amd64,linux/arm64
%/images/push: IMAGE_OUTPUT_TYPE?=image
%/images/push: IMAGE_OUTPUT?=push=true
%/images/push: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ)
	$(BUILDCTL)

%/images/amd64: ## Build image using buildkit only builds linux/amd64 and saves to local tar.
%/images/amd64: IMAGE_PLATFORMS?=linux/amd64

%/images/arm64: ## Build image using buildkit only builds linux/arm64 and saves to local tar.
%/images/arm64: IMAGE_PLATFORMS?=linux/arm64

%/images/amd64 %/images/arm64: IMAGE_OUTPUT_TYPE?=oci
%/images/amd64 %/images/arm64: IMAGE_OUTPUT?=dest=$(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).tar

%/images/amd64: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ)
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)

%/images/arm64: $(BINARY_TARGETS) $(LICENSES_TARGETS_FOR_PREREQ)
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)

%-useradd/images/export: IMAGE_OUTPUT_TYPE=local
%-useradd/images/export: IMAGE_OUTPUT=dest=$(OUTPUT_DIR)/files/$*
%-useradd/images/export: IMAGE_BUILD_ARGS=IMAGE_USERADD_USER_ID IMAGE_USERADD_USER_NAME
%-useradd/images/export: DOCKERFILE_FOLDER=$(BUILD_LIB)/docker/linux/useradd
%-useradd/images/export: IMAGE_PLATFORMS=linux/amd64
%-useradd/images/export:
	$(BUILDCTL)
##@ Build Targets

.PHONY: build
build: ## Called via prow presubmit, calls `binaries gather-licenses clean-repo local-images attribution checksums` by default
build: FAKE_ARM_IMAGES_FOR_VALIDATION=true
build: $(BUILD_TARGETS)

.PHONY: release
release: ## Called via prow postsubmit + release jobs, calls `binaries gather-licenses clean-repo images` by default
release: $(RELEASE_TARGETS)

.PHONY: %/release-branches/all
%/release-branches/all:
	@for version in $(SUPPORTED_K8S_VERSIONS) ; do \
		$(MAKE) $* RELEASE_BRANCH=$$version; \
	done;

##@ Clean Targets

.PHONY: clean-repo
clean-repo: ## Removes source directory
clean-repo:
	@rm -rf $(REPO)	

.PHONY: clean
clean: ## Removes source and _output directory
clean: clean-repo
	@rm -rf _output	
