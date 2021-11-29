BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=1.13

REPO=coredns
REPO_OWNER=coredns

LICENSE_PACKAGE_FILTER?=./coredns.go

BINARY_TARGET_FILES=coredns
SOURCE_PATTERNS=.
EXTRA_GO_LDFLAGS=-X github.com/coredns/coredns/coremain.GitCommit=$(shell git -C $(REPO) rev-list -n 1  "${GIT_TAG}")

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)

HAS_RELEASE_BRANCHES=true

# sync kubernetes directory for oci tars
HAS_S3_ARTIFACTS=true
SIMPLE_CREATE_TARBALLS=false

include $(BASE_DIRECTORY)/Common.mk


.PHONY: local-images
local-images: coredns/images/amd64

# we publish oci tarballs in release mode in addition to pushing images for installer tools
.PHONY: images
images: $(call IMAGE_TARGETS_FOR_NAME, coredns)
