BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=livenessprobe
COMPONENT=kubernetes-csi/$(REPO)

LICENSE_PACKAGE_FILTER=./cmd/livenessprobe
ADDITIONAL_ATTRIBUTION_DEPS=fix-licenses

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/livenessprobe

LIVENESSPROBE_IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

include $(BASE_DIRECTORY)/Common.mk

.PHONY: images
images: livenessprobe/images/push

.PHONY: local-images
local-images: livenessprobe/images/amd64

.PHONE: fix-licenses
fix-licenses: gather-licenses
	build/fix_licenses.sh
