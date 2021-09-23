BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
BUILD_LIB=$(BASE_DIRECTORY)/build/lib
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?="1.15"

REPO=external-snapshotter
COMPONENT=kubernetes-csi/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2

MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
BASE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-base
BASE_TAG?=$(shell cat $(MAKE_ROOT)/../../../EKS_DISTRO_BASE_TAG_FILE)
BASE_IMAGE?=$(BASE_REPO)/$(BASE_IMAGE_NAME):$(BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
CSI_SNAPSHOTTER_IMAGE_TAG=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
CSI_SNAPSHOTTER_IMAGE?=$(IMAGE_REPO)/kubernetes-csi/external-snapshotter/csi-snapshotter:$(CSI_SNAPSHOTTER_IMAGE_TAG)
SNAPSHOT_CONTROLLER_IMAGE_TAG=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
SNAPSHOT_CONTROLLER_IMAGE?=$(IMAGE_REPO)/kubernetes-csi/external-snapshotter/snapshot-controller:$(SNAPSHOT_CONTROLLER_IMAGE_TAG)
SNAPSHOT_VALIDATION_WEBHOOK_IMAGE_TAG=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
SNAPSHOT_VALIDATION_WEBHOOK_IMAGE?=$(IMAGE_REPO)/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:$(SNAPSHOT_VALIDATION_WEBHOOK_IMAGE_TAG)
GOPROXY_DNS?=direct
export GOPROXY=$(GOPROXY_DNS)

.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: images
images: binaries
	$(BUILD_LIB)/buildkit.sh \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/linux/csi-snapshotter \
		--local context=. \
		--output type=$(OUTPUT_TYPE),oci-mediatypes=true,name=$(CSI_SNAPSHOTTER_IMAGE),$(CSI_SNAPSHOTTER_OUTPUT)
	$(BUILD_LIB)/buildkit.sh \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/linux/snapshot-controller \
		--local context=. \
		--output type=$(OUTPUT_TYPE),oci-mediatypes=true,name=$(SNAPSHOT_CONTROLLER_IMAGE),$(SNAPSHOT_CONTROLLER_OUTPUT)
	$(BUILD_LIB)/buildkit.sh \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/linux/snapshot-validation-webhook \
		--local context=. \
		--output type=$(OUTPUT_TYPE),oci-mediatypes=true,name=$(SNAPSHOT_VALIDATION_WEBHOOK_IMAGE),$(SNAPSHOT_VALIDATION_WEBHOOK_OUTPUT)

.PHONY: docker
docker: binaries
	docker build \
		-t $(CSI_SNAPSHOTTER_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/linux/csi-snapshotter/Dockerfile .
	docker build \
		-t $(SNAPSHOT_CONTROLLER_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/linux/snapshot-controller/Dockerfile .
	docker build \
		-t $(SNAPSHOT_VALIDATION_WEBHOOK_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/linux/snapshot-validation-webhook/Dockerfile .

.PHONY: docker-push
docker-push:
	docker push $(CSI_SNAPSHOTTER_IMAGE)
	docker push $(SNAPSHOT_CONTROLLER_IMAGE)
	docker push $(SNAPSHOT_VALIDATION_WEBHOOK_IMAGE)

.PHONY: build release
build: OUTPUT_TYPE=oci
build: CSI_SNAPSHOTTER_OUTPUT=dest=/tmp/csi-snapshotter.tar
build: SNAPSHOT_CONTROLLER_OUTPUT=dest=/tmp/snapshot-controller.tar
build: SNAPSHOT_VALIDATION_WEBHOOK_OUTPUT=dest=/tmp/snapshot-validation-webhook.tar
release: OUTPUT_TYPE=image
release: CSI_SNAPSHOTTER_OUTPUT=push=true
release: SNAPSHOT_CONTROLLER_OUTPUT=push=true
release: SNAPSHOT_VALIDATION_WEBHOOK_OUTPUT=push=true
build release:
	make images OUTPUT_TYPE=$(OUTPUT_TYPE) \
		CSI_SNAPSHOTTER_OUTPUT=$(CSI_SNAPSHOTTER_OUTPUT) \
		SNAPSHOT_CONTROLLER_OUTPUT=$(SNAPSHOT_CONTROLLER_OUTPUT) \
		SNAPSHOT_VALIDATION_WEBHOOK_OUTPUT=$(SNAPSHOT_VALIDATION_WEBHOOK_OUTPUT)
	if [ $@ = "build" ]; then \
		make attribution; \
	fi
	echo "Done $(COMPONENT)"

.PHONY: attribution
attribution: 
	build/create_attribution.sh $(GOLANG_VERSION)

.PHONY: all
all: release

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"
