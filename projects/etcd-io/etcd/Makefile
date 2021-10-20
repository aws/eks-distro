BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?="1.14"

REPO=etcd
COMPONENT=etcd-io/$(REPO)

LICENSE_PACKAGE_FILTER?=./ ./etcdctl

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/etcd

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)

include $(BASE_DIRECTORY)/Common.mk

build: local-images s3-artifacts
release: images upload-artifacts

.PHONY: local-images
local-images: etcd/images/amd64

# we publish oci tarballs in release mode in addition to pushing images for installer tools
.PHONY: images
images: $(call IMAGE_TARGETS_FOR_NAME, etcd)

.PHONY: s3-artifacts
s3-artifacts: tarballs
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(REPO) $(OUTPUT_DIR)/tar $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG)
	$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG) $(REPO)
	
	# publish oci tarballs to kubernetes directory as well	
	$(BASE_DIRECTORY)/release/copy_artifacts.sh kubernetes $(OUTPUT_DIR)/images $(RELEASE_BRANCH) $(RELEASE)
	$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG) kubernetes $(FAKE_ARM_IMAGES_FOR_VALIDATION) "-path *etcd*"

.PHONY: upload-artifacts
upload-artifacts: s3-artifacts
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
	# Also sync kubernetes directory for oci tars
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) kubernetes


