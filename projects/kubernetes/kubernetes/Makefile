BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
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
BUILDER_IMAGE=$(GO_RUNNER_IMAGE) # for pause

PAUSE_SRC_DIR?=kubernetes/build/pause
PAUSE_DST=$(OUTPUT_DIR)/pause/pause.c
PAUSE_TAG+=$(IMAGE_TAG)
PAUSE_TAGS=$(foreach tag, $(PAUSE_TAG), $(IMAGE_REPO)/kubernetes/pause:$(tag))
PAUSE_IMAGE=$(shell echo $(PAUSE_TAGS) | sed "s/ \+/,/g")

KUBE_APISERVER_IMAGE_COMPONENT=kubernetes/kube-apiserver
KUBE_CONTROLLER_MANAGER_IMAGE_COMPONENT=kubernetes/kube-controller-manager
KUBE_SCHEDULER_IMAGE_COMPONENT=kubernetes/kube-scheduler
KUBE_PROXY_IMAGE_COMPONENT=kubernetes/kube-proxy

IMAGES=pause kube-proxy kube-apiserver kube-controller-manager kube-scheduler
LOCAL_IMAGE_TARGETS_AMD64=$(addsuffix /images/amd64, $(IMAGES))
LOCAL_IMAGE_TARGETS_ARM64=$(addsuffix /images/arm64, $(IMAGES))
IMAGE_TARGETS=$(addsuffix /images/push, $(IMAGES))

IMAGE_CONTEXT_DIR=$(OUTPUT_DIR)
DOCKERFILE_FOLDER=./docker
BASE_IMAGE=$(GO_RUNNER_IMAGE)
IMAGE_BUILD_ARGS=BINARY PAUSE_VERSION
BINARY=$(IMAGE_NAME)
PAUSE_VERSION=$(IMAGE_TAG)

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_BIN_DIR)/$(IMAGE_PLATFORMS)

LICENSE_PACKAGE_FILTER=./cmd/kubelet ./cmd/kube-proxy ./cmd/kubeadm ./cmd/kubectl ./cmd/kube-apiserver ./cmd/kube-controller-manager ./cmd/kube-scheduler

# Since we are overriding the building of binaries, just pick 1 of the binaries as the target
BINARY_TARGETS=$(OUTPUT_BIN_DIR)/linux/amd64/kubelet
SIMPLE_CREATE_BINARIES=false
SIMPLE_CREATE_TARBALLS=false

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true
HAS_S3_KUBERNETES_IMAGES=true
HAS_S3_KUBERNETES_IMAGES_FILTER=-not -path *coredns* -not -path *etcd*

include $(BASE_DIRECTORY)/Common.mk

# Validate version file before uploading artifacts since that runs in both build and release
s3-artifacts: cleanup-artifacts validate-version-file 

# Do not pass down overrides we add in common makefile
$(BINARY_TARGETS): MAKEFLAGS=
$(BINARY_TARGETS): | $(GIT_PATCH_TARGET)
	build/create_binaries.sh $(REPO) $(GOLANG_VERSION) $(GIT_TAG) $(RELEASE_BRANCH)

# There are a couple of fixes needed to the licenses and root-module name before running gather licenses
$(GATHER_LICENSES_TARGETS): fix-licenses

# For kube proxy images, use the kube proxy base
kube-proxy/images/%: BASE_IMAGE=$(KUBE_PROXY_BASE_IMAGE)

# For pause change the dockerfile and base off scratch
# wildcard match doesnt work for add pre-req so have to use helper
pause/images/%: DOCKERFILE_FOLDER=./docker/pause
pause/images/%: BASE_IMAGE=scratch
pause/images/%: IMAGE=$(PAUSE_IMAGE)
$(call IMAGE_TARGETS_FOR_NAME, pause): $(PAUSE_DST)

$(PAUSE_DST): $(GIT_PATCH_TARGET)
	@mkdir -p $(dir $(PAUSE_DST))
	cp $(PAUSE_SRC_DIR)/linux/pause.c $(PAUSE_DST) || cp $(PAUSE_SRC_DIR)/pause.c $(PAUSE_DST)

.PHONY: local-images
local-images: $(LOCAL_IMAGE_TARGETS_AMD64)

# we publish oci tarballs in release mode in addition to pushing images for use by kops and other installer tools
.PHONY: images
images: $(IMAGE_TARGETS) $(LOCAL_IMAGE_TARGETS_AMD64) $(LOCAL_IMAGE_TARGETS_ARM64)
	
tarballs:
	build/create_tarballs.sh $(REPO) $(GIT_TAG) $(RELEASE_BRANCH)

.PHONY: cleanup-artifacts
cleanup-artifacts:
	rm -rf $(OUTPUT_DIR)/{attribution,LICENSES,pause} $(OUTPUT_DIR)/bin/{LICENSES,ATTRIBUTION.txt}
	cp -rf $(OUTPUT_DIR)/* $(ARTIFACTS_PATH)

.PHONY: test
test: $(BINARY_TARGETS)
	build/run_tests.sh $(RELEASE_BRANCH) $(GOLANG_VERSION)

.PHONY: fix-licenses
fix-licenses:
	build/fix_licenses.sh $(REPO) $(OUTPUT_DIR)

.PHONY: update-version
update-version:
	build/create_version_file.sh $(GIT_TAG) $(RELEASE_BRANCH) $(IMAGE_TAG)

.PHONY: validate-version-file
validate-version-file: update-version
	git diff --exit-code $(MAKE_ROOT)/$(RELEASE_BRANCH)/KUBE_GIT_VERSION_FILE

.PHONY: reset-repo
reset-repo: $(REPO)
	git -C $(REPO) checkout master
	git -C $(REPO) clean -fd
