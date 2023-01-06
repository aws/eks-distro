BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=metrics-server
REPO_OWNER=kubernetes-sigs

BINARY_TARGET_FILES=metrics-server
SOURCE_PATTERNS=./cmd/metrics-server

PKG=k8s.io/client-go/pkg
GIT_COMMIT=$(shell git -C $(REPO) describe --always --abbrev=0)
BUILD_DATE=$(shell git -C $(REPO) show -s --format=format:%cd --date=format:'%Y-%m-%dT%H:%M:%SZ' HEAD)
EXTRA_GO_LDFLAGS=-X $(PKG)/version.gitVersion=$(GIT_TAG) -X $(PKG)/version.gitCommit=$(GIT_COMMIT) -X $(PKG)/version.buildDate=$(BUILD_DATE)

HAS_RELEASE_BRANCHES=true

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
	@if [[ "$$($(CLI) --version)" != "$(GIT_TAG)" ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
