BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-resizer
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-resizer
SOURCE_PATTERNS=./cmd/csi-resizer

include $(BASE_DIRECTORY)/Common.mk

.PHONY: images
images: csi-resizer/images/push

.PHONY: local-images
local-images: csi-resizer/images/amd64
