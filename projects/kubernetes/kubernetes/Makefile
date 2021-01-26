export RELEASE_BRANCH?=1-18
export RELEASE?=1

REPOSITORY?=kubernetes
CLONE_URL?=https://github.com/kubernetes/$(REPOSITORY).git
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2

BASE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
GO_RUNNER_IMAGE_NAME?=kubernetes/go-runner
KUBE_PROXY_BASE_IMAGE_NAME?=kubernetes/kube-proxy-base
KUBE_BASE_TAG?=v0.4.2-ea45689a0da457711b15fa1245338cd0b636ad4b
GO_RUNNER_IMAGE?=$(BASE_REPO)/$(GO_RUNNER_IMAGE_NAME):$(KUBE_BASE_TAG)
KUBE_PROXY_BASE_IMAGE?=$(BASE_REPO)/$(KUBE_PROXY_BASE_IMAGE_NAME):$(KUBE_BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_REPO_PREFIX=kubernetes
IMAGE_TAG?=$(GIT_TAG)-eks-${RELEASE_BRANCH}-${RELEASE}

PAUSE_SRC_DIR?=kubernetes/build/pause
PAUSE_DST_DIR?=_output/pause
PAUSE_IMAGE_NAME?=pause
PAUSE_IMAGE_TAG?=$(IMAGE_TAG)
PAUSE_IMAGE?=$(IMAGE_REPO)/$(IMAGE_REPO_PREFIX)/$(PAUSE_IMAGE_NAME):$(PAUSE_IMAGE_TAG)

.PHONY: update-version
update-version: binaries
	build/create_version_file.sh $(GIT_TAG) $(RELEASE_BRANCH)

.PHONY: update-checksums
update-checksums: binaries
	build/update_checksums.sh $(RELEASE_BRANCH)

.PHONY: binaries
binaries:
	build/create_binaries.sh $(CLONE_URL) $(RELEASE_BRANCH)

.PHONY: tarballs
tarballs: binaries
	build/create_tarballs.sh $(RELEASE_BRANCH)

$(PAUSE_DST_DIR)/pause.c:
	mkdir -p $(PAUSE_DST_DIR)
	cp $(PAUSE_SRC_DIR)/linux/pause.c $(PAUSE_DST_DIR) || cp $(PAUSE_SRC_DIR)/pause.c $(PAUSE_DST_DIR)

pause: $(PAUSE_DST_DIR)/pause.c
	rm -rf ./kubernetes

.PHONY: local-images
local-images: binaries pause
	build/create_images.sh $(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) $(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) false
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64 \
		--local dockerfile=./docker/pause/ \
		--local context=./_output/pause \
		--opt build-arg:BASE_IMAGE=$(GO_RUNNER_IMAGE) \
		--opt build-arg:VERSION=$(IMAGE_TAG) \
		--output type=oci,oci-mediatypes=true,name=$(PAUSE_IMAGE),dest=_output/$(RELEASE_BRANCH)/bin/linux/amd64/pause.tar

.PHONY: images
images: binaries pause
	build/create_images.sh $(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) $(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG) true
	buildctl \
		build \
		--frontend dockerfile.v0 \
		--opt platform=linux/amd64,linux/arm64  \
		--local dockerfile=./docker/pause/ \
		--local context=./_output/pause \
		--opt build-arg:BASE_IMAGE=$(GO_RUNNER_IMAGE) \
		--opt build-arg:VERSION=$(IMAGE_TAG) \
		--output type=image,oci-mediatypes=true,\"name=$(PAUSE_IMAGE),$(IMAGE_REPO)/$(IMAGE_REPO_PREFIX)/$(PAUSE_IMAGE_NAME):3.2\",push=true

.PHONY: docker
docker: binaries pause
	build/create_docker_images.sh $(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) $(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG)
	docker \
		build\
		--build-arg BASE_IMAGE=$(GO_RUNNER_IMAGE) \
		--build-arg VERSION=$(IMAGE_TAG) \
		-t $(PAUSE_IMAGE) \
		-t $(IMAGE_REPO)/$(IMAGE_REPO_PREFIX)/$(PAUSE_IMAGE_NAME):3.2 \
		-f ./docker/pause/Dockerfile ./_output/pause/

.PHONY: docker-push
docker-push:
	build/docker_push.sh $(RELEASE_BRANCH) $(GO_RUNNER_IMAGE) $(KUBE_PROXY_BASE_IMAGE) $(IMAGE_REPO) $(IMAGE_REPO_PREFIX) $(IMAGE_TAG)
	docker push $(PAUSE_IMAGE)
	docker push $(IMAGE_REPO)/$(IMAGE_REPO_PREFIX)/$(PAUSE_IMAGE_NAME):3.2

.PHONY: checksums
checksums:
	build/create_release_checksums.sh $(RELEASE_BRANCH)

.PHONY: build
build: checksums

.PHONY: release
release:
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(RELEASE_BRANCH) $(RELEASE) kubernetes/kubernetes
	echo "Done kubernetes/kubernetes"

.PHONY: all
all: release

.PHONY: test
test: binaries
	build/run_tests.sh $(RELEASE_BRANCH)

.PHONY: clean
clean:
	rm -rf ./kubernetes ./_output
