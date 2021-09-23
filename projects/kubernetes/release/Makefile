BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
BUILD_LIB=$(BASE_DIRECTORY)/build/lib
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=release
COMPONENT=kubernetes/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)

MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
BASE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-base
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

.PHONY: binaries
binaries:
	build/create_binaries.sh $(CLONE_URL) $(REPO) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: images
images: binaries
	cp release/images/build/debian-iptables/buster/iptables-wrapper _output/
	$(BUILD_LIB)/buildkit.sh \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64  \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--opt build-arg:RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--local dockerfile=./docker/go-runner/ \
		--local context=. \
		--output type=$(OUTPUT_TYPE),oci-mediatypes=true,name=$(GO_RUNNER_IMAGE),$(GO_RUNNER_OUTPUT)
	$(BUILD_LIB)/buildkit.sh \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64  \
		--opt build-arg:BASE_IMAGE=$(BASE_IMAGE) \
		--opt build-arg:RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--local dockerfile=./docker/kube-proxy-base/ \
		--local context=. \
		--output type=$(OUTPUT_TYPE),oci-mediatypes=true,name=$(KUBE_PROXY_BASE_IMAGE),$(KUBE_PROXY_BASE_OUTPUT)

.PHONY: docker
docker: binaries
	cp release/images/build/debian-iptables/buster/iptables-wrapper _output/
	docker build \
		-t $(GO_RUNNER_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/go-runner/Dockerfile .
	docker build \
		-t $(KUBE_PROXY_BASE_IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg RELEASE_BRANCH=$(RELEASE_BRANCH) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		-f ./docker/kube-proxy-base/Dockerfile .

.PHONY: docker-push
docker-push:
	docker push $(GO_RUNNER_IMAGE)
	docker push $(KUBE_PROXY_BASE_IMAGE)

.PHONY: build release
build: OUTPUT_TYPE=oci
build: GO_RUNNER_OUTPUT=dest=/tmp/go-runner.tar
build: KUBE_PROXY_BASE_OUTPUT=dest=/tmp/kube-proxy-base.tar
release: OUTPUT_TYPE=image
release: GO_RUNNER_OUTPUT=push=true
release: KUBE_PROXY_BASE_OUTPUT=push=true
build release:
	make images OUTPUT_TYPE=$(OUTPUT_TYPE) GO_RUNNER_OUTPUT=$(GO_RUNNER_OUTPUT) KUBE_PROXY_BASE_OUTPUT=$(KUBE_PROXY_BASE_OUTPUT)
	if [ $@ = "build" ]; then \
		make attribution; \
	fi
	echo "Done $(COMPONENT)"

.PHONY: attribution
attribution: 
	build/create_attribution.sh $(GOLANG_VERSION) $(RELEASE_BRANCH)

.PHONY: all
all: release

.PHONY: clean
clean:
	rm -rf ./_output ./release
