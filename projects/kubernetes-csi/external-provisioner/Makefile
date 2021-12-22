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


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
