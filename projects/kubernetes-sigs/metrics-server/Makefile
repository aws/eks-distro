BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=metrics-server
COMPONENT=kubernetes-sigs/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2

MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
BASE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
BASE_IMAGE_NAME?=eks-distro/base
BASE_TAG?=$(shell cat $(MAKE_ROOT)/../../../EKS_DISTRO_BASE_TAG_FILE)
BASE_IMAGE?=$(BASE_REPO)/$(BASE_IMAGE_NAME):$(BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_NAME?=$(COMPONENT)
IMAGE_TAG?=$(GIT_TAG)-eks-${RELEASE_BRANCH}-${RELEASE}
IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)


#Make sure GOPATH is set
.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: local-images
local-images: binaries
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--opt build-arg:RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--local dockerfile=./docker/linux \
		--local context=. \
		--output type=oci,oci-mediatypes=true,name=$(IMAGE),dest=/tmp/metrics-server.tar

.PHONY: images
images: binaries
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--opt build-arg:RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--local dockerfile=./docker/linux \
		--local context=. \
		--output type=image,oci-mediatypes=true,name=$(IMAGE),push=true

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
	# empty target

.PHONY: build
build: local-images tarballs

.PHONY: release
release: images tarballs
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

