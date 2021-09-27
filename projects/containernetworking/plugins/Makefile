BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
BUILD_LIB=$(BASE_DIRECTORY)/build/lib
MAKE_ROOT=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd -P)
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
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
build: tarballs attribution validate-checksums
	echo "Done $(COMPONENT)"

.PHONY: release
release: tarballs validate-checksums
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(COMPONENT) $(RELEASE_BRANCH) $(RELEASE)
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
	echo "Done $(COMPONENT)"

.PHONY: all
all: release

.PHONY: attribution
attribution: 
	build/create_attribution.sh $(GOLANG_VERSION)

docker:

docker-push:

.PHONY: checksums
checksums:
	$(BUILD_LIB)/update_checksums.sh $(MAKE_ROOT) $(MAKE_ROOT)/_output/bin $(MAKE_ROOT)/CHECKSUMS

.PHONY: validate-checksums
validate-checksums:
	sha256sum -c $(MAKE_ROOT)/CHECKSUMS

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"
