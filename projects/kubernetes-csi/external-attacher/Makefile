BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-attacher
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-attacher
SOURCE_PATTERNS=./cmd/csi-attacher

include $(BASE_DIRECTORY)/Common.mk
