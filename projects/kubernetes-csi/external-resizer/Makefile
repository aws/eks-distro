BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-resizer
COMPONENT=kubernetes-csi/$(REPO)

LICENSE_PACKAGE_FILTER?=./cmd/csi-resizer

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/csi-resizer

include $(BASE_DIRECTORY)/Common.mk

.PHONY: images
images: csi-resizer/images/push

.PHONY: local-images
local-images: csi-resizer/images/amd64
