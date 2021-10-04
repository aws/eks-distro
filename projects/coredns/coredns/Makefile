BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
BUILD_LIB=$(BASE_DIRECTORY)/build/lib
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=1.13

REPO=coredns
COMPONENT=coredns/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

AWS_REGION?=us-west-2
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)

MAKE_ROOT=$(BASE_DIRECTORY)/projects/$(COMPONENT)
BASE_REPO?=public.ecr.aws/eks-distro-build-tooling
BASE_IMAGE_NAME?=eks-distro-base
BASE_TAG?=$(shell cat $(BASE_DIRECTORY)/EKS_DISTRO_BASE_TAG_FILE)
BASE_IMAGE?=$(BASE_REPO)/$(BASE_IMAGE_NAME):$(BASE_TAG)

IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE_NAME?=$(COMPONENT)
# This tag is overwritten in the prow job to point to the upstream git tag and this repo's commit hash
IMAGE_TAG?=${GIT_TAG}-eks-${RELEASE_BRANCH}-${RELEASE}
IMAGE?=$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

FAKE_ARM_IMAGES_FOR_VALIDATION?=false

.PHONY: binaries
binaries:
	build/create_binaries.sh $(CLONE_URL) $(REPO) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: local-images
local-images: binaries
	build/create_images.sh $(RELEASE_BRANCH) $(BASE_IMAGE) \
		$(IMAGE_REPO) $(COMPONENT) $(IMAGE_TAG) false true
		
.PHONY: images
images: binaries
	# we publish oci tarballs in release mode in addition to pushing images for installer tools
	build/create_images.sh $(RELEASE_BRANCH) $(BASE_IMAGE) \
		$(IMAGE_REPO) $(COMPONENT) $(IMAGE_TAG) false

	build/create_images.sh $(RELEASE_BRANCH) $(BASE_IMAGE) \
		$(IMAGE_REPO) $(COMPONENT) $(IMAGE_TAG) true

.PHONY: docker		
docker: binaries
	docker build  \
		-t $(IMAGE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg TARGETARCH=amd64 \
		--build-arg TARGETOS=linux \
		--build-arg RELEASE_BRANCH=$(RELEASE_BRANCH) \
		-f ./docker/linux/Dockerfile .

.PHONY: docker-push
docker-push:
	docker push $(IMAGE)

.PHONY: build
build: FAKE_ARM_IMAGES_FOR_VALIDATION=true
build: local-images copy-artifacts attribution validate-checksums

.PHONY: release
release: images copy-artifacts validate-checksums
	# sync kubernetes directory for oci tars
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) kubernetes
	echo "Done $(COMPONENT)"

.PHONY: copy-artifacts
copy-artifacts:
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(COMPONENT) $(RELEASE_BRANCH) $(RELEASE)
	$(BUILD_LIB)/validate_artifacts.sh $(MAKE_ROOT) $(RELEASE_BRANCH) $(RELEASE) $(GIT_TAG) 'kubernetes' $(FAKE_ARM_IMAGES_FOR_VALIDATION) "-path *coredns*"

.PHONY: all
all: release

.PHONY: attribution
attribution: 
	build/create_attribution.sh $(RELEASE_BRANCH) $(GOLANG_VERSION)

.PHONY: checksums
checksums:
	$(BUILD_LIB)/update_checksums.sh $(MAKE_ROOT) $(MAKE_ROOT)/_output/bin $(MAKE_ROOT)/$(RELEASE_BRANCH)/CHECKSUMS

.PHONY: validate-checksums
validate-checksums:
	sha256sum -c $(MAKE_ROOT)/$(RELEASE_BRANCH)/CHECKSUMS

.PHONY: clean
clean: 
	rm -rf $(REPO)
	rm -rf "_output"

