BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?="1.14"

REPO=etcd
COMPONENT=etcd-io/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2

MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
BASE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-base
BASE_TAG?=$(shell cat $(MAKE_ROOT)/../../../EKS_DISTRO_BASE_TAG_FILE)
BASE_IMAGE?=$(BASE_REPO)/$(BASE_IMAGE_NAME):$(BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_REPO_PREFIX=etcd-io
IMAGE_NAME?=$(COMPONENT)
IMAGE_TAG?=$(GIT_TAG)-eks-${RELEASE_BRANCH}-${RELEASE}
IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)


.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: local-images
local-images: binaries
	build/create_images.sh $(RELEASE_BRANCH) $(BASE_IMAGE) \
		$(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) false true

.PHONY: images
images: binaries
	# we publish oci tarballs in release mode in addition to pushing images for installer tools
	build/create_images.sh $(RELEASE_BRANCH) $(BASE_IMAGE) \
		$(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) false

	build/create_images.sh $(RELEASE_BRANCH) $(BASE_IMAGE) \
		$(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) true

.PHONY: docker
docker: binaries
	docker build \
		-t $(IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/linux/Dockerfile .

.PHONY: docker-push
docker-push:
	docker push $(IMAGE)

.PHONY: tarballs
tarballs:
	build/create_tarballs.sh $(REPO) $(GIT_TAG) $(RELEASE_BRANCH)

.PHONY: build
build: local-images tarballs attribution

.PHONY: release
release: images tarballs
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(COMPONENT) $(RELEASE_BRANCH) $(RELEASE)
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
	echo "Done $(COMPONENT)"

.PHONY: all
all: release

.PHONY: attribution
attribution: 
	build/create_attribution.sh $(RELEASE_BRANCH) $(GOLANG_VERSION)

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"

