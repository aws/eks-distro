export RELEASE_BRANCH?=1-18
export RELEASE?=1

REPO?=coredns
CLONE_URL?=https://github.com/coredns/$(REPO).git
GIT_TAG?=$(shell cat GIT_TAG)
BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)

ifeq ("$(CLONE_URL)","")
	$(error No clone url was provided.)	
endif

ifeq ("$(REPO)","")
	$(error No repository name was provided.)	
endif

ifeq ("$(GIT_TAG)","")
	$(error No git tag was provided.)	
endif

DEVELOPMENT?=true
AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)

MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
BASE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
BASE_IMAGE_NAME?=eks-distro/base
BASE_TAG?=$(shell cat $(MAKE_ROOT)/../../../EKS_DISTRO_BASE_TAG_FILE)
BASE_IMAGE?=$(BASE_REPO)/$(BASE_IMAGE_NAME):$(BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_NAME?=coredns/coredns
# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
IMAGE_TAG?=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

ifeq ($(DEVELOPMENT),true)
	BASE_IMAGE=amazonlinux:2
endif

.PHONY: binaries
binaries:
	build/create_binaries.sh $(CLONE_URL) $(REPO) $(GIT_TAG)

.PHONY: local-images
local-images: binaries
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/linux \
		--local context=. \
		--output type=oci,oci-mediatypes=true,name=$(IMAGE),dest=/tmp/coredns.tar
		
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
	docker build  \
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
release:
	echo "Done coredns/coredns"

.PHONY: all
all: release

.PHONY: clean
clean: 
	rm -rf $(REPO)
	rm -rf "_output"

