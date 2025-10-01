BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)
PAUSE_TAG?=$(shell cat $(wildcard ./$(RELEASE_BRANCH)/PAUSE_*TAG))

REPO=kubernetes
REPO_OWNER=kubernetes

# binaries do not build to bin/$(repo) like most other projects
OUTPUT_DIR=_output/$(RELEASE_BRANCH)
OUTPUT_BIN_DIR=$(OUTPUT_DIR)/bin

KUBE_BASE_GIT_TAG?=$(shell cat $(BASE_DIRECTORY)/projects/kubernetes/release/$(RELEASE_BRANCH)/GIT_TAG)
KUBE_BASE_TAG?=${KUBE_BASE_GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
GO_RUNNER_IMAGE?=$(IMAGE_REPO)/kubernetes/go-runner:$(KUBE_BASE_TAG)
KUBE_PROXY_BASE_IMAGE?=$(IMAGE_REPO)/kubernetes/kube-proxy-base:$(KUBE_BASE_TAG)
BUILDER_IMAGE=$(EKS_DISTRO_BASE_IMAGE) # for pause

PAUSE_SRC_DIR?=kubernetes/build/pause
PAUSE_DST=$(OUTPUT_DIR)/pause/pause.c
PAUSE_TAG+=$(IMAGE_TAG)
PAUSE_TAGS=$(foreach tag, $(PAUSE_TAG), $(IMAGE_REPO)/kubernetes/pause:$(tag))
PAUSE_IMAGE=$(shell echo $(PAUSE_TAGS) | sed "s/ \+/,/g")

KUBE_APISERVER_IMAGE_COMPONENT=kubernetes/kube-apiserver
KUBE_CONTROLLER_MANAGER_IMAGE_COMPONENT=kubernetes/kube-controller-manager
KUBE_SCHEDULER_IMAGE_COMPONENT=kubernetes/kube-scheduler
KUBE_PROXY_IMAGE_COMPONENT=kubernetes/kube-proxy

IMAGE_NAMES=pause kube-proxy kube-apiserver kube-controller-manager kube-scheduler
DOCKER_TAR_IMAGE_NAMES=$(filter-out pause,$(IMAGE_NAMES))
BUILD_OCI_TARS=true

DOCKERFILE_FOLDER=./docker
BASE_IMAGE=$(GO_RUNNER_IMAGE)
IMAGE_BUILD_ARGS=BINARY PAUSE_VERSION
BINARY=$(IMAGE_NAME)
PAUSE_VERSION=$(IMAGE_TAG)

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)

LICENSE_PACKAGE_FILTER=./cmd/kubelet ./cmd/kube-proxy ./cmd/kubeadm ./cmd/kubectl ./cmd/kube-apiserver ./cmd/kube-controller-manager ./cmd/kube-scheduler

# Since we are overriding the building of binaries, just pick 1 of the binaries as the target
# kubernetes outputs to linux/amd64 instead of linux-amd64, have to override binary_targets as well
BINARY_TARGET_FILES=kubelet
BINARY_TARGETS=$(OUTPUT_BIN_DIR)/linux/amd64/kubelet

SIMPLE_CREATE_BINARIES=false
SIMPLE_CREATE_TARBALLS=false

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true

KUBE_GIT_VERSION_FILE=$(RELEASE_BRANCH)/KUBE_GIT_VERSION_FILE

# Environment variables to support copying the internally built artifacts instead of
# rebuilding from EKS-D repo source
BUILD_ARTIFACTS ?= false
ifeq ($(BUILD_ARTIFACTS),false)
BINARY_TARGETS:=

ifdef RELEASE_BRANCH
export KUBERNETES_ARTIFACTS_SOURCE_S3_BUCKET:="eks-distro-dev-release-artifacts"
_bootstrap:=$(shell ./build/bootstrap_copy_release_variables.sh)
export GIT_TAG:=$(shell cat .k8s_version)
export GOLANG_VERSION:=$(shell cat .go-version)
export EKS_VERSION:=$(shell cat .eks_version)
export KUBERNETES_ARTIFACTS_SOURCE_S3_RELEASE_PATH:=$(shell cat .s3_sync_path)
$(if $(GIT_TAG),$(shell rm -f .k8s_version),$(error GIT_TAG is empty, .k8s_version might be missing))
$(if $(GOLANG_VERSION),$(shell rm -f .go-version),$(error GOLANG_VERSION is empty, .go-version might be missing))
$(if $(EKS_VERSION),$(shell rm -f .eks_version),$(error EKS_VERSION is empty, .eks_version might be missing))
$(if $(KUBERNETES_ARTIFACTS_SOURCE_S3_RELEASE_PATH),$(shell rm -f .s3_sync_path),$(error KUBERNETES_ARTIFACTS_SOURCE_S3_RELEASE_PATH is empty, .s3_sync_path might be missing))
endif

