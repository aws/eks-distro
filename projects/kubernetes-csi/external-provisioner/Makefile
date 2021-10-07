BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-provisioner
COMPONENT=kubernetes-csi/$(REPO)

LICENSE_PACKAGE_FILTER?=./cmd/csi-provisioner

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/csi-provisioner

CSI_PROVISIONER_IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

include $(BASE_DIRECTORY)/Common.mk


.PHONY: images
images: csi-provisioner/images/push

.PHONY: local-images
local-images: csi-provisioner/images/amd64
