BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?=1.14

REPO=plugins
REPO_OWNER=containernetworking

TAR_FILE_PREFIX=cni-plugins

SOURCE_PATTERNS_TARGET=_output/source_patterns

HAS_S3_ARTIFACTS=true
IMAGE_NAMES=

ifneq ($(filter-out clean,$(MAKECMDGOALS)),)
-include $(SOURCE_PATTERNS_TARGET)
endif

include $(BASE_DIRECTORY)/Common.mk

$(SOURCE_PATTERNS_TARGET): $(GIT_CHECKOUT_TARGET)
	$(shell build/source_patterns.sh $(REPO) $(MAKE_ROOT)/$@)


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