endif


include $(BASE_DIRECTORY)/Common.mk

##################################### START Image Copy Block #####################################
# if we are not building artifacts, run the copy script instead to grab the latest source
# we can deprecate the rest of the processing when all projects are moved to internal builds
ifeq ($(BUILD_ARTIFACTS),false)
# Override the main build targets to copy instead of build
.PHONY: binaries
binaries: copy-kubernetes-artifacts
	@echo -e $(call TARGET_START_LOG)
	@echo "Using copied binaries instead of building"
	@echo -e $(call TARGET_END_LOG)

.PHONY: images
images: copy-kubernetes-artifacts
	@echo -e $(call TARGET_START_LOG)
	@echo "Using copied images instead of building images"
	@echo -e $(call TARGET_END_LOG)

# Override local-images to use copied images instead of building
.PHONY: local-images
local-images: copy-kubernetes-artifacts
	@echo -e $(call TARGET_START_LOG)
	@echo "Using copied images instead of building local images"
	@echo -e $(call TARGET_END_LOG)

# Override all individual image targets to do nothing when copying
.PHONY: $(call IMAGE_TARGETS_FOR_NAME, pause)
$(call IMAGE_TARGETS_FOR_NAME, pause):
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping build of pause - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

.PHONY: $(LOCAL_IMAGE_TARGETS)
$(LOCAL_IMAGE_TARGETS):
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping build of $@ - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

.PHONY: $(IMAGE_TARGETS)
$(IMAGE_TARGETS):
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping build of $@ - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

.PHONY: $(foreach image,$(DOCKER_TAR_IMAGE_NAMES),$(image)/images/arm64)
$(foreach image,$(DOCKER_TAR_IMAGE_NAMES),$(image)/images/arm64):
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping build of $@ - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

.PHONY: $(foreach image,$(IMAGE_NAMES),$(image)/images/push)
$(foreach image,$(IMAGE_NAMES),$(image)/images/push):
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping push of $@ - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

