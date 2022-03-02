BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=node-driver-registrar
REPO_OWNER=kubernetes-csi

BINARY_TARGET_FILES=csi-node-driver-registrar
SOURCE_PATTERNS=./cmd/csi-node-driver-registrar

include $(BASE_DIRECTORY)/Common.mk

$(ATTRIBUTION_TARGETS): fix-licenses

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
