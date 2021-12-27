BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=coredns
REPO_OWNER=coredns

LICENSE_PACKAGE_FILTER?=./coredns.go

BINARY_TARGET_FILES=coredns
SOURCE_PATTERNS=.
EXTRA_GO_LDFLAGS=-X github.com/coredns/coredns/coremain.GitCommit=$(shell git -C $(REPO) rev-list -n 1  "${GIT_TAG}")

BASE_IMAGE=$(if $(IS_BUILDING_MINIMAL),$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG),scratch)
IMAGE_TARGET=$(RELEASE_VARIANT)
BUILDER_IMAGE=$(EKS_DISTRO_BASE_IMAGE)

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)
BUILD_OCI_TARS=true

HAS_RELEASE_BRANCHES=true

# sync kubernetes directory for oci tars
HAS_S3_ARTIFACTS=true
SIMPLE_CREATE_TARBALLS=false

include $(BASE_DIRECTORY)/Common.mk


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
