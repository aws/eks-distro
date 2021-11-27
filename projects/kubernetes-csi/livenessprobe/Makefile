BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=livenessprobe
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=livenessprobe
SOURCE_PATTERNS=./cmd/livenessprobe

include $(BASE_DIRECTORY)/Common.mk

$(ATTRIBUTION_TARGETS): fix-licenses

.PHONY: images
images: livenessprobe/images/push

.PHONY: local-images
local-images: livenessprobe/images/amd64

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh
