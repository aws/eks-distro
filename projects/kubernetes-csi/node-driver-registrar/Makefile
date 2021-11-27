BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=node-driver-registrar
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-node-driver-registrar
SOURCE_PATTERNS=./cmd/csi-node-driver-registrar

include $(BASE_DIRECTORY)/Common.mk

$(ATTRIBUTION_TARGETS): fix-licenses

.PHONY: images
images: node-driver-registrar/images/push

.PHONY: local-images
local-images: node-driver-registrar/images/amd64

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh
