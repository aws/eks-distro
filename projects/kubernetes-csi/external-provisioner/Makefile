BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-provisioner
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-provisioner
SOURCE_PATTERNS=./cmd/csi-provisioner

include $(BASE_DIRECTORY)/Common.mk


.PHONY: images
images: csi-provisioner/images/push

.PHONY: local-images
local-images: csi-provisioner/images/amd64
