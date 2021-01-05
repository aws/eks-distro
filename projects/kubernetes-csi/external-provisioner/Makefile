REPO?=external-provisioner
CLONE_URL?=https://github.com/kubernetes-csi/$(REPO).git
GIT_TAG?=$(shell cat GIT_TAG)

ifeq ("$(REPO)","")
	$(error No repository name was provided.)
endif

ifeq ("$(CLONE_URL)","")
	$(error No clone url was provided.)
endif

ifeq ("$(GIT_TAG)","")
	$(error No git tag was provided.)
endif

DEVELOPMENT?=true
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2

RELEASE_BRANCH?="1-18"
RELEASE?="1"

BASE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
BASE_IMAGE_NAME?=eks-distro/base
BASE_TAG?=26f234d9da8bc4423bacb539caaece931808d28b
BASE_IMAGE?=$(BASE_REPO)/$(BASE_IMAGE_NAME):$(BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_NAME?=kubernetes-csi/external-provisioner
IMAGE_TAG?=$(GIT_TAG)-eks-${RELEASE_BRANCH}-${RELEASE}
IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)
GOPROXY_DNS?=direct
export GOPROXY=$(GOPROXY_DNS)

ifeq ($(DEVELOPMENT),true)
	BASE_IMAGE=amazonlinux:2
endif


.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG)

.PHONY: local-images
local-images: binaries
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/linux \
		--local context=. \
		--output type=oci,oci-mediatypes=true,name=$(IMAGE),dest=/tmp/external-provisioner.tar

.PHONY: images
images: binaries
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/linux \
		--local context=. \
		--output type=image,oci-mediatypes=true,name=$(IMAGE),push=true

.PHONY: docker
docker: binaries
	docker build \
		-t $(IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/linux/Dockerfile .

.PHONY: docker-push
docker-push:
	docker push $(IMAGE)

.PHONY: build
build: local-images

.PHONY: release
release: images

.PHONY: all
all: release

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"
