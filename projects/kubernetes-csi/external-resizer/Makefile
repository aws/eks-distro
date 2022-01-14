BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.16"

REPO=external-resizer
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-resizer
SOURCE_PATTERNS=./cmd/csi-resizer

include $(BASE_DIRECTORY)/Common.mk


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