# Copy artifacts from source S3 to local _output structure
# this includes tarballs, kube binaries, and image tars
.PHONY: copy-kubernetes-artifacts
copy-kubernetes-artifacts:
	@echo -e $(call TARGET_START_LOG)
	@echo "Copying Kubernetes binaries from S3..."
	@mkdir -p _output/
	RELEASE=$(RELEASE) \
    IMAGE_REPO=$(IMAGE_REPO) \
    SOURCE_ECR_REG=$(DEV_ECR_REG) \
    GO_RUNNER_IMAGE=$(GO_RUNNER_IMAGE) \
    MAKE_ROOT=$(MAKE_ROOT) \
    ./build/copy_kubernetes_artifacts.sh
	@chmod +x _output/*
	@echo -e $(call TARGET_END_LOG)

# Override attribution-related targets
.PHONY: $(GATHER_LICENSES_TARGETS)
$(GATHER_LICENSES_TARGETS):
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping license gathering - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

.PHONY: gather-licenses
gather-licenses:
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping license gathering - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

# Override the go-license.csv pattern target
$(OUTPUT_DIR)/%ttribution/go-license.csv:
	@echo -e $(call TARGET_START_LOG)
	@echo "Skipping go-license.csv generation - using copied artifacts"
	@echo -e $(call TARGET_END_LOG)

.PHONY: setup-internal-build-files
setup-internal-build-files: copy-kubernetes-artifacts

endif
##################################### END Image Copy Block #####################################

# Validate version file before uploading artifacts since that runs in both build and release
s3-artifacts: cleanup-artifacts

# Do not pass down overrides we add in common makefile
$(BINARY_TARGETS): MAKEFLAGS=
$(BINARY_TARGETS): $(KUBE_GIT_VERSION_FILE) | $(GIT_PATCH_TARGET)
	@echo -e $(call TARGET_START_LOG)
	build/create_binaries.sh $(REPO) $(GOLANG_VERSION) $(GIT_TAG) $(RELEASE_BRANCH)
	@echo -e $(call TARGET_END_LOG)

# There are a couple of fixes needed to the licenses and root-module name before running gather licenses
$(GATHER_LICENSES_TARGETS): fix-licenses

# Intentional override since this projects deps are vendored and handled a bit differently
# there is no need to go mod download
$(GO_MOD_DOWNLOAD_TARGETS):
	touch $@

# upstream builds the server images as docker format vs oci
$(foreach image,$(DOCKER_TAR_IMAGE_NAMES),$(image)/images/amd64 $(image)/images/arm64): IMAGE_OUTPUT_TYPE=docker
# we only want the main tag, not the -latest, in the repoTags in the final docker manifest
$(foreach image,$(DOCKER_TAR_IMAGE_NAMES),$(image)/images/amd64 $(image)/images/arm64): ALL_IMAGE_TAGS=$(IMAGE)
# since these images are included in the tar we need to generate them during presubmit/local-images
# by default only the amd64s are built to match the host arch on prow
# since these images are simple COPY/ADD dockerfiles there should be no problem building for arm on an amd host, even without qemu
local-images: $(foreach image,$(DOCKER_TAR_IMAGE_NAMES),$(image)/images/arm64)

# For kube proxy images, use the kube proxy base
kube-proxy/images/%: BASE_IMAGE=$(KUBE_PROXY_BASE_IMAGE)

# For pause change the dockerfile and base off scratch
# wildcard match doesnt work for add pre-req so have to use helper
pause/images/%: DOCKERFILE_FOLDER=./docker/pause
pause/images/%: BASE_IMAGE_NAME=eks-distro-minimal-base-nonroot
pause/images/%: BASE_IMAGE=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG)
pause/images/%: IMAGE=$(PAUSE_IMAGE)
$(call IMAGE_TARGETS_FOR_NAME, pause): $(PAUSE_DST)

$(PAUSE_DST): $(GIT_PATCH_TARGET)
	@$(if $(filter true,$(BUILD_ARTIFACTS)),\
		mkdir -p $(dir $(PAUSE_DST)) && \
		(cp $(PAUSE_SRC_DIR)/linux/pause.c $(PAUSE_DST) || cp $(PAUSE_SRC_DIR)/pause.c $(PAUSE_DST)),)

tarballs: $(KUBE_GIT_VERSION_FILE)
	@$(if $(filter true,$(BUILD_ARTIFACTS)),\
		echo -e $(call TARGET_START_LOG) && \
		build/create_tarballs.sh $(REPO) $(GIT_TAG) $(RELEASE_BRANCH) && \
		echo -e $(call TARGET_END_LOG),)

.PHONY: cleanup-artifacts
cleanup-artifacts:
	@if [ "$(BUILD_ARTIFACTS)" = "true" ]; then \
		mkdir -p "$(ARTIFACTS_PATH)/bin"; \
		rm -rf "$(OUTPUT_DIR)/attribution" "$(OUTPUT_DIR)/LICENSES" "$(OUTPUT_DIR)/pause" "$(OUTPUT_DIR)/bin/LICENSES" "$(OUTPUT_DIR)/bin/ATTRIBUTION.txt"; \
		mv "$(OUTPUT_DIR)/bin/"* "$(ARTIFACTS_PATH)/bin"; \
		cp "$(OUTPUT_DIR)/ATTRIBUTION.txt" "$(ARTIFACTS_PATH)"; \
		if [ "$(FAKE_ARM_IMAGES_FOR_VALIDATION)" = "true" ]; then rm -rf "$(OUTPUT_DIR)/images/bin/linux/arm64"; fi; \
	else \
		mkdir -p "$(ARTIFACTS_PATH)/bin"; \
		mv "$(OUTPUT_DIR)/bin/"* "$(ARTIFACTS_PATH)/bin"; \
		if [ "$(FAKE_ARM_IMAGES_FOR_VALIDATION)" = "true" ]; then rm -rf "$(OUTPUT_DIR)/images/bin/linux/arm64"; fi; \
	fi

.PHONY: test
test: $(GIT_PATCH_TARGET)
	@$(if $(filter true,$(BUILD_ARTIFACTS)),\
		echo "!!!GIT_PATCH_TARGET!!! : $(GIT_PATCH_TARGET)" && \
		echo "!!!BINARY_TARGETS!!!: $(BINARY_TARGETS)" && \
		build/run_tests.sh $(RELEASE_BRANCH) $(GOLANG_VERSION),)

.PHONY: fix-licenses
fix-licenses: $(GIT_PATCH_TARGET)
	@$(if $(filter true,$(BUILD_ARTIFACTS)),\
		build/fix_licenses.sh $(REPO) $(OUTPUT_DIR) $(RELEASE_BRANCH),)

$(KUBE_GIT_VERSION_FILE): $(GIT_PATCH_TARGET)
	@$(if $(filter true,$(BUILD_ARTIFACTS)),\
		build/create_version_file.sh $(GIT_TAG) $(RELEASE_BRANCH),)

.PHONY: reset-repo
reset-repo: $(REPO)
	git -C $(REPO) checkout -- .
	git -C $(REPO) clean -fd
	git -C $(REPO) checkout master
	


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
