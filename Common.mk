# Disable built-in rules and variables
MAKEFLAGS+=--no-builtin-rules --warn-undefined-variables
.SHELLFLAGS:=-eu -o pipefail -c
.SUFFIXES:

RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket

CLONE_URL=https://github.com/$(COMPONENT).git

AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)

MAKE_ROOT=$(BASE_DIRECTORY)/projects/$(COMPONENT)
OUTPUT_DIR?=_output
OUTPUT_BIN_DIR?=$(OUTPUT_DIR)/bin/$(REPO)

BUILD_LIB=${MAKE_ROOT}/../../../build/lib

ATTRIBUTION_TARGET=$(wildcard ATTRIBUTION.txt) $(wildcard $(RELEASE_BRANCH)/ATTRIBUTION.txt)

IMAGE_REPO?=$(if $(AWS_ACCOUNT_ID),$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com,localhost:5000)

BASE_IMAGE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-base
BASE_IMAGE_TAG?=$(shell cat $(BASE_DIRECTORY)/EKS_DISTRO_BASE_TAG_FILE)
BASE_IMAGE?=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG)
BUILDER_IMAGE?=BASE_IMAGE

IMAGE_NAME?=$(COMPONENT)
IMAGE_OUTPUT_DIR?=/tmp
IMAGE_CONTEXT_DIR?=.
IMAGE_OUTPUT_NAME?=$(IMAGE_NAME)
IMAGE=$($(shell echo '$(IMAGE_NAME)' | tr '[:lower:]' '[:upper:]' | tr '-' '_' )_IMAGE)

# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
IMAGE_TAG?=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
DOCKERFILE_FOLDER?=./docker/linux

BINARY_PLATFORMS?=linux/amd64 linux/arm64
SIMPLE_CREATE_BINARIES?=true
SIMPLE_CREATE_TARBALLS?=true

LICENSE_PACKAGE_FILTER?=
REPO_SUBPATH?=
IMAGE_BUILD_ARGS?=
TAR_FILE_PREFIX?=$(REPO)

GIT_CHECKOUT_TARGET=$(REPO)/eks-distro-checkout-$(GIT_TAG)
GATHER_LICENSES_TARGET=$(OUTPUT_DIR)/attribution/go-license.csv
FAKE_ARM_IMAGES_FOR_VALIDATION?=false

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
		--output type=$(IMAGE_OUTPUT_TYPE),oci-mediatypes=true,\"name=$(IMAGE)\",$(IMAGE_OUTPUT)
endef

define WRITE_LOCAL_IMAGE_TAG
	echo $(IMAGE_TAG) > $(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).docker_tag
	echo $(IMAGE) > $(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).docker_image_name	
endef

define IMAGE_TARGETS_FOR_NAME
	$(addsuffix /images/push, $(1)) $(addsuffix /images/amd64, $(1)) $(addsuffix /images/arm64, $(1))
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

$(GIT_CHECKOUT_TARGET): $(REPO)
	git -C $(REPO) checkout -f $(GIT_TAG)
	touch $@

$(BINARY_TARGET): | $(GIT_CHECKOUT_TARGET)
ifeq ($(SIMPLE_CREATE_BINARIES),true)
	$(BASE_DIRECTORY)/build/lib/simple_create_binaries.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(REPO) $(GOLANG_VERSION) $(GIT_TAG) "$(BINARY_PLATFORMS)" $(REPO_SUBPATH)
else
	build/create_binaries.sh $(REPO) $(GOLANG_VERSION) $(GIT_TAG) $(RELEASE_BRANCH)
endif

binaries: ## Build binaries by calling build/lib/simple_create_binaries.sh unless SIMPLE_CREATE_BINARIES=false, then calls build/create_binaries.sh from the project root.
binaries: $(BINARY_TARGET) validate-checksums

## File/Folder Targets

$(OUTPUT_DIR)/images/%:
	@mkdir -p $(@D)

$(OUTPUT_DIR)/ATTRIBUTION.txt:
	@cp $(ATTRIBUTION_TARGET) $(OUTPUT_DIR)


##@ License Targets

## Gather licenses for project based on dependencies in REPO.
$(GATHER_LICENSES_TARGET): $(BINARY_TARGET)
	$(BASE_DIRECTORY)/build/lib/gather_licenses.sh $(REPO) $(MAKE_ROOT)/$(OUTPUT_DIR) "$(LICENSE_PACKAGE_FILTER)" $(REPO_SUBPATH)

$(ATTRIBUTION_TARGET): $(GATHER_LICENSES_TARGET)
	$(BASE_DIRECTORY)/build/lib/create_attribution.sh $(MAKE_ROOT) $(GOLANG_VERSION) $(MAKE_ROOT)/$(OUTPUT_DIR) $(RELEASE_BRANCH)

