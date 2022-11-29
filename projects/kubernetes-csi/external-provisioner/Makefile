BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=external-provisioner
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-provisioner
SOURCE_PATTERNS=./cmd/csi-provisioner

HAS_RELEASE_BRANCHES=true

EXTRA_GO_LDFLAGS=-X main.version=$(GIT_TAG)

VENDOR_UPDATE_SCRIPT=release-tools/update-vendor.sh

include $(BASE_DIRECTORY)/Common.mk

build: validate-cli-version
release: validate-cli-version


.PHONY: validate-cli-version
validate-cli-version: CLI=./$(OUTPUT_BIN_DIR)/$(subst /,-,$(BUILDER_PLATFORM))/$(BINARY_TARGET_FILES)
validate-cli-version: $(BINARY_TARGETS)
	$(CLI) --version
	@if [[ "$$($(CLI) --version)" != *"$(GIT_TAG)"* ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi

########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
