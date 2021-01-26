export RELEASE_BRANCH?=1-18
export RELEASE?=1

REPO?=release
CLONE_URL?=https://github.com/kubernetes/$(REPO).git
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
GO_RUNNER_IMAGE_NAME?=kubernetes/go-runner
# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
GO_RUNNER_IMAGE_TAG?=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
GO_RUNNER_IMAGE?=$(IMAGE_REPO)/$(GO_RUNNER_IMAGE_NAME):$(GO_RUNNER_IMAGE_TAG)
KUBE_PROXY_BASE_IMAGE_NAME?=kubernetes/kube-proxy-base
# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
KUBE_PROXY_BASE_IMAGE_TAG?=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
KUBE_PROXY_BASE_IMAGE?=$(IMAGE_REPO)/$(KUBE_PROXY_BASE_IMAGE_NAME):$(KUBE_PROXY_BASE_IMAGE_TAG)

ifeq ($(DEVELOPMENT),true)
	BASE_IMAGE=amazonlinux:2
endif

.PHONY: binaries
binaries:
	build/create_binaries.sh $(CLONE_URL) $(REPO) $(GIT_TAG)

.PHONY: local-images
local-images: binaries
	cp release/images/build/debian-iptables/buster/iptables-wrapper _output/
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64  \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/go-runner/ \
		--local context=. \
		--output type=oci,oci-mediatypes=true,name=$(GO_RUNNER_IMAGE),dest=/tmp/go-runner.tar
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64 \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/kube-proxy-base/ \
		--local context=. \
		--output type=oci,oci-mediatypes=true,name=$(KUBE_PROXY_BASE_IMAGE),dest=/tmp/kube-proxy-base.tar

.PHONY: images
images: binaries
	cp release/images/build/debian-iptables/buster/iptables-wrapper _output/
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64  \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/go-runner/ \
		--local context=. \
		--output type=image,oci-mediatypes=true,name=$(GO_RUNNER_IMAGE),push=true
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64  \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--local dockerfile=./docker/kube-proxy-base/ \
		--local context=. \
		--output type=image,oci-mediatypes=true,name=$(KUBE_PROXY_BASE_IMAGE),push=true

.PHONY: docker
docker: binaries
	cp release/images/build/debian-iptables/buster/iptables-wrapper _output/
	docker build \
		-t $(GO_RUNNER_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/go-runner/Dockerfile .
	docker build \
		-t $(KUBE_PROXY_BASE_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/kube-proxy-base/Dockerfile .

.PHONY: docker-push
docker-push:
	docker push $(GO_RUNNER_IMAGE)
	docker push $(KUBE_PROXY_BASE_IMAGE)

.PHONY: clean
clean:
	rm -rf ./_output ./release

.PHONY: build
build: local-images

.PHONY: release
release:
	echo "Done kubernetes/release"

.PHONY: all
all: release
