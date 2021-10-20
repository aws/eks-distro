BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-snapshotter
COMPONENT=kubernetes-csi/$(REPO)

CSI_SNAPSHOTTER_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/csi-snapshotter
SNAPSHOT_CONTROLLER_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/snapshot-controller
SNAPSHOT_VALIDATION_WEBHOOK_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/snapshot-validation-webhook

IMAGES=csi-snapshotter snapshot-controller snapshot-validation-webhook
LOCAL_IMAGE_TARGETS=$(addsuffix /images/amd64, $(IMAGES))
IMAGE_TARGETS=$(addsuffix /images/push, $(IMAGES))

SNAPSHOOTER_LICENSE=$(REPO)/vendor/github.com/kubernetes-csi/external-snapshotter/LICENSE

LICENSE_PACKAGE_FILTER=./cmd/snapshot-controller ./cmd/csi-snapshotter ./cmd/snapshot-validation-webhook

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/csi-snapshotter

DOCKERFILE_FOLDER=./docker/linux/$(IMAGE_NAME)

include $(BASE_DIRECTORY)/Common.mk


$(GATHER_LICENSES_TARGET): $(SNAPSHOOTER_LICENSE)

# external-snappshotter ends up vendoring some deps that exist in the main repo, but there
# is no license file in the subfolder and go-license is not able to find it
# manually copying the root license to the vendor directory
$(SNAPSHOOTER_LICENSE): $(GIT_CHECKOUT_TARGET)
	cp $(REPO)/LICENSE $@

.PHONY: local-images
local-images: $(LOCAL_IMAGE_TARGETS)

.PHONY: images
images: $(IMAGE_TARGETS)
