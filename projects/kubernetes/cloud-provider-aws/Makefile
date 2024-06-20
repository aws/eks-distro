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

include $(BASE_DIRECTORY)/Common.mk


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
