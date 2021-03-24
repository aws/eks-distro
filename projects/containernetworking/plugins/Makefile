BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
RELEASE_BRANCH?=1-18
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket
GIT_TAG?=$(shell cat GIT_TAG)
GOLANG_VERSION?=1.14

REPO=plugins
COMPONENT=containernetworking/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG) $(GOLANG_VERSION)

.PHONY: tarballs
tarballs:  binaries
	build/create_tarballs.sh $(REPO) $(GIT_TAG)

.PHONY: build
build: tarballs
	echo "Done $(COMPONENT)"

.PHONY: release
release: tarballs
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(COMPONENT) $(RELEASE_BRANCH) $(RELEASE)
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
	echo "Done $(COMPONENT)"

.PHONY: all
all: release

.PHONY: generate-attribution
generate-attribution: 
	build/create_attribution.sh $(GOLANG_VERSION)

docker:

docker-push:

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"
