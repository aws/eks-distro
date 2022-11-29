BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=livenessprobe
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=livenessprobe
SOURCE_PATTERNS=./cmd/livenessprobe

BINARY_PLATFORMS=linux/amd64 linux/arm64 windows/amd64

HAS_RELEASE_BRANCHES=true

include $(BASE_DIRECTORY)/Common.mk


livenessprobe/images/push: IMAGE_PLATFORMS=linux/amd64,linux/arm64,windows/amd64

$(ATTRIBUTION_TARGETS): fix-licenses

.PHONY: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh $(RELEASE_BRANCH)


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
