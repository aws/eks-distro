BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
BUILD_LIB=$(BASE_DIRECTORY)/build/lib
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)
PAUSE_TAG?=$(shell cat $(wildcard ./$(RELEASE_BRANCH)/PAUSE_*TAG))

REPO=kubernetes
COMPONENT=kubernetes/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2

MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_REPO_PREFIX=kubernetes
IMAGE_TAG?=$(GIT_TAG)-eks-${RELEASE_BRANCH}-${RELEASE}

KUBE_BASE_REPO?=$(IMAGE_REPO)
GO_RUNNER_IMAGE_NAME?=kubernetes/go-runner
KUBE_PROXY_BASE_IMAGE_NAME?=kubernetes/kube-proxy-base
KUBE_BASE_GIT_TAG?=$(shell cat $(BASE_DIRECTORY)/projects/kubernetes/release/$(RELEASE_BRANCH)/GIT_TAG)
KUBE_BASE_TAG?=${KUBE_BASE_GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
GO_RUNNER_IMAGE?=$(KUBE_BASE_REPO)/$(GO_RUNNER_IMAGE_NAME):$(KUBE_BASE_TAG)
KUBE_PROXY_BASE_IMAGE?=$(KUBE_BASE_REPO)/$(KUBE_PROXY_BASE_IMAGE_NAME):$(KUBE_BASE_TAG)

PAUSE_SRC_DIR?=kubernetes/build/pause
PAUSE_DST_DIR?=_output/$(RELEASE_BRANCH)/pause
PAUSE_IMAGE_NAME?=pause
PAUSE_IMAGE_TAG?=$(IMAGE_TAG)
PAUSE_IMAGE?=$(IMAGE_REPO)/$(IMAGE_REPO_PREFIX)/$(PAUSE_IMAGE_NAME):$(PAUSE_IMAGE_TAG)
PAUSE_TAGS=$(foreach tag, $(PAUSE_TAG), $(IMAGE_REPO)/$(IMAGE_REPO_PREFIX)/$(PAUSE_IMAGE_NAME):$(tag))
PAUSE_IMAGE_3_X=$(shell echo $(PAUSE_TAGS) | sed "s/ \+/,/g")

.PHONY: update-version
update-version: binaries
	build/create_version_file.sh $(GIT_TAG) $(RELEASE_BRANCH)

.PHONY: binaries
binaries:
	build/create_binaries.sh $(CLONE_URL) $(RELEASE_BRANCH) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: tarballs
tarballs:
	build/create_tarballs.sh $(RELEASE_BRANCH)

$(PAUSE_DST_DIR)/pause.c:
	mkdir -p $(PAUSE_DST_DIR)
	cp $(PAUSE_SRC_DIR)/linux/pause.c $(PAUSE_DST_DIR) || cp $(PAUSE_SRC_DIR)/pause.c $(PAUSE_DST_DIR)

pause: $(PAUSE_DST_DIR)/pause.c

.PHONY: local-images
local-images:
	build/create_images.sh $(RELEASE_BRANCH) \
		$(GO_RUNNER_IMAGE) \
		$(KUBE_PROXY_BASE_IMAGE) \
		$(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) "$(PAUSE_IMAGE),$(PAUSE_IMAGE_3_X)" false true

.PHONY: images
images:
	# we publish oci tarballs in release mode in addition to pushing images for use by kops and other installer tools
	build/create_images.sh \
		$(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) \
		$(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) "$(PAUSE_IMAGE),$(PAUSE_IMAGE_3_X)" false
	
	build/create_images.sh \
		$(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) \
		$(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) "$(PAUSE_IMAGE),$(PAUSE_IMAGE_3_X)" true
		
.PHONY: docker
docker: binaries pause
	build/create_docker_images.sh $(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) $(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG)
	docker \
		build\
		--build-arg BASE_IMAGE=$(GO_RUNNER_IMAGE) \
		--build-arg VERSION=$(IMAGE_TAG) \
		-t $(PAUSE_IMAGE) \
		-t $(PAUSE_IMAGE_3_X) \
		-f ./docker/pause/Dockerfile $(PAUSE_DST_DIR)

.PHONY: docker-push
docker-push:
	build/docker_push.sh $(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) $(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG)
	docker push $(PAUSE_IMAGE)
	docker push $(PAUSE_IMAGE_3_X)

.PHONY: release-checksums
release-checksums:
	build/create_release_checksums.sh $(RELEASE_BRANCH)

.PHONY: build
build: binaries validate-checksums pause tarballs clean-repo local-images release-checksums attribution 

.PHONY: release
release: binaries validate-checksums pause tarballs clean-repo images release-checksums 
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(COMPONENT) $(RELEASE_BRANCH) $(RELEASE)
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
	echo "Done $(COMPONENT)"

.PHONY: all
all: release

.PHONY: test
test: binaries
	build/run_tests.sh $(RELEASE_BRANCH) $(GOLANG_VERSION)

.PHONY: attribution
attribution: 
	build/create_attribution.sh $(RELEASE_BRANCH) $(GOLANG_VERSION)

.PHONY: checksums
checksums:
	$(BUILD_LIB)/update_checksums.sh $(MAKE_ROOT) $(MAKE_ROOT)/_output/$(RELEASE_BRANCH)/bin $(MAKE_ROOT)/$(RELEASE_BRANCH)/CHECKSUMS

.PHONY: validate-checksums
validate-checksums:	
	sha256sum -c $(MAKE_ROOT)/$(RELEASE_BRANCH)/CHECKSUMS

.PHONY: clean-repo
clean-repo:
	rm -rf ./kubernetes

.PHONY: clean
clean: clean-repo
	rm -rf ./_output
