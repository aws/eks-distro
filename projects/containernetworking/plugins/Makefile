BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)

ifdef RELEASE_BRANCH
_bootstrap:=$(shell ./build/bootstrap_build_variables.sh)
export GIT_TAG:=$(shell cat .git_tag)
export GOLANG_VERSION:=$(shell cat .go-version)
$(if $(GIT_TAG),$(shell rm -f .git_tag),$(error GIT_TAG is empty, .git_tag might be missing))
$(if $(GOLANG_VERSION),$(shell rm -f .go-version),$(error GOLANG_VERSION is empty, .go-version might be missing))
endif

REPO=plugins
REPO_OWNER=containernetworking

TAR_FILE_PREFIX=cni-plugins

SOURCE_PATTERNS_TARGET=_output/$(RELEASE_BRANCH)/source_patterns
EXTRA_GO_LDFLAGS=-X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=$(GIT_TAG)

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true
IMAGE_NAMES=

# Generating the source patterns requires checking out the repo
# delay this as much as possible by skipping when running docker targets
# or all- targets
SKIP_SOURCE_PATTERN_TARGETS=clean clean-go-cache \
	$(foreach target,$(MAKECMDGOALS),$(if $(findstring in-docker,$(target)),$(target),)) \
	$(foreach target,$(MAKECMDGOALS),$(if $(findstring all-,$(target)),$(target),))

ifneq ($(filter-out $(SKIP_SOURCE_PATTERN_TARGETS),$(MAKECMDGOALS)),)
-include $(SOURCE_PATTERNS_TARGET)
endif

include $(BASE_DIRECTORY)/Common.mk

build: validate-cli-version
release: validate-cli-version

$(SOURCE_PATTERNS_TARGET): $(GIT_CHECKOUT_TARGET)
	$(shell build/source_patterns.sh $(REPO) $(MAKE_ROOT)/$@)

# To ensure this will work on mac, instead of building those archs
# only build it when run. on a linux builder this extra make will be a noop
.PHONY: validate-cli-version
validate-cli-version: CLI=$(OUTPUT_BIN_DIR)/$(subst /,-,$(BUILDER_PLATFORM))/static
validate-cli-version:
	$(MAKE) $(CLI) SOURCE_PATTERNS=./plugins/ipam/static BINARY_TARGET_FILES=static  BINARY_PLATFORMS=$(BUILDER_PLATFORM)
	$(CLI) version
	@if [[ "CNI static plugin $(GIT_TAG)" != "$$($(CLI) version)"* ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
