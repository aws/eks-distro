BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=node-driver-registrar
COMPONENT=kubernetes-csi/$(REPO)

LICENSE_PACKAGE_FILTER?=./cmd/csi-node-driver-registrar
BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/csi-node-driver-registrar

NODE_DRIVER_REGISTRAR_IMAGE?=$(IMAGE_REPO)/$(ECR_IMAGE_NAME):$(IMAGE_TAG)

include $(BASE_DIRECTORY)/Common.mk

$(ATTRIBUTION_TARGET): fix-licenses

.PHONY: images
images: node-driver-registrar/images/push

.PHONY: local-images
local-images: node-driver-registrar/images/amd64

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGET)
	build/fix_licenses.sh
