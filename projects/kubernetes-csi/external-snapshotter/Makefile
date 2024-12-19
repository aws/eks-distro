BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=external-snapshotter
REPO_OWNER=kubernetes-csi

CSI_SNAPSHOTTER_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/csi-snapshotter
SNAPSHOT_CONTROLLER_IMAGE_COMPONENT?=kubernetes-csi/external-snapshotter/snapshot-controller

IMAGE_NAMES=csi-snapshotter snapshot-controller

SNAPSHOTTER_LICENSE=$(REPO)/vendor/github.com/kubernetes-csi/external-snapshotter/LICENSE

BINARY_TARGET_FILES=snapshot-controller csi-snapshotter
SOURCE_PATTERNS=./cmd/snapshot-controller ./cmd/csi-snapshotter

DOCKERFILE_FOLDER=./docker/linux/$(IMAGE_NAME)

HAS_RELEASE_BRANCHES=true

EXTRA_GO_LDFLAGS=-X main.version=$(GIT_TAG)

VENDOR_UPDATE_SCRIPT=release-tools/update-vendor.sh

include $(BASE_DIRECTORY)/Common.mk

build: validate-cli-version
release: validate-cli-version

$(GATHER_LICENSES_TARGETS): $(SNAPSHOTTER_LICENSE)

# external-snapshotter ends up vendoring some deps that exist in the main repo, but there
# is no license file in the subfolder and go-license is not able to find it
# manually copying the root license to the vendor directory
$(SNAPSHOTTER_LICENSE): | $(GO_MOD_DOWNLOAD_TARGETS)
	mkdir -p $(@D)
	cp $(REPO)/LICENSE $@


%/validate-cli-version: CLI=./$(OUTPUT_BIN_DIR)/$(subst /,-,$(BUILDER_PLATFORM))/$*
%/validate-cli-version: $(BINARY_TARGETS)
	$(CLI) --version
	@if [[ "$$($(CLI) --version)" != *"$(GIT_TAG)"* ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi

.PHONY: validate-cli-version
validate-cli-version: csi-snapshotter/validate-cli-version snapshot-controller/validate-cli-version


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
