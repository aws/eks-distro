BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=external-snapshotter
REPO_OWNER=kubernetes-csi

CSI_SNAPSHOTTER_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/csi-snapshotter
SNAPSHOT_CONTROLLER_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/snapshot-controller
SNAPSHOT_VALIDATION_WEBHOOK_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/snapshot-validation-webhook

IMAGE_NAMES=csi-snapshotter snapshot-controller snapshot-validation-webhook

SNAPSHOTTER_LICENSE=$(REPO)/vendor/github.com/kubernetes-csi/external-snapshotter/LICENSE

BINARY_TARGET_FILES=snapshot-controller csi-snapshotter snapshot-validation-webhook
SOURCE_PATTERNS=./cmd/snapshot-controller ./cmd/csi-snapshotter ./cmd/snapshot-validation-webhook

DOCKERFILE_FOLDER=./docker/linux/$(IMAGE_NAME)

include $(BASE_DIRECTORY)/Common.mk


$(GATHER_LICENSES_TARGETS): $(SNAPSHOTTER_LICENSE)

# external-snapshotter ends up vendoring some deps that exist in the main repo, but there
# is no license file in the subfolder and go-license is not able to find it
# manually copying the root license to the vendor directory
$(SNAPSHOTTER_LICENSE): $(GIT_CHECKOUT_TARGET)
	cp $(REPO)/LICENSE $@


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
