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

include $(BASE_DIRECTORY)/Common.mk

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
	@mkdir -p $(dir $(PAUSE_DST))
	cp $(PAUSE_SRC_DIR)/linux/pause.c $(PAUSE_DST) || cp $(PAUSE_SRC_DIR)/pause.c $(PAUSE_DST)

tarballs: $(KUBE_GIT_VERSION_FILE)
	@echo -e $(call TARGET_START_LOG)
	build/create_tarballs.sh $(REPO) $(GIT_TAG) $(RELEASE_BRANCH)
	@echo -e $(call TARGET_END_LOG)

.PHONY: cleanup-artifacts
cleanup-artifacts:
	@mkdir -p $(ARTIFACTS_PATH)/bin
	rm -rf $(OUTPUT_DIR)/{attribution,LICENSES,pause} $(OUTPUT_DIR)/bin/{LICENSES,ATTRIBUTION.txt}
	mv $(OUTPUT_DIR)/bin/* $(ARTIFACTS_PATH)/bin
	cp $(OUTPUT_DIR)/ATTRIBUTION.txt $(ARTIFACTS_PATH)

.PHONY: test
test: $(GIT_PATCH_TARGET)
	@echo “!!!GIT_PATCH_TARGET!!! : $(GIT_PATCH_TARGET)”
	@echo “!!!BINARY_TARGETS!!!: $(BINARY_TARGETS)”
	build/run_tests.sh $(RELEASE_BRANCH) $(GOLANG_VERSION)

.PHONY: fix-licenses
fix-licenses: $(GIT_PATCH_TARGET)
	build/fix_licenses.sh $(REPO) $(OUTPUT_DIR) $(RELEASE_BRANCH)

$(KUBE_GIT_VERSION_FILE): $(GIT_PATCH_TARGET)
	build/create_version_file.sh $(GIT_TAG) $(RELEASE_BRANCH)

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
