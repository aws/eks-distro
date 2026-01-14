BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=cloud-provider-aws
REPO_OWNER=kubernetes

BINARY_TARGET_FILES=aws-cloud-controller-manager ecr-credential-provider
SOURCE_PATTERNS=./cmd/aws-cloud-controller-manager ./cmd/ecr-credential-provider

KUBE_BASE_GIT_TAG?=$(shell cat $(BASE_DIRECTORY)/projects/kubernetes/release/$(RELEASE_BRANCH)/GIT_TAG)
KUBE_BASE_TAG?=${KUBE_BASE_GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
GO_RUNNER_IMAGE?=$(IMAGE_REPO)/kubernetes/go-runner:$(KUBE_BASE_TAG)
BASE_IMAGE=$(GO_RUNNER_IMAGE)

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true

EXTRA_GO_LDFLAGS=-X k8s.io/component-base/version.gitVersion=$(GIT_TAG)

IMAGE_NAMES=cloud-controller-manager

CLOUD_CONTROLLER_MANAGER_IMAGE_COMPONENT?=kubernetes/cloud-provider-aws/cloud-controller-manager

# Environment variables to support copying the internally built artifacts instead of
# rebuilding from EKS-D repo source
ifdef RELEASE_BRANCH
_bootstrap:=$(shell REPO=$(REPO) ./build/bootstrap_copy_release_variables.sh)
export GIT_TAG:=$(shell cat .git_tag)
export GOLANG_VERSION:=$(shell cat .go-version)
export ARTIFACTS_SOURCE_S3_PATH:=$(shell cat .s3_sync_path)
export SOURCE_IMAGE_TAG:=$(shell cat .source_image_tag)
$(if $(GIT_TAG),$(shell rm -f .git_tag),$(error GIT_TAG is empty, .git_tag might be missing))
$(if $(GOLANG_VERSION),$(shell rm -f .go-version),$(error GOLANG_VERSION is empty, .go-version might be missing))
$(if $(ARTIFACTS_SOURCE_S3_PATH),$(shell rm -f .s3_sync_path),$(error ARTIFACTS_SOURCE_S3_PATH is empty, .s3_sync_path might be missing))
$(if $(SOURCE_IMAGE_TAG),$(shell rm -f .source_image_tag),$(error SOURCE_IMAGE_TAG is empty, .source_image_tag might be missing))
endif

PUSH_IMAGES ?= true
BUILD_ARTIFACTS ?= false
COPY_ARTIFACTS_SCRIPT = RELEASE=$(RELEASE) \
	IMAGE_REPO=$(IMAGE_REPO) \
	IMAGE_NAMES="$(REPO_OWNER)/$(REPO)/$(IMAGE_NAMES)" \
	SOURCE_ECR_REG=$(DEV_ECR_REG) \
	SOURCE_IMAGE_TAG=$(SOURCE_IMAGE_TAG) \
	GO_RUNNER_IMAGE=$(GO_RUNNER_IMAGE) \
	MAKE_ROOT=$(MAKE_ROOT) \
	PUSH_IMAGES=$(PUSH_IMAGES) \
	REPO=$(REPO) \
	$(BASE_DIRECTORY)/build/lib/copy_internal_build_artifacts.sh && chmod +x _output/*

include $(BASE_DIRECTORY)/Common.mk


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
