BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=livenessprobe
COMPONENT=kubernetes-csi/$(REPO)

LICENSE_PACKAGE_FILTER=./cmd/livenessprobe
BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/livenessprobe

include $(BASE_DIRECTORY)/Common.mk

$(ATTRIBUTION_TARGET): fix-licenses

.PHONY: images
images: livenessprobe/images/push

.PHONY: local-images
local-images: livenessprobe/images/amd64

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGET)
	build/fix_licenses.sh
