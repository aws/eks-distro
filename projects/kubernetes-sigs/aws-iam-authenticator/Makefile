BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)

GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?="1.13"

REPO=aws-iam-authenticator
COMPONENT=kubernetes-sigs/$(REPO)

LICENSE_PACKAGE_FILTER?=./cmd/aws-iam-authenticator

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/aws-iam-authenticator
BINARY_PLATFORMS=linux/amd64 linux/arm64 darwin/amd64 windows/amd64

AWS_IAM_AUTHENTICATOR_IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

include $(BASE_DIRECTORY)/Common.mk


build: s3-artifacts
release: upload-artifacts

.PHONY: images
images: aws-iam-authenticator/images/push 

.PHONY: local-images
local-images: aws-iam-authenticator/images/amd64

.PHONY: s3-artifacts
s3-artifacts: tarballs
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(REPO) $(OUTPUT_DIR)/tar $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG)
	$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG) $(REPO)

.PHONY: upload-artifacts
upload-artifacts: s3-artifacts	
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
