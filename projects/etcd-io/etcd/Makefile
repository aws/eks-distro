BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)

ifdef RELEASE_BRANCH
_bootstrap:=$(shell ./build/bootstrap_build_variables.sh)
export GIT_TAG:=$(shell cat .git_tag)
export GOLANG_VERSION:=$(shell cat .go-version)
$(if $(GIT_TAG),$(shell rm -f .git_tag),$(error GIT_TAG is empty, .git_tag might be missing))
$(if $(GOLANG_VERSION),$(shell rm -f .go-version),$(error GOLANG_VERSION is empty, .go-version might be missing))
endif

REPO=etcd
REPO_OWNER=etcd-io

BINARY_TARGET_FILES=etcd etcdctl
SOURCE_PATTERNS=go.etcd.io/etcd ./etcdctl
EXTRA_GOBUILD_FLAGS=-installsuffix cgo

ROOT_MODULE=go.etcd.io/etcd
EXTRA_GO_LDFLAGS=-X $(ROOT_MODULE)/version.GitSHA=$(shell git -C $(REPO) rev-parse --short $(GIT_TAG))

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)
BUILD_OCI_TARS=true

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true
SKIP_CHECKSUM_VALIDATION=true

-include $(RELEASE_BRANCH)/Overrides.mk
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
	@if [[ "$$($(CLI) --version)" != *"etcd Version: $(GIT_TAG:v%=%)"* ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
