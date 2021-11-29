BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=livenessprobe
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=livenessprobe
SOURCE_PATTERNS=./cmd/livenessprobe

include $(BASE_DIRECTORY)/Common.mk

$(ATTRIBUTION_TARGETS): fix-licenses

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh
