BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?="1.14"

REPO=etcd
REPO_OWNER=etcd-io

BINARY_TARGET_FILES=etcd etcdctl
SOURCE_PATTERNS=./ ./etcdctl
EXTRA_GOBUILD_FLAGS=-installsuffix cgo
EXTRA_GO_LDFLAGS=-X go.etcd.io/etcd/version.GitSHA=$(shell git -C $(REPO) rev-parse --short $(GIT_TAG))

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)
BUILD_OCI_TARS=true

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true

include $(BASE_DIRECTORY)/Common.mk


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
