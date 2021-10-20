BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-attacher
COMPONENT=kubernetes-csi/$(REPO)

LICENSE_PACKAGE_FILTER?=./cmd/csi-attacher

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/csi-attacher

CSI_ATTACHER_IMAGE?=$(IMAGE_REPO)/$(ECR_IMAGE_NAME):$(IMAGE_TAG)

include $(BASE_DIRECTORY)/Common.mk

.PHONY: images
images: csi-attacher/images/push

.PHONY: local-images
local-images: csi-attacher/images/amd64