.PHONY: gather-licenses
gather-licenses: ## Helper to call $(GATHER_LICENSES_TARGET) which gathers all licenses
gather-licenses: $(GATHER_LICENSES_TARGET)

.PHONY: attribution
attribution: ## Generates attribution from licenses gathered during `gather-licenses`.
attribution: $(ATTRIBUTION_TARGET)

##@ Tarball Targets

.PHONY: tarballs
tarballs: ## Create tarballs by calling build/lib/simple_create_tarballs.sh unless SIMPLE_CREATE_TARBALLS=false, then calls build/create_tarballs.sh from project directory
tarballs: $(GATHER_LICENSES_TARGET) $(OUTPUT_DIR)/ATTRIBUTION.txt
ifeq ($(SIMPLE_CREATE_TARBALLS),true)
	$(BASE_DIRECTORY)/build/lib/simple_create_tarballs.sh $(TAR_FILE_PREFIX) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(GIT_TAG) "$(BINARY_PLATFORMS)"
else
	build/create_tarballs.sh $(REPO) $(GIT_TAG) $(RELEASE_BRANCH)
endif


##@ Checksum Targets
	
.PHONY: checksums
checksums: ## Update checksums file based on currently built binaries.
checksums: $(BINARY_TARGET)
	$(BASE_DIRECTORY)/build/lib/update_checksums.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(RELEASE_BRANCH)

.PHONY: validate-checksums
validate-checksums: ## Validate checksums of currently built binaries against checksums file.
validate-checksums: $(BINARY_TARGET)
	$(BASE_DIRECTORY)/build/lib/validate_checksums.sh $(MAKE_ROOT) $(MAKE_ROOT)/$(OUTPUT_BIN_DIR) $(RELEASE_BRANCH)

## Image Targets


#	IMAGE_NAME is dynamically set based on target prefix. \
#	BASE_IMAGE BUILDER_IMAGE RELEASE_BRANCH are automatically passed as build-arg(s) to buildctl. args: \
#	DOCKERFILE_FOLDER: folder containing dockerfile, defaults ./docker/linux \
#	IMAGE_BUILD_ARGS:  additional build-args passed to buildctl, set to name of variable defined in makefile \
#	IMAGE_CONTEXT_DIR: context directory for buildctl, default: .

.PHONY: %/images/push %/images/amd64 %/images/arm64
%/images/push %/images/amd64 %/images/arm64: IMAGE_NAME=$*

%/images/push: ## Build image using buildkit for all platforms, by default pushes to registry defined in IMAGE_REPO.
%/images/push: IMAGE_PLATFORMS?=linux/amd64,linux/arm64
%/images/push: IMAGE_OUTPUT_TYPE?=image
%/images/push: IMAGE_OUTPUT?=push=true
%/images/push: $(GATHER_LICENSES_TARGET) $(OUTPUT_DIR)/ATTRIBUTION.txt
	$(BUILDCTL)

%/images/amd64: ## Build image using buildkit only builds linux/amd64 and saves to local tar.
%/images/amd64: IMAGE_PLATFORMS?=linux/amd64

%/images/arm64: ## Build image using buildkit only builds linux/arm64 and saves to local tar.
%/images/arm64: IMAGE_PLATFORMS?=linux/arm64

%/images/amd64 %/images/arm64: IMAGE_OUTPUT_TYPE?=oci
%/images/amd64 %/images/arm64: IMAGE_OUTPUT?=dest=$(IMAGE_OUTPUT_DIR)/$(IMAGE_OUTPUT_NAME).tar

%/images/amd64: $(GATHER_LICENSES_TARGET) $(OUTPUT_DIR)/ATTRIBUTION.txt
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)

%/images/arm64: $(GATHER_LICENSES_TARGET) $(OUTPUT_DIR)/ATTRIBUTION.txt
	@mkdir -p $(IMAGE_OUTPUT_DIR)
	$(BUILDCTL)
	$(WRITE_LOCAL_IMAGE_TAG)

##@ Build Targets

.PHONY: build
build: ## Called via prow presubmit, calls `binaries gather-licenses clean-repo local-images attribution checksums` by default
build: FAKE_ARM_IMAGES_FOR_VALIDATION=true
build: $(BINARY_TARGET) validate-checksums $(GATHER_LICENSES_TARGET) local-images $(ATTRIBUTION_TARGET)

.PHONY: release
release: ## Called via prow postsubmit + release jobs, calls `binaries gather-licenses clean-repo images` by default
release: $(BINARY_TARGET) validate-checksums $(GATHER_LICENSES_TARGET) images


##@ Clean Targets

.PHONY: clean-repo
clean-repo: ## Removes source directory
clean-repo:
	@rm -rf $(REPO)	

.PHONY: clean
clean: ## Removes source and _output directory
clean: clean-repo
	@rm -rf _output	
