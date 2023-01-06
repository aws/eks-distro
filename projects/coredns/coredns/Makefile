BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=coredns
REPO_OWNER=coredns

BINARY_TARGET_FILES=coredns
SOURCE_PATTERNS=.
EXTRA_GO_LDFLAGS=-X github.com/coredns/coredns/coremain.GitCommit=$(shell git -C $(REPO) rev-list -n 1  "${GIT_TAG}")

BASE_IMAGE=$(BASE_IMAGE_REPO)/$(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG)
BUILDER_IMAGE=$(EKS_DISTRO_BASE_IMAGE)

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)
BUILD_OCI_TARS=true

HAS_RELEASE_BRANCHES=true

# sync kubernetes directory for oci tars
HAS_S3_ARTIFACTS=true
SIMPLE_CREATE_TARBALLS=false

include $(BASE_DIRECTORY)/Common.mk


build: validate-cli-version
release: validate-cli-version

# To ensure this will work on mac, instead of building those archs
# only build it when run. on a linux builder this extra make will be a noop
.PHONY: validate-cli-version
validate-cli-version: CLI=$(OUTPUT_BIN_DIR)/$(subst /,-,$(BUILDER_PLATFORM))/$(REPO)
validate-cli-version:
	$(MAKE) $(CLI) BINARY_PLATFORMS=$(BUILDER_PLATFORM)
	$(CLI) --version
	@if [[ "$$($(CLI) --version)" != *"CoreDNS-$(GIT_TAG:v%=%)"* ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
