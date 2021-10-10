BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?=1.14

REPO=plugins
COMPONENT=containernetworking/$(REPO)

LICENSE_PACKAGE_FILTER?=$(shell build/license_patterns.sh $(REPO))
TAR_FILE_PREFIX=cni-plugins

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/host-device

include $(BASE_DIRECTORY)/Common.mk

build: s3-artifacts
release: upload-artifacts

.PHONY: s3-artifacts
s3-artifacts: tarballs
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(REPO) $(OUTPUT_DIR)/tar $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG)
	$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG) $(REPO)

.PHONY: upload-artifacts
upload-artifacts: s3-artifacts
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)

local-images: # noop
images: # noop
