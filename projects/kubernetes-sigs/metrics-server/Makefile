BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=metrics-server
COMPONENT=kubernetes-sigs/$(REPO)

LICENSE_PACKAGE_FILTER=./cmd/metrics-server

BINARY_TARGET=$(OUTPUT_BIN_DIR)/linux-amd64/metrics-server

METRICS_SERVER_IMAGE?=$(IMAGE_REPO)/$(ECR_IMAGE_NAME):$(IMAGE_TAG)

include $(BASE_DIRECTORY)/Common.mk


.PHONY: images
images: metrics-server/images/push

.PHONY: local-images
local-images: metrics-server/images/amd64

