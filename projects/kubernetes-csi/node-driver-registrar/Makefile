BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=node-driver-registrar
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-node-driver-registrar
SOURCE_PATTERNS=./cmd/csi-node-driver-registrar

BINARY_PLATFORMS=linux/amd64 linux/arm64 windows/amd64

HAS_RELEASE_BRANCHES=true

EXTRA_GO_LDFLAGS=-X main.version=$(GIT_TAG)

include $(BASE_DIRECTORY)/Common.mk


build: validate-cli-version
release: validate-cli-version

node-driver-registrar/images/push: IMAGE_PLATFORMS=linux/amd64,linux/arm64,windows/amd64

$(ATTRIBUTION_TARGETS): fix-licenses

.PHONY: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh $(RELEASE_BRANCH)

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
