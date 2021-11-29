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
BUILD_OCI_TARS=true

HAS_RELEASE_BRANCHES=true

# sync kubernetes directory for oci tars
HAS_S3_ARTIFACTS=true
SIMPLE_CREATE_TARBALLS=false

include $(BASE_DIRECTORY)/Common.mk
